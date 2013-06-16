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

    var ip = req.connection.remoteAddress;

    celerity.incrementAndRead(celerityConfig, 'requests:' + ip, 1, function(err, rate) {
        if (err) {
            return res.end('there was an error');
        }

        if (rate > 10) {
            return res.end("slow down. you are going too fast");
        }

        res.end('there have been ' + rate + ' requests from your ip ' + ip + ' in the last 10 seconds');
    });
});

var port = process.argv[2] || 8080;

server.listen(port);

console.log('go to port ' + port);
