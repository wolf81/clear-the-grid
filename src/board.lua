local GridCursor        = require 'src.grid_cursor'
local DirectionChooser  = require 'src.direction_chooser'
local PeekView          = require 'src.peek_view'

local min, max, ceil, sin = math.min, math.max, math.ceil, math.sin

local FG_COLOR      = { 0.2, 0.2, 0.8, 1.0 }
local GRID_COLOR    = { 0.5, 0.5, 0.5, 1.0 }
local MARGIN_COLOR  = { 1.0, 0.2, 0.2, 1.0 }
local MARGIN_X      = 64

local DIR_INFO = {
    [Direction.U] = 'U',
    [Direction.D] = 'D',
    [Direction.L] = 'L',
    [Direction.R] = 'R',
}

local Board = {}

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

Board.new = function(grid)
    -- determine x and y offsets for drawing the grid
    local w, h = grid:getSize()
    local ox = math.floor((VIRTUAL_W - w * GRID_SIZE) / 2)
    local oy = math.floor((VIRTUAL_H - h * GRID_SIZE) / 2)

    local add = false

    local cursor        = GridCursor(grid)
    local dir_chooser   = DirectionChooser(grid)
    local peek_view     = PeekView(grid)

    -- callback
    local onGridChanged = function() end

    cursor:onStateChange(function() 
        dir_chooser:setActive(cursor:getState() == 'highlight')
        peek_view:setActive(cursor:getState() == 'highlight')
    end)

    cursor:onCoordChange(function()
        dir_chooser:setCoord(cursor:getCoord())
    end)

    dir_chooser:onDirectionChange(function() 
        local dir = dir_chooser:getDirection()
        if dir then
            local x, y = dir_chooser:getCoord()
            peek_view:setMove(x, y, DIR_INFO[dir], add)    
        end
    end)

    local font_manager = ServiceLocator.get(FontManager)
    local font = font_manager:get('default')
    local text_h = font:getHeight()

    local update = function(self, dt)
        cursor:update(dt)
        dir_chooser:update(dt)
        peek_view:update(dt)        

        local input_manager = ServiceLocator.get(InputManager)

        local cursor_state = cursor:getState()
        if cursor_state == 'highlight' then
            if input_manager:isReleased('return') then
                cursor:setState('default')

                local dir = dir_chooser:getDirection()
                if dir ~= 0 then
                    local x, y = cursor:getCoord()
                    grid:applyMove(x, y, DIR_INFO[dir], add)
                    onGridChanged()
                end
            end

            if input_manager:isReleased('escape') then
                cursor:setState('default')
            end

            if input_manager:isReleased('tab') then
                add = (not add)

                local dir = dir_chooser:getDirection()
                if dir then
                    local x, y = dir_chooser:getCoord()
                    peek_view:setMove(x, y, DIR_INFO[dir], add)    
                end
            end
        end    

        if cursor_state == 'default' then
            local x, y = cursor:getCoord()
            if input_manager:isPressed('right', 'd') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.R)
                cursor:setCoord(nx, ny)
            end

            if input_manager:isPressed('left', 'a') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.L)
                cursor:setCoord(nx, ny)
            end

            if input_manager:isPressed('up', 'w') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.U)
                cursor:setCoord(nx, ny)
            end

            if input_manager:isPressed('down', 's') then
                local nx, ny = findPlayableCell(grid, x, y, Direction.D)
                cursor:setCoord(nx, ny)
            end

            if input_manager:isReleased('r') then
                grid:revertMove()
                onGridChanged()
            end

            if input_manager:isReleased('return') then
                if grid:getValue(cursor:getCoord()) ~= 0 then
                    cursor:setState('highlight')
                end
            end
        end    
    end

    local draw = function(self)
        love.graphics.push()

        -- move grid to center of screen
        love.graphics.translate(ox, oy)

        -- draw grid lines
        do
            love.graphics.setLineWidth(2)
            love.graphics.setColor(GRID_COLOR)

            for x = 0, w * GRID_SIZE, GRID_SIZE do
                love.graphics.line(x, 0, x, h * GRID_SIZE)            
            end

            for y = 0, h * GRID_SIZE, GRID_SIZE do
                love.graphics.line(0, y, w * GRID_SIZE, y)            
            end
        end

        -- draw grid values
        do 
            love.graphics.setFont(font)

            -- push state, as we will translate by half a pixel, just for text rendering
            love.graphics.push()

            -- translate half a pixel for clearer font rendering
            love.graphics.translate(0.5, 0.5)

            for x, y, value in grid:iter() do
                if value == 0 then
                    love.graphics.setColor(0.7, 0.7, 0.7, 1.0)
                else
                    love.graphics.setColor(FG_COLOR)
                end

                local text = tostring(value)
                local text_w = font:getWidth(text)
                local text_x = (x - 1) * GRID_SIZE + (GRID_SIZE - text_w) / 2
                local text_y = (y - 1) * GRID_SIZE + (GRID_SIZE - text_h) / 2
                love.graphics.print(text, text_x, text_y)
            end

            -- pop back to previous state, reverting half pixel translation
            love.graphics.pop()
        end

        -- draw cursor
        cursor:draw()

        -- draw direction chooser
        dir_chooser:draw()

        -- draw the peek view
        peek_view:draw()

        -- reset color to white
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.pop()
    end

    local onGridChange = function(self, func)
        onGridChanged = func or function() end
    end

    return setmetatable({
        draw            = draw,
        update          = update,
        onGridChange    = onGridChange,
    }, Board)
end

return setmetatable(Board, {
    __call = function(_, ...) return Board.new(...) end,
})
