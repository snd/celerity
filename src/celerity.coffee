lua = require './lua'

defaultPrefix = 'celerity:'

isInt = (n) ->
    return ('number' is typeof n) and (n % 1 is 0)

checkConfig = (config) ->
    unless 'object' is typeof config
        throw new Error 'config argument must be an object'
    unless 'object' is typeof config.redis
        throw new Error 'config.redis argument must be an object'
    unless isInt config.timespanMs
        throw new Error 'config.timespanMs argument must be an integer'
    unless isInt config.bucketCount
        throw new Error 'config.bucketCount argument must be an integer'
    if config.prefix? and 'string' isnt typeof config.prefix
        throw new Error 'config.prefix argument must be a string'
    unless isInt getBucketMs(config)
        throw new Error 'config.timespanMs must be evenly dividable by config.bucketCount'

getBucketMs = (config) ->
    config.timespanMs / config.bucketCount

getPrefix = (config) ->
    config.prefix or defaultPrefix

getBucketIndex = (config, now) ->
    Math.floor((now % config.timespanMs) / getBucketMs(config))

getKey = (config, name) ->
    getPrefix(config) + name

getBucketKey = (config, name, now) ->
    getPrefix(config) + name + ':' + getBucketIndex(config, now)

getExpire = (config) ->
    config.timespanMs

module.exports =

    increment: (config, name, n, cb) ->
        checkConfig config

        config.redis.eval lua.increment, 1,
            getBucketKey(config, name, Date.now()),
            n,
            getExpire(config),
            cb

    incrementAndRead: (config, name, n, cb) ->
        checkConfig config

        config.redis.eval lua.incrementAndRead, 2,
            getKey(config, name),
            getBucketKey(config, name, Date.now()),
            n,
            getExpire(config),
            config.bucketCount,
            cb

    read: (config, name, cb) ->
        checkConfig config

        config.redis.eval lua.read, 1,
            getKey(config, name),
            config.bucketCount,
            cb
