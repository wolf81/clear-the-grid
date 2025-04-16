-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    filesystem  = require 'lovr.filesystem',
    thread      = require 'lovr.thread',
    math        = require 'lovr.math',
}

require 'src.dependencies'

local args = {...}

-- the first argument should be raw map data as it's 
-- not possible to send custom classes to a LÖVR thread
assert(#args == 2, 'Missing arguments: channel & map_data')

local channel = args[1]

local rnd = lovr.math.newRandomGenerator()

local DIRS = { 'U', 'D', 'L', 'R' }

local getMoves = function(map)
    local rows, cols = map:getSize()

    local moves = {}
    for i = 1, rows * cols do
        table.insert(moves, Move.empty())
    end

    return moves
end

local getMapScore = function(map)
    local result = 0

    local w, h = map:getSize()

    for x, y, value in map:iter() do
        if value > 0 then
            result = result + 1
        end
    end

    return result
end

local isValidMove = function(map, move)
    local x, y, dir, add = move:unpack()
    local source_value = map:getValue(x, y)

    if source_value == 0 then 
        return false 
    end

    local dx, dy = Direction(dir):unpack()
    local dx = x + dx * source_value
    local dy = y + dy * source_value

    local w, h = map:getSize()
    if dx >= 1 and dx <= w and dy >= 1 and dy <= h then
        local target_value = map:getValue(dx, dy)
        if target_value == 0 then return false end
        return true
    end

    return false
end

local function getValidMoves(map)
    local moves = {}

    local w, h = map:getSize()

    for x, y, value in map:iter() do
        for _, dir in ipairs(DIRS) do
            for i = 1, 2 do
                local move = Move(x, y, dir, i == 1)

                if isValidMove(map, move) then
                    table.insert(moves, move)
                end
            end
        end
    end

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

        channel:push({ actual_move:unpack() })

        local _ = local_map:applyMove(actual_move)

        table.insert(actual_moves, actual_move:clone())
    end

    return local_map, actual_moves
end

-- raw map data, since we cannot pass classes to threads
local map = Map(args[2])
local moves = getMoves(map)

-- the best score is 0, so start how, work downwards
local best_score = 999999

local done = false

while not done do
    local new_map, actual_moves = playMoves(map, moves)
    local new_score = getMapScore(new_map)
    if new_score < best_score then
        print(string.format('New highscore: %s', new_score))
        best_score = new_score

        for i = 1, #actual_moves do
            moves[i] = actual_moves[i]
        end
    end

    if new_score == 0 then
        print('Solution found!')
        done = true
    else
        moves[rnd:random(#moves)] = Move.empty()
    end
end
