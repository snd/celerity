local bucket_key = KEYS[1]
local n = ARGV[1]
local expire = ARGV[2]

redis.call("INCRBY", bucket_key, n)
redis.call("PEXPIRE", bucket_key, expire)
