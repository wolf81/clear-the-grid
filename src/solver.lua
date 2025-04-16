local lovr = { 
    thread = require 'lovr.thread' 
}

local args = {...}

assert(#args == 1, 'Missing argument: map')

local map = args[1]

local channel = lovr.thread.getChannel('test')

local x = 0
while true do
    x = x + 1
    channel:push(x)
end
