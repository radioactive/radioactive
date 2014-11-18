chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'
ut          = require 'ut'

delay = -> setTimeout arguments[1], arguments[0]

STEP = 100

case_insensitive_comparator = (a, b) -> a.toLowerCase() is b.toLowerCase()

describe 'radioactive.distinct', ->

  it '1', (done) ->
    val = undefined
    c1 = radioactive.cell 'a'
    counter = 0
    radioactive.react ->
      counter++
      val = c1()
    delay STEP, ->
      val.should.equal 'a'
      counter.should.equal 1
      done()

  it '2', (done) ->
    val = undefined
    c1 = radioactive.cell 'a'
    counter = 0
    radioactive.react ->
      counter++
      val = c1()
    delay STEP, ->
      val.should.equal 'a'
      counter.should.equal 1
      c1 'A'
      delay STEP, ->
        val.should.equal 'A'
        counter.should.equal 2
        done()

  it '3', (done) ->
    val = undefined
    c1 = radioactive.cell 'a'
    counter = 0
    radioactive.react ->
      counter++
      val = radioactive.distinct c1
    delay STEP, ->
      val.should.equal 'a'
      counter.should.equal 1
      c1 'A'
      delay STEP, ->
        val.should.equal 'A'
        counter.should.equal 2
        done()

  it '4', (done) ->
    val = undefined
    c1 = radioactive.cell 'a'
    counter = 0
    radioactive.react ->
      counter++
      val = radioactive.distinct c1, case_insensitive_comparator
    delay STEP, ->
      val.should.equal 'a'
      counter.should.equal 1
      c1 'A'
      delay STEP, ->
        val.should.equal 'a'
        c1().should.equal 'A'
        counter.should.equal 1
        done()