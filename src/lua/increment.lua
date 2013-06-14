redis.call("INCRBY", KEYS[1], ARGV[1])
redis.call("PEXPIRE", KEYS[1], ARGV[2])
