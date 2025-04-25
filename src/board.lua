local Board = {}

local GRID_SIZE = 32
local GRID_COLOR = { 0.8, 0.8, 0.8, 1.0 }
local MARGIN_X = 64
local MARGIN_COLOR = { 1.0, 0.2, 0.2, 1.0 }

Board.new = function(grid)
    local w, h = grid:getSize()

    local ox = math.floor((VIRTUAL_W - w * GRID_SIZE) / 2)
    local oy = math.floor((VIRTUAL_H - h * GRID_SIZE) / 2)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        love.graphics.translate(ox, oy)
        love.graphics.setLineWidth(2)

        love.graphics.setColor(GRID_COLOR)

        for x = 0, w * GRID_SIZE, GRID_SIZE do
            love.graphics.line(x, 0, x, h * GRID_SIZE)            
        end

        for y = 0, h * GRID_SIZE, GRID_SIZE do
            love.graphics.line(0, y, w * GRID_SIZE, y)            
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
