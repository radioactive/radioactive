ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.pending(expr)', ->

  it 'should return true when block throws an PendingSignal', (done) ->
    radioactive ->
      r = radioactive.pending -> radioactive.pending()
      unless r then done new Error() else done()

  it 'should return false when block does not throw an PendingSignal', (done) ->
    radioactive ->
      r = radioactive.pending ->
      if r then done new Error() else done()

  it 'should return false when block throws any other type of error', (done) ->
    radioactive ->
      r = radioactive.pending -> throw new Error
      if r then done new Error() else done()

  it 'should be reactive if the inner expression is reactive', (done) ->

    cell = radioactive.cell new radioactive.PendingSignal
    results = []

    radioactive ->
      results.push radioactive.pending cell

    ut.delay 100, ->
      results.length.should.equal 1
      results[0].should.equal true
      cell "foo"

      ut.delay 100, ->
        results.length.should.equal 2
        results[0].should.equal true
        results[1].should.equal false
        done()