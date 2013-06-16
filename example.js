var http = require('http');

var redis = require('redis');
var celerity = require('celerity');

var redisClient = redis.createClient();

var celerityConfig = {
    redis: redisClient,
    timespanMs: 10 * 1000,
    bucketCount: 10
};

var server = http.createServer(function(req, res) {
    // bounce favicon
    if (req.url == '/favicon.ico') {
        res.statusCode = 404;
        res.end();
        return
    }

    celerity.read(celerityConfig, 'requests', 1, function(err, rate) {
        if (err) {
            return res.end('there was an error');
        }

        if (rate > 10) {
            return res.end('whoa. you are going way too fast');
        }

        res.end(rate + ' requests in the last 10 seconds');
    });
});

server.listen(8080);

console.log('go to port 8080');
