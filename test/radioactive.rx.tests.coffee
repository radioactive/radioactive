chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'
Rx          = require 'rx'
ut          = require 'ut'

describe 'radioactive.rx', ->

  describe 'expr -> Rx.Observable', ->

    it 'should return an Rx.Observable', ->
      obs = radioactive.rx ->
      obs.should.be.instanceof Rx.Observable

    it 'which works with an R(0) expression', ( done ) ->
      obs = radioactive.rx -> 'a'
      obs.subscribe ( x ) ->
        x.should.equal 'a'
        done()

    it 'which works with an R(2) expression', ( done ) ->
      echos = radioactive.echo()
      obs = radioactive.rx -> echos 'a'
      obs.subscribe ( x ) ->
        x.should.equal 'a'
        done()

  describe 'Rx.Observable -> expr', ->

    it 'should return an expression', ->
      expr = radioactive.rx Rx.Observable.fromArray []
      expr.should.be.a 'function'

  ###
  it.skip 'xx', ->

    obs = radioactive.rx ->
      radioactive.time()
      console.log ''
      console.log 'i: ' + time
      time

    obs = obs.filter (t) ->
      console.log 'filtering', t
      ( t % 2 ) is 0

    obs.subscribe (x) ->
      console.log 'o: ' + x

  it.skip 'foo', ( done ) ->
    obs = radioactive.rx -> radioactive.time 100
    # obs = obs.filter (x) -> ( x % 2 ) is 0
    obs = obs.map (x) -> "time is " + x

    #obs.subscribe (x) -> console.log 'o: ' + x

    expr = radioactive.rx(obs)

    radioactive.react ->
      console.log expr().toUpperCase()

  it.skip 'should work again', ->

    time  = radioactive.time
    time2 = radioactive.rx time, (obs) ->
      obs = obs.filter (x) -> ( x % 2 ) is 0
      obs.map (x) -> 'the time is ' + x

    radioactive -> console.log time2()


    console.log ''
  ###