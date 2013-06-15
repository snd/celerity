lua = require './lua'

defaultPrefix = 'celerity:'

isInt = (n) ->
    return ('number' is typeof n) and (n % 1 is 0)

checkConfig = (config) ->
    unless config?
        throw new Error 'config argument is missing'
    unless 'object' is typeof config
        throw new Error 'config argument must be an object'
    unless 'object' is typeof config.redis
        throw new Error 'config.redis argument must be an object'
    unless config.timespanMs?
        throw new Error 'config.timespanMs argument is missing'
    unless isInt config.timespanMs
        throw new Error 'config.timespanMs argument must be an integer'
    unless config.timespanMs?
        throw new Error 'config.bucketCount argument is missing'
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

    increment: (config, name, increment, cb) ->
        checkConfig config
        unless 'string' is typeof name
            throw new Error 'name argument must be a string'
        unless isInt increment
            throw new Error 'increment argument must be an integer'
        unless 'function' is typeof cb
            throw new Error 'cb argument must be a function'

        config.redis.eval lua.increment, 1,
            getBucketKey(config, name, Date.now()),
            increment,
            getExpire(config),
            cb

    incrementAndRead: (config, name, increment, cb) ->
        checkConfig config
        unless 'string' is typeof name
            throw new Error 'name argument must be a string'
        unless isInt increment
            throw new Error 'increment argument must be an integer'
        unless 'function' is typeof cb
            throw new Error 'cb argument must be a function'

        config.redis.eval lua.incrementAndRead, 2,
            getKey(config, name),
            getBucketKey(config, name, Date.now()),
            increment,
            getExpire(config),
            config.bucketCount,
            cb

    read: (config, name, cb) ->
        checkConfig config
        unless 'string' is typeof name
            throw new Error 'name argument must be a string'
        unless 'function' is typeof cb
            throw new Error 'cb argument must be a function'

        config.redis.eval lua.read, 1,
            getKey(config, name),
            config.bucketCount,
            cb
