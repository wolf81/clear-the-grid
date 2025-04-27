local min, max, ceil, sin = math.min, math.max, math.ceil, math.sin

local COLOR = { 1.0, 0.2, 0.2, 1.0 }
local SCALE = 0.96 -- by default cursor is a little bit smaller than GRID_SIZE

-- control states
local STATES = { 
    default     = true, 
    highlight   = true,
}

local GridCursor = {}

-- Converts a distance along the rectangle's perimeter to a coordinate
local function getPointOnRectPerimeter(x, y, w, h, dist)
    if dist < w then
        return x + dist, y
    elseif dist < w + h then
        return x + w, y + (dist - w)
    elseif dist < w + h + w then
        return x + w - (dist - w - h), y + h
    else
        return x, y + h - (dist - w - h - w)
    end
end

local function drawDashedRectangle(x, y, w, h, dash_length, gap_length, offset)
    local step = dash_length + gap_length
    local perimeter = 2 * (w + h)
    offset = offset % step

    for i = offset, perimeter, step do
        local a = i
        local b = min(i + dash_length, perimeter)

        -- Get coordinates along the path from a to b
        local ax, ay = getPointOnRectPerimeter(x, y, w, h, a)
        local bx, by = getPointOnRectPerimeter(x, y, w, h, b)
        love.graphics.line(ax, ay, bx, by)
    end
end

-- TODO: would be nicer to represent the non-0 values in the grid in a Graph
local function findPlayableCell(grid, x, y, dir)
    local w, h = grid:getSize()

    if dir == Direction.L then
        x = max(x - 1, 1)

        for x1 = x, 1, -1 do
            if grid:getValue(x1, y) ~= 0 then
                x = x1
                break
            end
        end
    end

    if dir == Direction.R then
        x = min(x + 1, w)

        for x1 = x, w do
            if grid:getValue(x1, y) ~= 0 then
                x = x1
                break
            end
        end
    end

    if dir == Direction.U then
        y = max(y - 1, 1)

        for y1 = y, 1, -1 do
            if grid:getValue(x, y1) ~= 0 then
                y = y1
                break
            end
        end
    end

    if dir == Direction.D then
        y = min(y + 1, h)

        for y1 = y, h do
            if grid:getValue(x, y1) ~= 0 then
                y = y1
                break
            end
        end
    end

    return x, y
end

GridCursor.new = function(grid)
    local grid_w, grid_h = grid:getSize()

    -- at the start place a cursor near the center of the grid
    local x, y = ceil(grid_w / 2), ceil(grid_h / 2)

    -- the current control state
    local state = 'default'

    -- a callback that is fired whenever the state has changed
    local onStateChanged = function() end

    -- a callback that is fired whenever the coord has changed
    local onCoordChanged = function() end

    -- keep track of time for animations
    local time = 0.0

    -- styling for default animation
    local alpha = 1.0

    local update = function(self, dt)
        time = time + dt        

        -- for default state us a pulse animation
        if state == 'default' then
            -- fade cursor in/out with time from 0.4 to 1.0
            alpha = 0.4 + 0.6 * (0.5 + 0.5 * sin(time * 2))            
        end

        local input_manager = ServiceLocator.get(InputManager)

        if state == 'default' then
            if input_manager:isPressed('right', 'd') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.R)
                self:setCoord(nx, ny)
            end

            if input_manager:isPressed('left', 'a') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.L)
                self:setCoord(nx, ny)
            end

            if input_manager:isPressed('up', 'w') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.U)
                self:setCoord(nx, ny)
            end

            if input_manager:isPressed('down', 's') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.D)
                self:setCoord(nx, ny)
            end
        end
    end

    local draw = function(self)
        love.graphics.setColor(COLOR[1], COLOR[2], COLOR[3], alpha)

        -- push graphics state for scale and translation
        love.graphics.push()

        love.graphics.translate(
            (x - 1) * GRID_SIZE + GRID_SIZE / 2, 
            (y - 1) * GRID_SIZE + GRID_SIZE / 2)
        love.graphics.scale(SCALE)

        local rect_x, rect_y = -GRID_SIZE / 2, -GRID_SIZE / 2

        if state == 'default' then
            love.graphics.rectangle('line', rect_x, rect_y, GRID_SIZE, GRID_SIZE)
        else
            drawDashedRectangle(rect_x, rect_y, GRID_SIZE, GRID_SIZE, 4, 6, time * 10)
        end

        -- revert scale and translation
        love.graphics.pop()
    end

    local setState = function(self, state_)
        if not STATES[state_] then            
            local valid_states = table.concat(Utils.getKeys(STATES), ', ')
            error(string.format('Invalid state %s, valid states are: %s', state_, valid_states))
        end

        state = state_

        if state == 'highlight' then
            scale, alpha = BASE_SCALE, 1.0
        end

        -- notify on state changes
        onStateChanged()
    end

    local getState = function(self)
        return state
    end

    local getCoord = function(self)
        return x, y
    end

    local setCoord = function(self, x_, y_)
        if x == x_ and y == y_ then return end

        x, y = x_, y_

        onCoordChanged(x, y)
    end

    local onStateChange = function(self, func)
        onStateChanged = func or function() end
    end

    local onCoordChange = function(self, func)
        onCoordChanged = func or function() end
    end

    return setmetatable({
        draw            = draw,
        update          = update,
        getState        = getState,
        setState        = setState,
        getCoord        = getCoord,
        setCoord        = setCoord,
        onStateChange   = onStateChange,
        onCoordChange   = onCoordChange,
    }, GridCursor)
end

return setmetatable(GridCursor, {
    __call = function(_, ...) return GridCursor.new(...) end,
})
