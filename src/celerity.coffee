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

module.exports =

    increment: (config, key, n = 1, cb) ->
        checkConfig config

        prefix = getPrefix config

        bucketIndex = Math.floor((Date.now() % config.timespanMs) / getBucketMs(config))

        fullKey = prefix + key + ':' + bucketIndex

        expire = config.timespanMs

        config.redis.eval lua.increment, 1, fullKey, n, expire, cb

    read: (config, key, cb) ->
        checkConfig config

        prefix = getPrefix config

        config.redis.eval lua.read, 1, (prefix + key), config.bucketCount, cb
