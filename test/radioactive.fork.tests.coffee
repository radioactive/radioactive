ut          = require 'ut'
chai        = require 'chai'
should      = chai.should()
radioactive = require './radioactive'

class Test
  constructor: ( @str, @block ) ->
  run: ( done ) ->
    arr = []
    echo = radioactive.echo 10
    x = ( t ) -> arr.push if t? then t else '_'
    radioactive =>
      x '|'
      @block echo, x
      end()
    end = =>
      actual = arr.join ''
      if actual isnt @str
        done new Error "expected #{@str} but got #{actual}"
      else
        done()


tests = []
T = ( str, block ) -> tests.push new Test str, block

T '|AB', (echo, x) ->
  x 'A'
  x 'B'

T '||A|AB', (echo, x) ->
  x echo 'A'
  x echo 'B'

T '|__|AB', (echo, x) ->
  fork = radioactive.fork()
  x fork -> echo 'A'
  x fork -> echo 'B'
  fork.join()

T '|1_2_3|1A2B34', (echo, x) ->
  fork = radioactive.fork()
  x '1'
  x fork -> echo 'A'
  x '2'
  x fork -> echo 'B'
  x '3'
  fork.join()
  x '4'

describe.only 'radioactive.fork', ->
  it 'should work', ( done ) ->
    do iter = ( error = null ) ->
      if error?
        return done error
      if t = tests.shift()
        t.run iter
      else
        done()
