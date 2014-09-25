ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

describe 'radioactive.echo', ->
  it 'should return a function', ->
    echo = radioactive.echo()
    should.exist echo
    echo.should.be.a 'function'
  describe 'the returned function', ->
    it 'should throw a WaitSignal', ->
      echo = radioactive.echo()
      echo.should.throw()
    it 'should echo after a while', (done) ->
      echo = radioactive.echo 10
      ( -> echo 'hello' ).should.throw()
      ut.delay 20, ->
        ( -> echo 'hello' )().should.equal 'hello'
        done()