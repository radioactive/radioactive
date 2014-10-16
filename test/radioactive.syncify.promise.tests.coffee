ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'
Q           = require 'q'

ucasync = ( str, cb ) ->
  deferred = Q.defer()
  ut.delay 10, -> deferred.resolve str.toUpperCase( )
  deferred.promise

describe 'radioactive.syncify ( over a promise )', ->

  it 'should return a function', ->
    uc = radioactive.syncify ucasync
    uc.should.be.a 'function'

  describe 'should create a service which', ->

    it 'should throw a PendingSignal initially', (done) ->
      uc = radioactive.syncify func: ucasync, global: true
      try
        uc 'Hello'
      catch e
        if e instanceof radioactive.PendingSignal
          done()
        else
          done e
        return
      done new Error


    it 'should return a value if we give it enough time', (done) ->
      uc = radioactive.syncify func: ucasync, global: true
      try # it will throw a PendingSignal the first time
        uc 'Hello'
      ut.delay 30, ->
        uc('Hello').should.equal 'HELLO'
        done()