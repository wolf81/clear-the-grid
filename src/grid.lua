local max, min, bor, lshift = math.max, math.min, bit.bor, bit.lshift

local M_PI_2 = math.pi / 2

local Grid = {}

local vertex = [[
    vec4 lovrmain() {
        return DefaultPosition;
    }
]]

local fragment = [[
    Constants {
        vec4 blendColor;
        float blendAmount;
    };

    vec4 lovrmain() {
        vec4 color = DefaultColor;
        return mix(color, blendColor, blendAmount);
    }
]]

local function getKey(x, y)
    return bor(lshift(x, 16), y)
end

Grid.new = function(map)
    local shader = lovr.graphics.newShader(vertex, fragment)

    local rows, cols = map:getSize()

    local ox, oz = -(rows * 1.1 / 2) * 1.1, -(cols * 1.1)

    -- currently active moves
    local moves = {}

    local solution = {}

    for col, row, _ in map:iter() do
        moves[getKey(col, row)] = {
            value = 0.0,
            dir = 0,
        }
    end

    local update = function(self, dt)
        for key, info in pairs(moves) do
            if info.dir == 1 then
                moves[key].value = min(info.value + dt * 2, 1.0)

                if info.value == 1 then
                    info.dir = -1
                end
            elseif info.dir == -1 then                
                moves[key].value = max(info.value - dt * 2, 0)

                if info.value == 0 then
                    info.dir = 0
                end
            end
        end

        if #solution > 0 then
            local move = solution[1]
            move.delay = move.delay - dt

            local from_x, from_y = unpack(move.from)
            local from_key = getKey(from_x, from_y)

            local to_x, to_y = unpack(move.to)
            local to_key = getKey(to_x, to_y)

            if move.delay < 0 then
                table.remove(solution, 1)
                moves[from_key].value = 0.0
                moves[to_key].value = 0.0
            else
                moves[from_key].value = 1.0
                moves[to_key].value = 1.0                
            end
        end
    end

    local draw = function(self, pass)
        pass:push()
        pass:translate(ox, 0, oz)

        for col, row, value in map:iter() do
            local x, z = col * 1.1, (rows - row) * 1.1

            pass:setShader(shader)

            -- draw squares that visually seem like a grid
            pass:setColor(0.5, 0.5, 0.4, 1.0)

            local info = moves[getKey(col, row)]
            pass:send('blendColor', { 1.0, 0.5, 1.0, 1.0 })
            pass:send('blendAmount', info.value)
            pass:plane(x, 0, z, 1, 1, -M_PI_2, 1, 0, 0)

            pass:setShader()

            -- draw number values slightly above each square
            pass:setColor(0xffffff)
            pass:text(value, x, 0.0001, z, 1, -M_PI_2, 1, 0, 0)
        end

        pass:pop()
    end

    local addMove = function(self, move)
        local x, y = move:unpack()
        moves[getKey(x, y)].dir = 1.0
    end

    local setSolution = function(self, moves)
        solution = {}

        for _, move in ipairs(moves) do
            -- local from_x, from_y, dir, _ = move:unpack()
            -- local value = map:getValue(from_x, from_y)
            -- local dx, dy = Direction(dir):unpack()
            -- local to_x, to_y = from_x + dx * value, from_y + dy * value
            -- print(from_x, from_y, to_x, to_y, value)

            -- table.insert(solution, {
            --     from    = { from_x, from_y },
            --     to      = { to_x, to_y },
            --     delay   = 1.0,
            -- })
        end
    end

    return setmetatable({
        setSolution = setSolution,
        addMove     = addMove,
        update      = update,
        draw        = draw,
    }, Grid)
end

return setmetatable(Grid, {
    __call = function(_, ...) return Grid.new(...) end,
})
