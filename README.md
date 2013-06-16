# celerity

[![Build Status](https://travis-ci.org/snd/celerity.png)](https://travis-ci.org/snd/celerity)

celerity uses redis to do centralized rate limiting for applications running
on multiple heroku dynos (or processes).

### install

```
npm install celerity
```

### example

[see example.js for a simple rate limited webserver using celerity](example.js)

### use

##### require

```javascript
var celerity = require('celerity');

var redis = require('redis');
```

##### configure

```javascript
var config = {
    redis: redis.createClient(),
    timespan: 10 * 1000,
    bucketCount: 10
};
```

celerity keeps the rate for the last `timespan` milliseconds.

`timespan` is divided into `bucketCount` buckets.
the rate is stored in the buckets.
buckets older than `timespan` expire every `timespan / bucketCount` milliseconds.

a higher `bucketCount` increases the frequency and accuracy of the expires
but uses more memory and results in slower read operations.
if `timespan` is several seconds long it is usually enough to have
a bucket for every second.

use the `prefix` property to set a prefix for all redis keys used by celerity.
the default prefix is `celerity:`.

##### increment(config, event, n, cb)

```javascript
celerity.increment(config, 'event', 1, function(err) {
    if (err) throw err

});
```

atomic. complexity: O(1).

##### read(config, event, cb)

```javascript
celerity.read(config, 'event', function(err, rate) {
    if (err) throw err
    console.log(rate);
});
```

atomic. complexity: O(n) where n is `bucketCount`.

##### incrementAndRead(config, event, n, cb)

```javascript
celerity.incrementAndRead(config, 'event', 1, function(err, rate) {
    if (err) throw err
    console.log(rate);
});
```

is atomic. complexity: O(n) where n is `bucketCount`.

### license: MIT
