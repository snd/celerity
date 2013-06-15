redis = require 'redis'

celerity = require '../src/celerity'

module.exports =

    'setUp': (done) ->
        this.redis = redis.createClient()
        this.redis.flushdb()
        done()

    'tearDown': (done) ->
        this.redis.quit (err) ->
            throw err if err?
            done()

    'incrementAndRead returns increment initially': (test) ->
        config =
            redis: this.redis
            timespanMs: 20
            bucketCount: 1

        celerity.incrementAndRead config, 'test', 5, (err, count) ->
            throw err if err?
            test.equals count, 5

            test.done()

    'increment and then read returns increment initially': (test) ->
        config =
            redis: this.redis
            timespanMs: 20
            bucketCount: 1

        celerity.increment config, 'test', 5, (err) ->
            throw err if err?
            next = ->
                celerity.read config, 'test', (err, count) ->
                    throw err if err?
                    test.equals count, 5
                    test.done()

            setTimeout next, 10


    'single bucket is cleared after timespan': (test) ->
        config =
            redis: this.redis
            timespanMs: 20
            bucketCount: 1

        celerity.increment config, 'test', 5, (err, count) ->
            throw err if err?
            next = ->
                celerity.read config, 'test', (err, count) ->
                    throw err if err?
                    test.equals count, 0
                    test.done()

            setTimeout next, 21
