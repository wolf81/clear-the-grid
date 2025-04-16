local Move = require 'shared.move'

-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    thread = require 'lovr.thread' 
}

local args = {...}

-- the first argument should be raw map data as it's 
-- not possible to send custom classes to a LÖVR thread
assert(#args == 1, 'Missing argument: map_data')

-- raw map data, since we cannot pass classes to threads
local map_data = args[1]

local function getMoves()
    local rows, cols = #map_data, #map_data[1]

    local moves = {}
    for i = 1, rows * cols do
        table.insert(moves, Move.empty())
    end

    return moves
end

local moves = getMoves()

-- the best score is 0, so start how, work downwards
local best_score = 999999

local done = false

while not done do

end

local channel = lovr.thread.getChannel('test')

local x = 0
while true do
    x = x + 1
    channel:push(x)
end
