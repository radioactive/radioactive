chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

delay = -> setTimeout arguments[1], arguments[0]

STEP = 100

build_helper = ->
  n = null
  ret = ->
    n = radioactive.notifier()
    true
  ret.notify = -> n?()
  ret

describe 'radioactive.loop', ->

  it 'should run at least once if it contains an R(0) expression', (done) ->
    radioactive.loop -> done()

  ###
  radioactive.loop will always run asynchronously.
  This makes it easier to reason about things.
  ###
  it 'should always run asynchronously', ( done ) ->
    counter = 0
    radioactive.loop -> counter++
    counter.should.equal 0
    delay STEP, ->
      counter.should.equal 1
      done()

  it 'should run only once if expression is not reactive', ( done ) ->
    counter = 0
    radioactive.loop -> counter++
    counter.should.equal 0
    delay STEP, ->
      counter.should.equal 1
      delay STEP, ->
        counter.should.equal 1 # no increment
        done()

  it 'run more than once if expression is reactive and notifies()', (done) ->
    helper = build_helper()
    counter = 0
    radioactive.loop ->
      counter++
      helper()
    counter.should.equal 0
    delay STEP, ->
      counter.should.equal 1
      delay STEP, ->
        counter.should.equal 1
        helper.notify()
        delay STEP, ->
          counter.should.equal 2
          delay STEP, ->
            counter.should.equal 2
            done()

  it 'should wait and retry', (done) ->
    echo = radioactive.echo 10
    rets = []
    radioactive.loop ->
      rets.push '|'
      rets.push echo 'a'
      rets.push echo 'b'
      rets.push echo 'c'
    delay 300, ->
      rets.join("").should.equal '||a|ab|abc'
      done()


  it 'should work with fork', (done) ->
    echo = radioactive.echo 10
    rets = []
    radioactive.loop ->
      fork = radioactive.fork()
      fecho = (str) -> ( fork -> echo str ) or '?'
      rets.push '|'
      rets.push fecho 'a'
      rets.push fecho 'b'
      rets.push fecho 'c'
      fork.join()
    delay 400, ->
      rets.join("").should.equal '|???|abc'
      done()




