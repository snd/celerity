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

    'single 50 ms bucket':

        'read returns 0 initially': (test) ->
            config =
                redis: this.redis
                timespanMs: 50
                bucketCount: 1

            celerity.read config, 'test', (err, count) ->
                throw err if err?
                test.equals count, 0

                test.done()

        'incrementAndRead on empty bucket returns increment': (test) ->
            config =
                redis: this.redis
                timespanMs: 50
                bucketCount: 1

            celerity.incrementAndRead config, 'test', 5, (err, count) ->
                throw err if err?
                test.equals count, 5

                test.done()

        'increment and then read returns increment before expire': (test) ->
            config =
                redis: this.redis
                timespanMs: 50
                bucketCount: 1

            celerity.increment config, 'test', 5, (err) ->
                throw err if err?
                next = ->
                    celerity.read config, 'test', (err, count) ->
                        throw err if err?
                        test.equals count, 5
                        test.done()

                setTimeout next, 40

        'single bucket is cleared after timespan': (test) ->
            config =
                redis: this.redis
                timespanMs: 50
                bucketCount: 1

            celerity.increment config, 'test', 5, (err, count) ->
                throw err if err?
                next = ->
                    celerity.read config, 'test', (err, count) ->
                        throw err if err?
                        test.equals count, 0
                        test.done()

                setTimeout next, 60

        'single bucket is incremented': (test) ->
            config =
                redis: this.redis
                timespanMs: 50
                bucketCount: 1

            celerity.increment config, 'test', 1, (err) ->
                throw err if err?
                celerity.increment config, 'test', 1, (err) ->
                    throw err if err?
                    celerity.increment config, 'test', 1, (err) ->
                        throw err if err?
                        celerity.read config, 'test', (err, count) ->
                            throw err if err?
                            test.equals count, 3

                            test.done()
