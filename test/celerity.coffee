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
            timespanMs: 1000
            bucketCount: 1

        celerity.incrementAndRead config, 'test', 5, (err, count) ->
            throw err if err?
            test.equals count, 5

            test.done()
