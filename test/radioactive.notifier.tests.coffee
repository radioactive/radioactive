ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.notifier()', ->
  it 'should return undefined when called from outside a reactive context', ->
    should.not.exist radioactive.notifier()
  it 'should return a notifier when called from inside a reactive context', ( done ) ->
    radioactive.react ->
      if radioactive.notifier()?
        done()
      else
        done new Error 'no notifier'

describe 'radioactive.notifier(callback)', ->
  it 'should not call the callback when called from outside a reactive context', ->
    called = no
    radioactive.notifier -> called = yes
    called.should.equal no
  it 'should call the callback passing a notifier when called inside a reactive context', ( done ) ->
    radioactive.react ->
      radioactive.notifier ( n ) ->
        should.exist n
        done()