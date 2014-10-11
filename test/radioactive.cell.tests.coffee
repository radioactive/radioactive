chai    = require 'chai'
should  = chai.should()
X       = require './radioactive'
ut      = require 'ut'

describe 'a cell', ->
  c1 = X()
  it 'should be a function',               -> c1.should.be.a 'function'
  it 'should initially contain undefined', -> should.not.exist c1()
  it 'should accept a string',             -> c1 'hello'
  it 'should now return the string',       -> c1().should.equal 'hello'
  it 'should accept a different string',   -> c1 'hello2'
  it 'should now return the new string',   -> c1().should.equal 'hello2'
  it 'should return undefined when set',   -> should.not.exist c1 'foo'
  it 'should accept an error',             -> c1 new Error 'abc'
  it 'and throw it...',                    -> c1.should.throw 'abc'
  it 'and throw it again',                 -> c1.should.throw 'abc'
  it 'should accept callback style passing of values', ->
    r = c1 null, 'foo'
    should.not.exist r
    c1().should.equal 'foo'
  it 'should accept callback style passing of errors', ->
    r = c1 new Error('oops'), null
    should.not.exist r
    c1.should.throw 'oops'

describe 'a cell', ->
  it 'should be reactive', (done) ->
    c = X()
    values = []
    steps  = []
    steps.push ->
      values.should.have.length 1
      should.not.exist values[0][0]
      should.not.exist values[0][1]
      setTimeout ( -> c 'a' ), 10
    steps.push ->
      values.should.have.length 2
      should.not.exist values[1][0]
      should.exist v = values[1][1]
      v.should.equal 'a'
      c null
    steps.push ->
      values.should.have.length 3
      should.not.exist values[2][0]
      should.not.exist values[2][1]
      done()
    X ->
      try
        values.push [null, c()]
      catch e
        values.push [e, null]
      do steps.shift()

describe 'a cell', ->
  it 'can be initialized to a value upon construction', ->
    c = X 'a'
    c.should.be.a 'function'
    c().should.equal 'a'

describe 'a cell with a custom comparator', ->
  it 'should use it to determine whether a change has occurred or not', ->
    c = X.cell 'a', comparator: ( a, b ) -> a.toLowerCase() is b.toLowerCase()
    c().should.equal 'a'
    c 'b'
    c().should.equal 'b'
    c 'B'
    c().should.equal 'b'

describe 'a throttled cell', ->
  it 'should throttle its set() operation', ( done ) ->
    c = X.cell 'a', throttle: 100
    c().should.equal 'a'
    c 'b'
    c().should.equal 'a'
    ut.delay 200, ->
      c().should.equal 'b'
      done()

  it 'should throttle its set() operation 2', ( done ) ->
    c = X.cell 'a', throttle: 100
    c().should.equal 'a'
    c 'b'
    c().should.equal 'a'
    ut.delay 50, ->
      c 'a'
      c().should.equal 'a'
      ut.delay 200, ->
        c 'a'
        c().should.equal 'a'
        done()