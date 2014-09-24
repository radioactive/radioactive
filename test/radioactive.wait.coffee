ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.wait', ->

  it 'should interrupt execution within a loop', (done) ->
    count = 0
    radioactive ->
      count++
      radioactive.wait()
      count++

    ut.delay 100, ->
      count.should.equal 1
      done()