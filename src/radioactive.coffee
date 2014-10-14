VERSION = '1.0.0'

serial = do -> ii = 0 ; -> ii++


WIKI_URL                   = 'https://github.com/radioactive/radioactive/wiki'
DEBUG                      = yes
DEFAULT_LOOP_DELAY         = 50
LOOP_ITERATIONS_TO_SURVIVE = 2

is_special_error = ( e ) -> e instanceof PendingSignal or e instanceof StopSignal
debug_error      = ( e ) -> console.log e if DEBUG and e? and ! is_special_error e

next_tick        = ( f ) -> setTimeout f, 1
tap              = ( v ) -> ( f ) -> f v ; v

delay            = -> setTimeout arguments[1], arguments[0]

EQUALS           = (a, b) -> a is b


class PendingSignal extends Error
  constructor: -> super "PendingSignal"

class StopSignal extends Error
  constructor: -> super()


class BasicEventEmitter
  constructor: ->
    @_request_cleanup = no
    @_handlers = []
  emit: ( type, payload ) ->
    @_handlers.forEach (h) =>
      if h.type is type and 0 is h.fire payload
        @_request_cleanup = yes
    @_cleanup()
  on:   ( type, f ) -> @_upsert type, f, -1
  once: ( type, f ) -> @_upsert type, f,  1
  off:  ( type, f ) -> @_upsert type, f,  0
  removeListener: ( type, f ) -> @off type, f
  removeAllListeners: -> @_handlers = []
  _cleanup: ->
    if @_request_cleanup
      @_request_cleanup = no
      @_handlers = ( h for h in @_handlers when h.remaining isnt 0 )
  _find_handler: ( type, f ) ->
    return h for h in @_handlers when h.equals type, f
    undefined
  _upsert: (type, f, q) ->
    if ( x = @_find_handler type, f )?
      x.update q
    else
      return if q is 0
      @_handlers.push new BasicEventEmitterHandler type, f, q
    if q is 0
      @_request_cleanup = yes
      @_cleanup()


class BasicEventEmitterHandler
  constructor: ( @type, @func, @remaining = -1 ) ->
  update: ( q ) ->
    return if @remaining < 0 and q is 1
    @remaining = q
  fire: (e) ->
    if @remaining isnt 0
      @remaining--
      @func e
    @remaining
  ###
  equals(type:string, func:CB):boolean;
  equals(other:Handler):boolean;
  ###
  equals: ( type, func ) ->
    if type instanceof BasicEventEmitterHandler
      func = type.func
      type = type.type
    @type is type and @func is func


class StackVal
  constructor: -> @stack = []
  defined:     -> @stack.length > 0
  run: ( expr, build ) ->
    try
      @stack.push build()
      expr()
    finally @stack.pop()
  get: -> if @defined() then @stack[@stack.length - 1] else throw new Error "No value found upstack"


class Base extends BasicEventEmitter
  constructor: -> super()


class Notifier extends Base
  constructor: ( @monitor ) -> super()
  fire:                 -> @monitor.fire @
  cancel:               -> # TODO
  is_active:            -> yes # TODO: states
  # Expose a minimal interface. See typescript definition file.
  public_api:           ->
    api      = => @fire()
    api.once = ( h ) => @once h
    api.off  = ( h ) => @off h
    api


class NotifierPool extends Base
  constructor:        ->
    super()
    @notifiers = []
  allocate:           -> @notifiers.push ReactiveEval.notifier() if ReactiveEval.active()
  cancel:             -> @_each (n) -> n.cancel()
  fire:               -> @_each (n) -> n.fire()
  monitor_cancelled:  -> @_each (n) -> n.monitor_cancelled()
  sibling_fired:      -> @_each (n) -> n.sibling_fired()
  # true if it has at least one active notifier at this time
  is_active: ->
    return true for n in @notifiers when n.is_active()
    no
  _each: ( f ) ->
    ns = @notifiers
    @notifiers = []
    ns.forEach f


class NotifierPoolWithValue
  constructor: ->
    @notifiers = new NotifierPool()
    @current = Try.null
  allocate: ->
  set: ( e, r ) ->
    @current = Try.resolve e, r
    @notifiers.fire()
  get: ->
    @notifiers.allocate()
    @current.get()


class Monitor extends Base
  constructor: ->
    super()
    @notifiers = []

  notifier: ->
    @notifiers.push n = new Notifier @
    n

  cancel: -> # TODO

  fire: ->
    # IMPORTANT: we never fire in the same "thread"
    # this provides a simple and robust solution for nested notifications and recursion
    next_tick => @emit 'fire'

  bubble:            ->
    if ReactiveEval.active()
      n = ReactiveEval.notifier()
      @once 'fire', -> n.fire()

  @join: ( monitors ) ->
    if ReactiveEval.active()
      notifier = ReactiveEval.notifier()
      len = monitors.length
      cb  = -> notifier.fire() if --len is 0
      monitors.forEach (m) -> m.once 'fire', cb


class MonitorListenerProxy
  constructor: ( @handler ) ->
  swap: ( m ) ->
    @monitor?.off 'fire', @handler
    @monitor = m
    @monitor?.once 'fire', @handler


class Try
  constructor: ( @error, @result ) ->
  get: ->
    throw @error if @error?
    @result
  equals: ( other, comparator = undefined ) ->
    comparator ?= ( a, b ) -> a is b
    return false unless other instanceof Try
    if other.error? or @error?
      comparator other.error, @error
    else
      comparator other.result, @result
  @eval: ( expr ) -> try new Try null, expr() catch e then new Try e
  @err: ( v ) -> new Try v, null
  @res: ( v ) -> new Try null, v
  @resolve: ( e, r ) ->
    return e if e instanceof Try
    if e? then new Try e, null else new Try null, r
  @one: ( x ) -> if x instanceof Error then new Try x else new Try null, x
  @null: new Try null, null


class Token
  result:  null # Try
  partial: false
  monitor: null # Monitor?


class Iterator extends Base

  expired:         yes
  last_token:      null # :Token
  iteration_count: 0

  constructor: ( expr ) ->
    super()
    @expr = @add_to_stack @invalidate_service_caches @mark_partials @attach_monitors @update_counters @tokenize expr
    @monitor_listener = new MonitorListenerProxy =>
      @expired = yes
      @emit 'change'
    @cache = {}

  # upon creating the iterator you must call refresh manually
  refresh: -> # : Boolean
    if @expired
      @expired = false
      t = @expr()
      @monitor_listener.swap t.monitor
      @last_token = t
      debug_error t.result?.result?.error
      true
    else
      false

  current:    -> if @pending() then Try.null else @last_token.result
  pending:    -> @last_token.result.error instanceof PendingSignal
  expireable: -> if @last_token? then @last_token.monitor? else true

  close: ->
    @last_token?.monitor?.cancel()
    @monitor_listener.swap null
    @cache = {}

  # some of the following combinators don't need access to the instance
  # we could put them somewhere else but we keep them all here
  # for clarity

  tokenize: ( expr ) -> -> tap( new Token ) ( t ) -> t.result = Try.eval expr

  attach_monitors: ( stream ) -> ->
    r = ReactiveEval.eval stream
    tap( r.result ) ( t ) -> t.monitor = r.monitor

  mark_partials: ( stream ) -> ->
    prm = new PartialResultMarker
    tap( prm.run stream ) ( t ) -> t.partial = prm.marked

  invalidate_service_caches: ( stream ) => => tap( stream() ) ( t ) =>
    @cache = {} unless t.partial or t.result.error instanceof PendingSignal

  update_counters: ( stream ) => => tap( stream() ) => @iteration_count++
  add_to_stack:    ( stream ) => => Iterator.stack.run stream, => @

  @stack: new StackVal
  @current_cache: -> @stack.get().cache # : Object


class ReactiveLoop extends Base
  constructor: ( expr , @opts = null ) ->
    super()
    @opts ?= {}
    @opts.debounce ?= DEFAULT_LOOP_DELAY
    @opts.detached ?= true
    @iter = new Iterator => ReactiveLoop.stack.run expr, => @
    @_attach_to_parent()
    @_request_loop()

  _request_loop: ->
    clearTimeout @loop_timeout if @loop_timeout?
    @loop_timeout = setTimeout @_loop, @opts.debounce

  _loop: =>
    if @_eol_heuristics()
      @iter.refresh()
      err = @iter.current().error
      if err instanceof StopSignal
        @stop()
      else
        if err? then try console.log err
        @iter.once "change", => @_request_loop()
    else
      @stop()

  iteration_count: ->  @iter.iteration_count

  stop: =>
    clearTimeout @loop_timeout if @loop_timeout?
    @iter.close()

  _eol_heuristics: -> # :Boolean
    if @parent?
      iterations_we_have_lived = @parent.iteration_count() - @parent_iteration_count
      if iterations_we_have_lived > LOOP_ITERATIONS_TO_SURVIVE
        return false
    true

  parent: undefined
  parent_iteration_count: undefined
  _attach_to_parent: ->
    unless @opts.detached
      if ReactiveLoop.stack.defined()
        @parent = ReactiveLoop.stack.get
        @parent_iteration_count = @parent.iteration_count()

  @stack: new StackVal


syncify = ( opts ) ->
  opts = func: opts if typeof opts is 'function'
  opts.global ?= no
  opts.ttl    ?= 0
  opts.hasher ?= JSON.stringify

  id = serial()
  instance_scoped_cache_lazy = undefined
  cache = ->
    build = ->
      cells = {}
      get = ( args ) ->
        if args.length isnt opts.func.length - 1
          # TODO: improve this error message. We have more info at hand
          throw new Error 'Wrong number of arguments for syncified function ' + opts.func.toString()
        key = opts.hasher args
        do cells[ key ] ?= do ->
          c = build_cell new PendingSignal
          c.___args = args
          if opts.ttl isnt 0 then c.___timeout = delay opts.ttl, -> reset_cell key
          opts.func.apply null, args.concat [c]
          c
      reset_cell = ( key ) ->
        if ( cell = cells[key] )?
          # 1. delete cell so we re-created on next call ( TODO: we could reuse it )
          delete cells[key]
          # 2. clear any associated timeouts if they exist
          if cell.___timeout then clearTimeout cell.___timeout
          # 3. let people know that something changed
          #    no one has direct access to this cell. we just set it to something "different"
          #    to trigger notifiers
          if cell.monitored() then cell {}
          # TODO: destroy cell?
      reset = ( filter ) ->
        reset_cell k for own k, cell of cells when not filter? or filter cell.___args
      {get, reset}
    # TODO: TTL
    iteration_scoped = -> Iterator.current_cache()[ id ] ?= build()
    instance_scoped  = -> instance_scoped_cache_lazy     ?= build()
    if opts.global then instance_scoped() else iteration_scoped()
  api       = -> cache().get Array::slice.apply arguments
  api.reset = ( filter ) -> instance_scoped_cache().reset filter
  api




fork = ->
  pending  = 0
  monitors = []
  api = ( expr ) ->
    res = ReactiveEval.eval expr
    if res.result.error instanceof PendingSignal
      unless res.monitor?
        throw new Error 'You cannot throw a PendingSignal from a non reactive function - it will never resolve'
      pending++
      monitors.push res.monitor
      null
    else
      res.unbox()
  api.join = ->
    Monitor.join monitors
    if pending > 0 then throw new PendingSignal
    undefined
  api


class PartialResultMarker
  flag:     false
  run:      ( expr ) -> PartialResultMarker.stack.run expr, => this
  mark:     => @flag = yes
  marked:   -> @flag
  @stack:   new StackVal
  @mark: -> @stack.get().mark()


class ReactiveEval
  constructor: ( @expr ) ->
  lazy_monitor: -> @_monitor ?= new Monitor
  run: ->
    # evaluate expression first. it may create a monitor
    t = Try.eval @expr
    # and now compose result
    new ReactiveEvalResult t, @_monitor
  allocate_notifier: -> @lazy_monitor().notifier()
  @stack: []
  # may return null
  @notifier: -> @stack[@stack.length - 1]?.allocate_notifier()
  @active:   -> @stack.length > 0
  @mute: ( expr ) -> ->
    res = ReactiveEval.eval expr
    res.monitor?.cancel()
    delete res.result.error if is_special_error res.result.error
    res.result
  @eval: ( expr ) ->
    rev = new ReactiveEval expr
    @stack.push rev
    r = rev.run()
    @stack.pop()
    r


class ReactiveEvalResult
  constructor: ( @result, @monitor ) ->
  unbox: ->
    @monitor?.bubble()
    @result.get()


build_cell = ( initial_value, opts = {} ) ->

  opts.comparator  ?= EQUALS
  opts.throttle    ?= 0

  value            = undefined
  notifiers        = new NotifierPool
  throttle_timeout = undefined

  doget = ->
    notifiers.allocate()
    value?.get()

  doset_throttled = ( v ) ->
    if opts.throttle is 0
      doset v
    else
      if throttle_timeout
        clearTimeout throttle_timeout
        throttle_timeout = undefined
      throttle_timeout = delay opts.throttle, -> doset v

  doset = ( v ) ->
    new_t = if v instanceof Error then new Try v else new Try null, v
    return if new_t.equals value, opts.comparator
    value = new_t
    notifiers.fire()

  api = ->
    a = arguments
    switch a.length
      when 0 then doget()
      when 1 then doset_throttled a[0]
      when 2 then doset_throttled a[0] or a[1]

  api.monitored = -> notifiers.is_active()
  if initial_value? then doset initial_value
  api


###
  Wraps an expression.
  After the expression is evaluated.
  It will remain being re-evaluated in the back until a change is detected
  When this happens, this function will notify()
###
poll = ( interval, expr ) ->
  if typeof interval is 'function'
    expr     = interval
    interval = 300
  reval = ( exp ) ->
    r = ReactiveEval.eval exp
    r.monitor?.cancel()
    r.result
  unless ReactiveEval.active()
    expr()
  else
    notifier = ReactiveEval.notifier()
    res      = reval expr
    do iter = -> delay interval, ->
      if notifier.is_active()
        if res.equals reval expr
          iter()
        else
          notifier.fire()
    res.get()


radioactive_data = do ->
  json_service = do ->
    cached = undefined
    ->
      cached ?= do ->
        unless jQuery? then throw new Error 'radioactive.data requires jQuery to issue Ajax calls'
        syncify ( url, cb ) ->
          jQuery.ajax
            dataType: "json"
            url:      url
            success:  ( data )      -> cb null, data
            error:    ( x, y, err ) -> cb err
  # TODO: AJAX JSON options
  get_json = ( url, opts ) -> json_service() url
  # public API

  firebase_cache = {}
  get_firebase = ( url ) ->
    do firebase_cache[url] ?= do ->
      unless Firebase? then throw new Error 'cannot find Firebase client library'
      ref  = new Firebase url
      cell = build_cell new PendingSignal
      ref.on 'value', ( snap ) -> cell snap.val()
      cell

  get_html_elm_val = ( $elm ) ->
    unless jQuery? then throw new Error 'radioactive.data requires jQuery to issue read HTML UI Element values'
    $elm.val()
    key = 'radioactive-cell'
    unless ( c = $elm.data key )?
      $elm.data key, c = build_cell $elm.val()
      switch $elm[0].tagName
        when 'INPUT'
          $elm.on 'keyup', -> c $elm.val()
        when 'SELECT'
          $elm.on 'change', -> c $elm.val()
    c()

  ->
    a = arguments
    switch typeof a[0]
      when 'string'
        if a[0][0] in ['.', '#'] # selectors
          get_html_elm_val $(a[0])
        else if -1 isnt a[0].indexOf 'firebaseio.com'
          get_firebase a[0]
        else
          get_json a[0], a[1]
      when 'object'
        if $(a)[0].ownerDocument?
          get_html_elm_val $(a[0])
      else
        throw new Error "Unknown datasource. Check #{WIKI_URL}/radioactive.data for a list of built-in datasources"

###
  Integration with Reactive Extensions for Javascript
  https://github.com/Reactive-Extensions
###

rxjs = do ->
  # find the Rx module
  rx_module = undefined
  resolve_rx_module = -> rx_module ?= do ->
    tap( try require 'r' + 'x' catch e then Rx ) ( m ) ->
      throw new Error 'Rx-JS not found' unless m?

  from_rx = ( rx_observable ) -> # R(2) expression
    unless typeof rx_observable.subscribe is 'function'
      throw new Error 'Not an instance of Rx.Observable'
    rx_observable.__radioactive_expression ?= do ->
      npv = new NotifierPoolWithValue
      npv.set new PendingSignal
      on_next = ( x ) -> npv.set null, x
      on_err  = ( x ) -> npv.set x, null
      on_complete =   -> # TODO
      rx_observable.subscribe on_next, on_err, on_complete
      -> npv.get()

  to_rx = ( expr ) -> # Rx.Observable
    expr.__rx_observable ?= do ->
      resolve_rx_module( ).Observable.create ( observer ) ->
        radioactive.react expr, (e, r) ->
          if e? then observer.onError e else observer.onNext r

  expr_roundtrip = ( expr, process_obs ) -> from_rx process_obs to_rx expr
  obs_roundtrip  = ( obs, process_expr ) -> to_rx process_expr from_rx obs

  ( a, b ) -> switch typeof a + ' ' + typeof b
    when 'function undefined' then to_rx          a
    when 'object undefined'   then from_rx        a
    when 'function function'  then expr_roundtrip a, b
    when 'object function'    then obs_roundtrip  a, b


loop_with_callback = ( expr, cb ) ->
  stop = no
  radioactive.react ->
    radioactive.stop() if stop
    try cb null, expr()
    catch e
      throw e if is_special_error e
      cb e
  -> stop = yes


is_pending = ( expr ) ->
  try
    expr()
    false
  catch e
  if e instanceof PendingSignal
    PartialResultMarker.mark()
    true
  else
    false


build_public_api = ->

  radioactive = ( a, b ) -> switch typeof a + ' ' + typeof b
    when 'function undefined' then radioactive.react a
    when 'function function'  then radioactive.react a, b
    else                           build_cell        a

  radioactive.data      = radioactive_data

  radioactive.cell      = build_cell

  radioactive.active    = -> ReactiveEval.active()

  radioactive.notifier  = ( callback ) ->
    n = ReactiveEval.notifier()?.public_api()
    if callback?
      callback n if n?
    else
      n

  radioactive.stop      = -> throw new StopSignal

  radioactive.fork      = fork

  radioactive.mute      = ( expr ) -> ReactiveEval.mute expr

  radioactive.poll      = poll

  # TODO: options
  radioactive.react = ( a, b ) ->
    switch typeof a + ' ' + typeof b
      when 'function undefined' then new ReactiveLoop a
      when 'function function'  then loop_with_callback a, b

  radioactive.once = ( expr ) -> radioactive.react ->
    expr()
    radioactive.stop()

  radioactive.pending = ( expr, defv ) ->
    switch arguments.length
      when 0 then throw new PendingSignal
      when 1 then is_pending expr
      when 2
        if is_pending expr
          if typeof defv is 'function' then defv() else defv
        else
          expr()

  radioactive.syncify = syncify

  radioactive.echo = ( delay_ms = 1000 ) ->
    cells = {}
    ( message ) -> do cells[message] ?= do ->
        delay delay_ms, -> c message
        c = build_cell new PendingSignal

  radioactive.time = ( interval = 1000 ) ->
    setTimeout radioactive.notifier(), interval if interval > 0 and ReactiveEval.active()
    new Date().getTime()

  radioactive.PendingSignal = PendingSignal

  radioactive.rx = rxjs

  ###
    Exported internals ( for unit testing only )
  ###

  radioactive._internals      = internals = {}
  internals.Monitor           = Monitor
  internals.Notifier          = Notifier
  internals.ReactiveEval      = ReactiveEval
  internals.BasicEventEmitter = BasicEventEmitter

  radioactive


compare_semver = ( v1, v2 ) ->
  v1 = ( Number x for x in v1.split '.' )
  v2 = ( Number x for x in v2.split '.' )
  arr = for x1, i in v1
    x2 = v2[i]
    if x1 > x2 then 'GT' else if x1 < x2 then 'LT' else 'EQ'
  for x in arr
    return 'GT' if x is 'GT'
    return 'LT' if x is 'LT'
  'EQ'


GLOBAL = try window catch then global

# only build and replace if we are newer than the existing implementation
do conditional_build = ->
  create = false
  if ( other = GLOBAL.radioactive )?
    other_version = other.version or '0.0.0'
    if compare_semver( VERSION, other_version ) is 'GT'
      create = yes
  else
    create = yes
  if create then GLOBAL.radioactive = GLOBAL.Ra = build_public_api()

try
  module.exports = GLOBAL.radioactive