ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.pending()', ->

  it 'should interrupt execution within a loop', (done) ->
    count = 0
    radioactive ->
      count++
      radioactive.pending()
      count++

    ut.delay 100, ->
      count.should.equal 1
      done()