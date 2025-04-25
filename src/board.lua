local Board = {}

local BG_COLOR = { 0.99, 0.99, 0.99, 1.0 }
local GRID_SIZE = 48
local GRID_COLOR = { 0.6, 0.6, 0.6, 1.0 }
local MARGIN_X = 64
local MARGIN_COLOR = { 1.0, 0.2, 0.2, 1.0 }

Board.new = function(grid)
    -- determine x and y offsets for drawing the grid
    local w, h = grid:getSize()
    local ox = math.floor((VIRTUAL_W - w * GRID_SIZE) / 2)
    local oy = math.floor((VIRTUAL_H - h * GRID_SIZE) / 2)

    -- set font
    local font = love.graphics.newFont('fnt/Kalam/Kalam-Bold.ttf', 18)
    local text_h = font:getHeight()

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        -- set background color
        love.graphics.clear(BG_COLOR)

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

            -- translate half a pixel for clearer font rendering
            love.graphics.translate(0.5, 0.5)

            for x, y, value in grid:iter() do
                local text = tostring(value)
                local text_w = font:getWidth(text)
                local text_x = (x - 1) * GRID_SIZE + (GRID_SIZE - text_w) / 2
                local text_y = (y - 1) * GRID_SIZE + (GRID_SIZE - text_h) / 2
                love.graphics.print(text, text_x, text_y)
            end
        end
    end

    return setmetatable({
        update      = update,
        draw        = draw,
    }, Board)
end

return setmetatable(Board, {
    __call = function(_, ...) return Board.new(...) end,
})
