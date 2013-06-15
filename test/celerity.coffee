redis = require 'redis'

celerity = require '../src/celerity'

module.exports =

    # these tests assume 10 seconds latency

    'setUp': (done) ->
        this.redis = redis.createClient()
        this.redis.flushdb()
        done()

    'tearDown': (done) ->
        this.redis.quit (err) ->
            throw err if err?
            done()

    'single 100 ms bucket':

        'read returns 0 initially': (test) ->
            config =
                redis: this.redis
                timespanMs: 100
                bucketCount: 1

            celerity.read config, 'test', (err, count) ->
                throw err if err?
                test.equals count, 0

                test.done()

        'incrementAndRead returns increment initially': (test) ->
            config =
                redis: this.redis
                timespanMs: 100
                bucketCount: 1

            celerity.incrementAndRead config, 'test', 5, (err, count) ->
                throw err if err?
                test.equals count, 5

                test.done()

        'increment and then read returns increment initially': (test) ->
            config =
                redis: this.redis
                timespanMs: 100
                bucketCount: 1

            celerity.increment config, 'test', 5, (err) ->
                throw err if err?
                next = ->
                    celerity.read config, 'test', (err, count) ->
                        throw err if err?
                        test.equals count, 5
                        test.done()

                setTimeout next, 90

        'single bucket is cleared after timespan': (test) ->
            config =
                redis: this.redis
                timespanMs: 100
                bucketCount: 1

            celerity.increment config, 'test', 5, (err, count) ->
                throw err if err?
                next = ->
                    celerity.read config, 'test', (err, count) ->
                        throw err if err?
                        test.equals count, 0
                        test.done()

                setTimeout next, 110
