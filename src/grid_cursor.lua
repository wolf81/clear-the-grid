local min, max, ceil, sin = math.min, math.max, math.ceil, math.sin

local CURSOR_COLOR = { 1.0, 0.2, 0.2 }

local GridCursor = {}

GridCursor.new = function(grid)
    local grid_w, grid_h = grid:getSize()

    -- at the start place a cursor near the center of the grid
    local x, y = ceil(grid_w / 2), ceil(grid_h / 2)

    -- align a pulsate animation with current time
    local time = 0

    -- styling for pulsate animation
    local scale, alpha = 1, 1

    local update = function(self, dt)
        time = time + dt

        -- scale cursor with time
        scale = 0.95 + 0.1 * sin(time * 2) -- 10% scale pulsation

        -- fade cursor in/out with time
        alpha = 0.4 + 0.6 * (0.5 + 0.5 * sin(time * 2))

        local input_manager = ServiceLocator.get(InputManager)

        if input_manager:isReleased('right', 'd') then
            x = min(max(x + 1, 1), grid_w)
        end

        if input_manager:isReleased('left', 'a') then
            x = min(max(x - 1, 1), grid_w)
        end

        if input_manager:isReleased('up', 'w') then
            y = min(max(y - 1, 1), grid_h)
        end

        if input_manager:isReleased('down', 's') then
            y = min(max(y + 1, 1), grid_h)
        end    
    end

    local draw = function(self)
        love.graphics.setColor(CURSOR_COLOR[1], CURSOR_COLOR[2], CURSOR_COLOR[3], alpha)

        -- push graphics state for scale and translation
        love.graphics.push()

        love.graphics.translate((x - 1) * GRID_SIZE + GRID_SIZE / 2, (y - 1) * GRID_SIZE + GRID_SIZE / 2)
        love.graphics.scale(scale)
        love.graphics.rectangle('line', -GRID_SIZE / 2, -GRID_SIZE / 2, GRID_SIZE, GRID_SIZE)

        -- revert scale and translation
        love.graphics.pop()
    end

    return setmetatable({
        draw    = draw,
        update  = update,
    }, GridCursor)
end

return setmetatable(GridCursor, {
    __call = function(_, ...) return GridCursor.new(...) end,
})
