fs = require 'fs'

module.exports =

    increment: fs.readFileSync(__dirname + '/lua/increment.lua', 'utf-8')
    read: fs.readFileSync(__dirname + '/lua/read.lua', 'utf-8')
    incrementAndRead: fs.readFileSync(__dirname + '/lua/increment-and-read.lua', 'utf-8')
    buckets: fs.readFileSync(__dirname + '/lua/buckets.lua', 'utf-8')
