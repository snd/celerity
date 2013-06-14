var redis = require('redis');

var celerity = require('./src/celerity');

var redisClient = redis.createClient();

var oneMinuteMs = 60 * 1000

var config = {
    redis: redisClient,
    timespanMs: oneMinuteMs,
    bucketCount: 10
};

celerity.increment(config, 'test', 1, function(err) {
    if (err) throw err;
    celerity.read(config, 'test', function(err, count) {
        if (err) throw err;
        console.log(count);
        redisClient.quit()
    });
});
