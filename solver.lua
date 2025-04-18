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

local rng = lovr.math.newRandomGenerator()

local DIRS = { 'U', 'D', 'L', 'R' }

local getMoves = function(map)
    local moves = {}

    for i = 1, map:getArea() do
        table.insert(moves, Move.empty())
    end

    return moves
end

local evaluateMap = function(map)
    local result = 0

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

    if map:inBounds(dx, dy) then
        return map:getValue(dx, dy) ~= 0
    end

    return false
end

local function getValidMoves(map)
    local moves = {}

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

local function playMoves(starting_map)
    local best_score = math.huge
    local best_moves = {}

    local stack = {
        {
            map = starting_map:clone(),
            moves = {},
        }
    }

    while #stack > 0 do
        local state = table.remove(stack)
        local map = state.map
        local moves = state.moves

        local valid_moves = getValidMoves(map)

        if #valid_moves == 0 then
            -- Terminal state: evaluate the map
            local score = evaluateMap(map)

            if score < best_score then
                print(string.format('New highscore: %s', score))
            end

            if score == 0 then
                print('Solution found!')

                best_score = score
                best_moves = { unpack(moves) }

                break
            end
        else
            for _, move in ipairs(valid_moves) do
                local new_map = map:clone()
                new_map:applyMove(move)

                channel:push({
                    type = 'test',
                    data = { move:unpack() },
                })

                local new_moves = { unpack(moves) }
                table.insert(new_moves, move)

                table.insert(stack, {
                    map = new_map,
                    moves = new_moves,
                })
            end
        end
    end

    return best_moves, best_score
end

-- generate a new Map from raw map data in arguments
local map = Map(args[2])

-- get all moves in the map, one for every coord
local moves = getMoves(map)

-- the best score is 0, so start how, work downwards
local best_score = 999999

local done = false

while true do
    if not done then
    local best_moves, best_score = playMoves(map)

    local data = {}

    for _, move in ipairs(best_moves) do
        print(move)
        table.insert(data, { move:unpack() })
    end

    channel:push({ type = 'done', data = data })
done = true
    end
end
