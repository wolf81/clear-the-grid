local min, max, ceil, cos, sin, sqrt    = math.min, math.max, math.ceil, math.cos, math.sin
local sqrt, atan2                       = math.sqrt, math.atan2

local CURSOR_COLOR = { 1.0, 0.2, 0.2 }
local BASE_SCALE = 0.96 -- by default cursor is a little bit smaller than GRID_SIZE

local STATES = { 
    default     = true, 
    highlight   = true,
}

local GridCursor = {}

function drawDottedLine(x1, y1, x2, y2, dot_length, gap_length, offset)
    local dx = x2 - x1
    local dy = y2 - y1
    local length = sqrt(dx * dx + dy * dy)
    local angle = atan2(dy, dx)
    local step = dot_length + gap_length

    offset = offset % step

    for i = offset, length, step do
        local startX = x1 + cos(angle) * i
        local startY = y1 + sin(angle) * i
        local endX = x1 + cos(angle) * min(i + dot_length, length)
        local endY = y1 + sin(angle) * min(i + dot_length, length)
        love.graphics.line(startX, startY, endX, endY)
    end
end

-- Converts a distance along the rectangle's perimeter to a coordinate
function getPointOnRectPerimeter(x, y, w, h, dist)
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

function drawDottedRectangleLoop(x, y, w, h, dot_length, gap_length, offset)
    local step = dot_length + gap_length
    local perimeter = 2 * (w + h)
    offset = offset % step

    for i = offset, perimeter, step do
        local a = i
        local b = min(i + dot_length, perimeter)

        -- Get coordinates along the path from a to b
        local ax, ay = getPointOnRectPerimeter(x, y, w, h, a)
        local bx, by = getPointOnRectPerimeter(x, y, w, h, b)
        love.graphics.line(ax, ay, bx, by)
    end
end

GridCursor.new = function(grid)
    local grid_w, grid_h = grid:getSize()

    -- at the start place a cursor near the center of the grid
    local x, y = ceil(grid_w / 2), ceil(grid_h / 2)

    -- the current control state
    local state = 'default'

    -- keep track of time for animations
    local time = 0.0

    -- styling for default animation
    local scale, alpha = BASE_SCALE, 1.0

    local update = function(self, dt)
        time = time + dt        

        -- for default state us a pulse animation
        if state == 'default' then
            -- scale cursor with time from 0.96 to 1.0
            scale = BASE_SCALE + 0.04 * sin(time * 2) 

            -- fade cursor in/out with time from 0.4 to 1.0
            alpha = 0.4 + 0.6 * (0.5 + 0.5 * sin(time * 2))            
        end

        local input_manager = ServiceLocator.get(InputManager)

        if input_manager:isPressed('right', 'd') then
            x = min(max(x + 1, 1), grid_w)
        end

        if input_manager:isPressed('left', 'a') then
            x = min(max(x - 1, 1), grid_w)
        end

        if input_manager:isPressed('up', 'w') then
            y = min(max(y - 1, 1), grid_h)
        end

        if input_manager:isPressed('down', 's') then
            y = min(max(y + 1, 1), grid_h)
        end    
    end

    local draw = function(self)
        love.graphics.setColor(CURSOR_COLOR[1], CURSOR_COLOR[2], CURSOR_COLOR[3], alpha)

        -- push graphics state for scale and translation
        love.graphics.push()

        love.graphics.translate(
            (x - 1) * GRID_SIZE + GRID_SIZE / 2, 
            (y - 1) * GRID_SIZE + GRID_SIZE / 2)
        love.graphics.scale(scale)

        if state == 'default' then
            love.graphics.rectangle('line', -GRID_SIZE / 2, -GRID_SIZE / 2, GRID_SIZE, GRID_SIZE)
        else
            drawDottedRectangleLoop(-GRID_SIZE / 2, -GRID_SIZE / 2, GRID_SIZE, GRID_SIZE, 4, 6, time * 10)
        end

        -- revert scale and translation
        love.graphics.pop()
    end

    local setState = function(self, state_)
        if not STATES[state_] then            
            local valid_states = table.concat(Utils.getKeys(STATES), ', ')
            error(string.format('Invalid state %s, valid states are: %s', state_, valid_states))
        end

        if state == 'highlight' then
            scale, alpha = BASE_SCALE, 1.0
        end

        state = state_
    end

    setState(nil, 'default')

    return setmetatable({
        draw        = draw,
        update      = update,
        setState    = setState,
    }, GridCursor)
end

return setmetatable(GridCursor, {
    __call = function(_, ...) return GridCursor.new(...) end,
})
