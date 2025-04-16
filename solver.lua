-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    filesystem  = require 'lovr.filesystem',
    thread      = require 'lovr.thread',
    math        = require 'lovr.math',
}

require 'src.dependencies'

local rnd = lovr.math.newRandomGenerator()

local function getMoves(map)
    local rows, cols = map:getSize()

    local moves = {}
    for i = 1, rows * cols do
        table.insert(moves, Move.empty())
    end

    return moves
end

local isValidMove = function(map, move)
    local x, y, dir, add = move:unpack()
    local source_value = map:getValue(x, y)

    if source_value == 0 then 
        return false 
    end

    local dx, dy = Direction(dir):unpack()
    print(dx, dy)

    local tx = x + dx * source_value
    local ty = y + dy * source_value

    local w, h = map:getSize()
    if tx >= 1 and tx <= w and ty >= 1 and ty <= h then
        local target_value = map:getValue(tx, ty)
        if target_value == 0 then return false end
        return true
    end

    return false
end

local function getValidMoves(map)
    local moves = {}

    local w, h = map:getSize()

    local dirs = { 'U', 'D', 'L', 'R' }

    for y = 1, h do
        for x = 1, w do
            for _, dir in ipairs(dirs) do
                for i = 1, 2 do
                    local move = Move(x, y, dir, i == 1)

                    if isValidMove(map, move) then
                        table.insert(moves, move)
                    end
                end
            end
        end
    end

    print('moves', #moves)

    return moves
end

local function playMoves(map, moves)
    local actual_moves = {}

    -- don't mess up original map
    local local_map = map:clone()

    for _, move in ipairs(moves) do
        local actual_move = move

        if not isValidMove(local_map, actual_move) then
            local valid_moves = getValidMoves(local_map)

            if #valid_moves == 0 then break end

            actual_move = valid_moves[rnd:random(#valid_moves)]
        end

        local r = map:applyMove(actual_move)
        print(r)

        table.insert(actual_moves, actual_move:clone())
    end

    return local_map, actual_moves
end

local args = {...}

-- the first argument should be raw map data as it's 
-- not possible to send custom classes to a LÖVR thread
assert(#args == 1, 'Missing argument: map_data')

-- raw map data, since we cannot pass classes to threads
local map = Map(args[1])
local moves = getMoves(map)

playMoves(map, moves)

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
