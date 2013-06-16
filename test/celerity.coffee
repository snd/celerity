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

    'read returns 0 initially': (test) ->
        config =
            redis: this.redis
            timespanMs: 1000
            bucketCount: 10

        celerity.read config, 'test', (err, count) ->
            throw err if err?
            test.equals count, 0

            celerity.buckets config, 'test', (err, buckets) ->
                throw err if err?

                test.deepEqual buckets, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                test.done()

    'incrementAndRead on empty bucket returns increment': (test) ->
        config =
            redis: this.redis
            timespanMs: 1000
            bucketCount: 10

        celerity.incrementAndRead config, 'test', 5, (err, count, bucketIndex) ->
            throw err if err?
            test.equals count, 5

            celerity.buckets config, 'test', (err, buckets) ->
                throw err if err?

                test.equals buckets[bucketIndex], 5

                test.done()

    'run over three timespans': (test) ->
        config =
            redis: this.redis
            timespanMs: 300
            bucketCount: 3

        incrementReadAndGetBuckets = (cb) ->
            celerity.incrementAndRead config, 'test', 1, (err, count, index) ->
                throw err if err?
                celerity.buckets config, 'test', (err, buckets) ->
                    throw err if err?
                    cb count, index, buckets

        readAndGetBuckets = (cb) ->
            celerity.read config, 'test', (err, count) ->
                throw err if err?
                celerity.buckets config, 'test', (err, buckets) ->
                    throw err if err?
                    cb count, buckets

        # 2 increments every 100 ms

        calls =

            # ramp up

            0: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 0
                    test.equals count, 1
                    test.deepEqual buckets, [1, 0, 0]
            50: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 0
                    test.equals count, 2
                    test.deepEqual buckets, [2, 0, 0]
            110: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 1
                    test.equals count, 3
                    test.deepEqual buckets, [2, 1, 0]
            150: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 1
                    test.equals count, 4
                    test.deepEqual buckets, [2, 2, 0]
            210: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 2
                    test.equals count, 5
                    test.deepEqual buckets, [2, 2, 1]
            250: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 2
                    test.equals count, 6
                    test.deepEqual buckets, [2, 2, 2]

            # oscillating and nearly constant

            310: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 0
                    test.equals count, 5
                    # first bucket has expired
                    test.deepEqual buckets, [1, 2, 2]
            350: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 0
                    test.equals count, 6
                    test.deepEqual buckets, [2, 2, 2]
            410: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 1
                    test.equals count, 5
                    # second bucket has expired
                    test.deepEqual buckets, [2, 1, 2]
            450: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 1
                    test.equals count, 6
                    test.deepEqual buckets, [2, 2, 2]
            510: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 2
                    test.equals count, 5
                    # third bucket has expired
                    test.deepEqual buckets, [2, 2, 1]
            550: ->
                incrementReadAndGetBuckets (count, index, buckets) ->
                    console.log count, index, buckets

                    test.equals index, 2
                    test.equals count, 6
                    test.deepEqual buckets, [2, 2, 2]

            # ramp down

            610: ->
                readAndGetBuckets (count, buckets) ->
                    console.log count, buckets

                    # first bucket has expired
                    test.equals count, 4
                    test.deepEqual buckets, [0, 2, 2]
                    test.done()
            710: ->
                readAndGetBuckets (count, buckets) ->
                    console.log count, buckets

                    # second bucket has expired
                    test.equals count, 2
                    test.deepEqual buckets, [0, 0, 2]
            810: ->
                readAndGetBuckets (count, buckets) ->
                    console.log count, buckets

                    # third bucket has expired
                    test.equals count, 0
                    test.deepEqual buckets, [0, 0, 0]
                    test.done()

        # align test timings with bucket boundaries

        currentPositionInTimespan = Date.now() % 300

        alignedContinuation = ->
            Object.keys(calls).forEach (key) ->
                call = -> calls[key]()
                setTimeout call, key

        setTimeout alignedContinuation, 300 - currentPositionInTimespan
