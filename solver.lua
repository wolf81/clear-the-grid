-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    filesystem  = require 'lovr.filesystem',
    thread      = require 'lovr.thread',
    math        = require 'lovr.math',
}

require 'src.dependencies'

local args = {...}

-- the first argument should be a table with map_w, map_h, 
-- map_data as LÖVR can't send custom objects over channel
assert(#args == 2, 'Arguments required: channel & map_info')

local channel = args[1]

local DIRS = { 'U', 'D', 'L', 'R' }

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
        if map:getValue(x, y) == 0 then goto continue end

        for _, dir in ipairs(DIRS) do
            for _, move in ipairs({ 
                Move(x, y, dir, true), 
                Move(x, y, dir, false)}) do

                local dx, dy = Direction(dir):unpack()
                local dx = x + dx * value
                local dy = y + dy * value
                if map:inBounds(dx, dy) and map:getValue(dx, dy) ~= 0 then
                    table.insert(moves, move)
                end

            end
        end

        ::continue::
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
                best_score = score
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
local map_info = args[2]
local map = Map(map_info.w, map_info.h, map_info.data)

local best_moves, best_score = playMoves(map)

local data = {}

for _, move in ipairs(best_moves) do
    print(move)
    table.insert(data, { move:unpack() })
end

channel:push({ type = 'done', data = data })
