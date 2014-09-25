ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'


describe 'radioactive.stop', ->
  it 'should stop execution', ( done ) ->
    m = {}
    radioactive ->
      m.a = yes
      radioactive.stop()
      m.b = yes
    ut.delay 100, ->
      should.exist m.a
      should.not.exist m.b
      done()

  it 'should stop only enclosing loop', ( done ) ->
    m = {}
    radioactive ->
      m.a = yes
      radioactive ->
        m.b = yes
        radioactive.stop()
        m.c = yes
      m.d = yes
    ut.delay 200, ->
      should.exist m.a
      should.exist m.b
      should.not.exist m.c
      should.exist m.d
      done()