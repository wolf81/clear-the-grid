local GridCursor = require 'src.grid_cursor'

local Board = {}

local FG_COLOR      = { 0.2, 0.2, 0.8, 1.0 }
local GRID_COLOR    = { 0.5, 0.5, 0.5, 1.0 }
local MARGIN_COLOR  = { 1.0, 0.2, 0.2, 1.0 }
local MARGIN_X      = 64

Board.new = function(grid)
    -- determine x and y offsets for drawing the grid
    local w, h = grid:getSize()
    local ox = math.floor((VIRTUAL_W - w * GRID_SIZE) / 2)
    local oy = math.floor((VIRTUAL_H - h * GRID_SIZE) / 2)

    local cursor = GridCursor(grid)

    -- set font
    local font = love.graphics.newFont('fnt/Kalam/Kalam-Bold.ttf', 24)
    local text_h = font:getHeight()

    local update = function(self, dt)
        cursor:update(dt)
    end

    local draw = function(self)
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

        -- reset color to white
        love.graphics.setColor(1, 1, 1, 1)
    end

    return setmetatable({
        update      = update,
        draw        = draw,
    }, Board)
end

return setmetatable(Board, {
    __call = function(_, ...) return Board.new(...) end,
})
