ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

ucasync = ( str, cb ) -> ut.delay 10, -> cb null, str.toUpperCase()

describe 'radioactive.syncify', ->

  it 'should return a function', ->
    uc = radioactive.syncify ucasync
    uc.should.be.a 'function'


  describe 'should create a service which', ->

    it 'should throw a WaitSignal initially', (done) ->
      uc = radioactive.syncify func: ucasync, global: true
      try
        uc 'Hello'
      catch e
        if e instanceof radioactive.WaitSignal
          done()
        else
          done e
        return
      done new Error


    it 'should return a value if we give it enough time', (done) ->
      uc = radioactive.syncify func: ucasync, global: true
      try # it will throw a WaitSignal the first time
        uc 'Hello'
      ut.delay 30, ->
        uc('Hello').should.equal 'HELLO'
        done()