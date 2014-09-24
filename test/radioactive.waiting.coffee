ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.waiting', ->

  it 'should return true when block throws a wait signal', (done) ->
    radioactive.loop ->
      r = radioactive.waiting -> radioactive.wait()
      unless r then done new Error() else done()

  it 'should return false when block does not throw a wait signal', (done) ->
    radioactive.loop ->
      r = radioactive.waiting ->
      if r then done new Error() else done()

  it 'should return false when block throws any other type of error', (done) ->
    radioactive.loop ->
      r = radioactive.waiting -> throw new Error
      if r then done new Error() else done()

  it 'should be reactive if the inner expression is reactive', (done) ->

    cell = radioactive.cell new radioactive.WaitSignal
    results = []

    radioactive.loop ->
      results.push radioactive.waiting cell

    ut.delay 100, ->
      results.length.should.equal 1
      results[0].should.equal true
      cell "foo"

      ut.delay 100, ->
        results.length.should.equal 2
        results[0].should.equal true
        results[1].should.equal false
        done()