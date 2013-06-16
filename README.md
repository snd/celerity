# celerity

[![Build Status](https://travis-ci.org/snd/celerity.png)](https://travis-ci.org/snd/celerity)

celerity tracks the rate of events by using redis.

it can be used to implement centralized rate limiting for web applications running
on multiple heroku dynos (or processes).

### install

```
npm install celerity
```

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
    timespanMs: 10 * 1000,
    bucketCount: 10
};
```

##### increment the rate whenever an event occurs

```javascript
celerity.increment(config, 'event', 1, function(err) {
    // ...
});
```

##### read the current rate

```javascript
celerity.read(config, 'event', function(err, rate) {
    console.log(rate);
});
```

### example

see [example.js](example.js) for a simple rate limited webserver.

### api

all operations are atomic within redis.

##### `celerity.increment(config, name, increment, function(err) {...})`

##### `celerity.read(config, name, function(err, rate) {...})`

##### `celerity.incrementAndRead(config, name, increment, function(err, rate) {...})`

### license: MIT
