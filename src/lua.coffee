fs = require 'fs'

module.exports =

    increment: fs.readFileSync(__dirname + '/lua/increment.lua', 'utf-8')
    read: fs.readFileSync(__dirname + '/lua/read.lua', 'utf-8')
