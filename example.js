var redis = require('redis');

var celerity = require('./src/celerity');

var redisClient = redis.createClient();

var config = {
    redis: redisClient,
    timespanMs: 10 * 1000,
    bucketCount: 10
};

celerity.incrementAndRead(config, 'test', 1, function(err, rate) {
    if (err) throw err;
    console.log(rate);
    redisClient.quit()
});
