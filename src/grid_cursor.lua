local min, max, ceil, cos, sin, sqrt    = math.min, math.max, math.ceil, math.cos, math.sin
local sqrt, atan2, band                 = math.sqrt, math.atan2, bit.band

local CURSOR_COLOR  = { 1.0, 0.2, 0.2, 1.0 }
local BASE_SCALE    = 0.96 -- by default cursor is a little bit smaller than GRID_SIZE
local TRIANGLE_SIZE = ceil(GRID_SIZE / 4)

-- control states
local STATES = { 
    default     = true, 
    highlight   = true,
}

-- map direction keys (as used in libctg) to Direction flags
local DIR_INFO = {
    L = Direction.L,
    R = Direction.R,
    U = Direction.U,
    D = Direction.D,
}

local GridCursor = {}

local function getDirName(dir)
    for dir_name, dir_value in pairs(DIR_INFO) do
        if dir == dir_value then return dir_name end
    end

    error(string.format('Invalid direction: %s', dir))
end

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
    local count = 0

    for dir_name, dir in pairs(DIR_INFO) do
        if grid:isValidMove(x, y, dir_name) then
            dirs[dir] = true
            count = count + 1
        end
    end
    
    return dirs, count
end

GridCursor.new = function(grid)
    local grid_w, grid_h = grid:getSize()

    -- at the start place a cursor near the center of the grid
    local x, y = ceil(grid_w / 2), ceil(grid_h / 2)

    -- the current control state
    local state = 'default'

    -- keep track of time for animations
    local time = 0.0

    -- the pointer direction or 0 to hide pointer
    local dir = 0

    -- possible directions for direction pointers
    local valid_dirs = {}

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
            dir = 0

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
            if input_manager:isPressed('right', 'd') then
                if valid_dirs[Direction.R] then
                    dir = Direction.R
                end
            end

            if input_manager:isPressed('left', 'a') then
                if valid_dirs[Direction.L] then
                    dir = Direction.L
                end
            end

            if input_manager:isPressed('up', 'w') then
                if valid_dirs[Direction.U] then
                    dir = Direction.U
                end
            end

            if input_manager:isPressed('down', 's') then
                if valid_dirs[Direction.D] then
                    dir = Direction.D
                end
            end
        end

        if input_manager:isReleased('return') then
            if state == 'default' and grid:getValue(x, y) ~= 0 then
                self:setState('highlight')

                valid_dirs, dir_count = getValidDirs(grid, x, y)

                if dir_count > 0 then
                    dir = next(valid_dirs)
                end
            else
                if dir ~= 0 then
                    grid:applyMove(x, y, getDirName(dir), false)
                end

                self:setState('default')

                valid_dirs = {}
            end
        end 

        if state == 'highlight' and input_manager:isReleased('escape') then
            self:setState('default')

            dir, valid_dirs = 0, {}
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

        for valid_dir in pairs(valid_dirs) do
            if dir == valid_dir then
                love.graphics.setColor(CURSOR_COLOR)
            else
                love.graphics.setColor(CURSOR_COLOR[1], CURSOR_COLOR[2], CURSOR_COLOR[3], 0.4)
            end

            if valid_dir == Direction.U then
                local x1, x2, x3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
                local y1, y2 = rect_y - TRIANGLE_SIZE, rect_y - 1
                love.graphics.polygon('fill', x1, y1, x2, y2, x3, y2)
            end

            if valid_dir == Direction.D then
                local x1, x2, x3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
                local y1, y2 = rect_y + GRID_SIZE + TRIANGLE_SIZE, rect_y + GRID_SIZE + 1
                love.graphics.polygon('fill', x1, y1, x2, y2, x3, y2)
            end

            if valid_dir == Direction.L then
                local x1, x2 = rect_x - TRIANGLE_SIZE, rect_x - 1
                local y1, y2, y3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
                love.graphics.polygon('fill', x1, y1, x2, y2, x2, y3)
            end

            if valid_dir == Direction.R then
                local x1, x2 = rect_x + GRID_SIZE + 1, rect_x + GRID_SIZE + TRIANGLE_SIZE
                local y1, y2, y3 = 0, -TRIANGLE_SIZE / 2, TRIANGLE_SIZE / 2
                love.graphics.polygon('fill', x2, y1, x1, y2, x1, y3)
            end
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

    return setmetatable({
        draw        = draw,
        update      = update,
        setState    = setState,
    }, GridCursor)
end

return setmetatable(GridCursor, {
    __call = function(_, ...) return GridCursor.new(...) end,
})
