local COLOR         = { 1.0, 0.2, 0.2, 1.0 }
local TRIANGLE_SIZE = math.ceil(GRID_SIZE / 4)

local DirectionChooser = {}

-- map direction keys (as used in libctg) to Direction flags
local DIR_INFO = {
    [Direction.L] = 'L',
    [Direction.R] = 'R',
    [Direction.U] = 'U',
    [Direction.D] = 'D',
}

local function getValidDirs(grid, x, y)
    local dirs = {}
    local count = 0

    for dir, dir_name in pairs(DIR_INFO) do
        if grid:isValidMove(x, y, dir_name) then
            dirs[dir] = true
            count = count + 1
        end
    end
    
    return dirs, count
end

DirectionChooser.new = function(grid)
    -- possible directions for the chooser
    local valid_dirs = {}

    -- the focused direction or 0 to hide chooser
    local dir = 0

    -- coord of the chooser
    local x, y = 0, 0

    -- whether the chooser is active - when active accepts input and is visible
    local active = false

    -- a callback that is invoked whenever the target direction changes
    local onDirectionChanged = function() end

    local update = function(self, dt)
        if not active then return end

        local input_manager = ServiceLocator.get(InputManager)

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

    local draw = function(self)
        if not active then return end

        local rect_x, rect_y = -GRID_SIZE / 2, -GRID_SIZE / 2

        love.graphics.push()
        love.graphics.translate(
            (x - 1) * GRID_SIZE + GRID_SIZE / 2, 
            (y - 1) * GRID_SIZE + GRID_SIZE / 2)

        for valid_dir in pairs(valid_dirs) do
            if dir == valid_dir then
                love.graphics.setColor(COLOR)
            else
                love.graphics.setColor(COLOR[1], COLOR[2], COLOR[3], 0.4)
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

        love.graphics.pop()
    end

    local setCoord = function(self, x_, y_)
        -- only update when coords have changed
        if x == x_ and y == y_ then return end

        x, y = x_, y_

        -- determine valid directions on coord change
        valid_dirs, dir_count = getValidDirs(grid, x, y)

        -- set active direction to first value in the table
        if dir_count > 0 then
            dir = next(valid_dirs)
        end        
    end

    local setActive = function(self, active_)
        active = active_
    end

    local getDirection = function(self)
        return dir
    end

    local onDirectionChange = function(self, func)
        onDirectionChanged = func or function() end
    end
    
    return setmetatable({
        draw                = draw,
        update              = update,
        setCoord            = setCoord,
        setActive           = setActive,
        getDirection        = getDirection,
        onDirectionChange   = onDirectionChange,
    }, DirectionChooser)
end

return setmetatable(DirectionChooser, {
    __call = function(_, ...) return DirectionChooser.new(...) end,
})
