local key = KEYS[1]
local bucket_key = KEYS[2]
local n = ARGV[1]
local expire = ARGV[2]
local bucket_count = ARGV[3]

redis.call("INCRBY", bucket_key, n)
redis.call("PEXPIRE", bucket_key, expire)

local sum = 0

for i = 1, bucket_count do
    local full_key = key .. ":" .. tostring(i - 1)
    local bucket_value = redis.call("GET", full_key)
    if type(bucket_value) == 'string' then
        sum = sum + tonumber(bucket_value)
    end
end

return sum
