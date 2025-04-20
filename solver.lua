-- include any required LÖVR libraries as these are not 
-- loaded by default in thread code
local lovr = { 
    filesystem  = require 'lovr.filesystem',
    thread      = require 'lovr.thread',
    math        = require 'lovr.math',
}

local profile = require 'lib.profile.profile'

local abs = math.abs

require 'src.dependencies'

profile.start()

local args = {...}

-- the first argument should be a table with map_w, map_h, 
-- map_data as LÖVR can't send custom objects over channel
assert(#args == 2, 'Arguments required: channel & map_info')

local channel = args[1]

local function getHighValueCells(map)
    local cells = {}

    for x, y, value in map:iter() do
        -- TODO: should determine more dynamically
        if value > 5 then
            table.insert(cells, { x = x, y = y, value = value })
        end
    end

    table.sort(cells, function(a, b) return a.value > b.value end)

    return cells -- descending order
end

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

local function getReducersForCell(map, tx, ty)
    local reducers = {}

    for x, y, value in map:iter() do
        if value == 0 then goto continue end

        local dx = tx - x
        local dy = ty - y

        -- Same column
        if x == tx and math.abs(dy) == value then
            local dir = dy > 0 and 'D' or 'U'
            table.insert(reducers, { x, y, dir, true  })
            table.insert(reducers, { x, y, dir, false })
        end

        -- Same row
        if y == ty and math.abs(dx) == value then
            local dir = dx > 0 and 'R' or 'L'
            table.insert(reducers, { x, y, dir, true  })
            table.insert(reducers, { x, y, dir, false })
        end

        ::continue::
    end

    return reducers
end

local function getPrioritizedMoves(map)
    local moves = {}

    local seen = {}

    local function insertUnique(move)
        local key = move[1] .. "," .. move[2] .. "," .. move[3] .. "," .. (move[4] and '1' or '0')
        if not seen[key] then
            seen[key] = true
            table.insert(moves, move)
        end
  end

    for i, cell in ipairs(getHighValueCells(map)) do
        local reducers = getReducersForCell(map, cell.x, cell.y)
        for _, reducer in ipairs(reducers) do
            insertUnique(reducer)
        end
    end

    local valid_moves = getValidMoves(map)
    for _, move in ipairs(valid_moves) do
        insertUnique(move)
    end

    return valid_moves
end

local function playMoves(starting_map)
    local best_score = math.huge
    local best_moves = {}

    local stack = {
        {
            map = starting_map:clone(),
            moves = {},
            depth = 0,
        }
    }

    local visited = {}

    while #stack > 0 do
        local state = table.remove(stack)
        local map = state.map
        local moves = state.moves
        local depth = state.depth

        local key = map:getHash()
        if visited[key] then goto continue end
        visited[key] = true

        if max_depth and depth >= max_depth then goto continue end

        local valid_moves = getPrioritizedMoves(map)

        if #valid_moves == 0 then
            local score = map:getScore()

            if score < best_score then
                best_score = score
                best_moves = moves
                print(string.format('New best score: %d', best_score))
            end

            if score == 0 then
                print('Solution found!')
                break            
            end
        else
            for _, move in ipairs(valid_moves) do
                local new_map = map:clone()
                new_map:applyMove(unpack(move))

                local new_moves = { unpack(moves) }
                table.insert(new_moves, move)

                table.insert(stack, {
                    map = new_map,
                    moves = new_moves,
                    depth = depth + 1,
                })

                channel:push({
                    type = 'test',
                    data = move,
                })
            end
        end

        ::continue::
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
