local key = KEYS[1]
local bucket_count = ARGV[1]

local buckets = {}

for i = 1, bucket_count do
    local full_key = key .. ":" .. tostring(i - 1)
    local bucket_value = redis.call("GET", full_key)
    if type(bucket_value) == 'string' then
        buckets[i] = tonumber(bucket_value)
    else
        buckets[i] = 0
    end
end

return cjson.encode(buckets)
