local Grid = require 'src.grid'
local Hud = require 'src.hud'

local Game = {}

Game.new = function()
    local level = 1

    -- local map = loadLevel(level)

    -- a grid is a visual representation of a map
    local grid = Grid()

    local hud = Hud()

    local update = function(self, dt)
        grid:update(dt)
        hud:update()
    end

    local draw = function(self)
        grid:draw()
        hud:draw()
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, Game)
end

return setmetatable(Game, {
    __call = function(_, ...) return Game.new(...) end,
})
