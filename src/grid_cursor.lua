local min, max, ceil, cos, sin, sqrt    = math.min, math.max, math.ceil, math.cos, math.sin
local sqrt, atan2, band                 = math.sqrt, math.atan2, bit.band

local CURSOR_COLOR  = { 1.0, 0.2, 0.2 }
local BASE_SCALE    = 0.96 -- by default cursor is a little bit smaller than GRID_SIZE
local TRIANGLE_SIZE = ceil(GRID_SIZE / 4)

local STATES = { 
    default     = true, 
    highlight   = true,
}

local GridCursor = {}

local function drawDottedLine(x1, y1, x2, y2, dot_length, gap_length, offset)
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

local function drawDottedRectangleLoop(x, y, w, h, dot_length, gap_length, offset)
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

local function getValidDirs(grid, x, y)
    local dirs = {}

    for _, dir in ipairs({ Direction.L, Direction.R, Direction.U, Direction.D }) do
        local cx, cy = findPlayableCell(grid, x, y, dir)

        if cx == x and cy == y then goto continue end

        if grid:getValue(cx, cy) ~= 0 then
            dirs[dir] = { cx, cy }
        end

        ::continue::
    end
    
    return dirs
end

GridCursor.new = function(grid)
    local grid_w, grid_h = grid:getSize()

    -- at the start place a cursor near the center of the grid
    local x, y = ceil(grid_w / 2), ceil(grid_h / 2)

    -- the current control state
    local state = 'default'

    -- keep track of time for animations
    local time = 0.0

    -- optionally show direction pointers
    local dirs = 0

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

        if state == 'default' then
            dirs = 0

            if input_manager:isPressed('right', 'd') then
                x, y = findPlayableCell(grid, x, y, Direction.R)
            end

            if input_manager:isPressed('left', 'a') then
                x, y = findPlayableCell(grid, x, y, Direction.L)
            end

            if input_manager:isPressed('up', 'w') then
                x, y = findPlayableCell(grid, x, y, Direction.U)
            end

            if input_manager:isPressed('down', 's') then
                x, y = findPlayableCell(grid, x, y, Direction.D)
            end
        end

        if state == 'highlight' then
            local valid_dirs = getValidDirs(grid, x, y)

            if input_manager:isPressed('right', 'd') then
                if valid_dirs[Direction.R] then
                    dirs = Direction.R
                end
            end

            if input_manager:isPressed('left', 'a') then
                if valid_dirs[Direction.L] then
                    dirs = Direction.L
                end
            end

            if input_manager:isPressed('up', 'w') then
                if valid_dirs[Direction.U] then
                    dirs = Direction.U
                end
            end

            if input_manager:isPressed('down', 's') then
                if valid_dirs[Direction.D] then
                    dirs = Direction.D
                end
            end
        end

        if input_manager:isReleased('return') then
            if state == 'default' and grid:getValue(x, y) ~= 0 then
                self:setState('highlight')
            else
                self:setState('default')
            end
        end 

        if state == 'highlight' and input_manager:isReleased('escape') then
            self:setState('default')
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

        local rect_x, rect_y = -GRID_SIZE / 2, -GRID_SIZE / 2

        if state == 'default' then
            love.graphics.rectangle('line', rect_x, rect_y, GRID_SIZE, GRID_SIZE)
        else
            drawDottedRectangleLoop(rect_x, rect_y, GRID_SIZE, GRID_SIZE, 4, 6, time * 10)
        end

        if bit.band(dirs, Direction.U) == Direction.U then
            local x1, x2, x3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
            local y1, y2 = rect_y - TRIANGLE_SIZE, rect_y - 1
            love.graphics.polygon('fill', x1, y1, x2, y2, x3, y2)
        end

        if bit.band(dirs, Direction.D) == Direction.D then
            local x1, x2, x3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
            local y1, y2 = rect_y + GRID_SIZE + TRIANGLE_SIZE, rect_y + GRID_SIZE + 1
            love.graphics.polygon('fill', x1, y1, x2, y2, x3, y2)
        end

        if bit.band(dirs, Direction.L) == Direction.L then
            local x1, x2 = rect_x - TRIANGLE_SIZE, rect_x - 1
            local y1, y2, y3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
            love.graphics.polygon('fill', x1, y1, x2, y2, x2, y3)
        end

        if bit.band(dirs, Direction.R) == Direction.R then
            local x1, x2 = rect_x + GRID_SIZE + 1, rect_x + GRID_SIZE + TRIANGLE_SIZE
            local y1, y2, y3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
            love.graphics.polygon('fill', x2, y1, x1, y2, x1, y3)
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
    end

    local showDirs = function(self, dirs_)
        dirs_ = dirs_ or 0 -- don't show any directions if called without arguments

        if type(dirs_) ~= 'number' then
            error('Invalid dirs, should be a number composed for Direction flags.')
        end

        dirs = dirs_
    end

    return setmetatable({
        draw        = draw,
        update      = update,
        setState    = setState,
        showDirs    = showDirs,
    }, GridCursor)
end

return setmetatable(GridCursor, {
    __call = function(_, ...) return GridCursor.new(...) end,
})
