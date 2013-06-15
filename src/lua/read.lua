local key = KEYS[1]
local bucket_count = ARGV[1]

local sum = 0

for i = 1, bucket_count do
    local full_key = key .. ":" .. tostring(i)
    local bucket_value = redis.call("GET", full_key)
    if type(bucket_value) == 'string' then
        sum = sum + tonumber(bucket_value)
    end
end

return sum
