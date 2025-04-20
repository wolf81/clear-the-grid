-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    filesystem  = require 'lovr.filesystem',
    thread      = require 'lovr.thread',
    math        = require 'lovr.math',
}

local profile = require 'lib.profile.profile'
profile.start()

require 'src.dependencies'

local args = {...}

-- the first argument should be a table with map_w, map_h, 
-- map_data as LÖVR can't send custom objects over channel
assert(#args == 2, 'Arguments required: channel & map_info')

local channel = args[1]

local function getValidMoves(map)
    local moves = {}

    for x, y, value in map:iter() do
        if value == 0 then goto continue end

        for dir, dir_vector in pairs(Direction) do
            local dx = x + dir_vector[1] * value
            local dy = y + dir_vector[2] * value

            if map:getValue(dx, dy) ~= 0 then
                table.insert(moves, { x, y, dir, true  })
                table.insert(moves, { x, y, dir, false })
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
            local score = map:getScore()

            if score < best_score then
                best_score = score
                print(string.format('New highscore: %s', score))
            end

            if score == 0 then
                print('Solution found!')

                best_score = score
                best_moves = moves

                break
            end
        else
            for _, move in ipairs(valid_moves) do
                local new_map = map:clone()
                new_map:applyMove(unpack(move))

                channel:push({
                    type = 'test',
                    data = move,
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

profile.stop()
print(profile.report(20))

channel:push({ type = 'done', data = best_moves })
