local Game = require 'src.game'

local GameScreen = {}

GameScreen.new = function()
    local game = Game(1)

    local update = function(self, dt)
        game:update(dt)
    end

    local draw = function(self)
        game:draw()
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, GameScreen)
end

return setmetatable(GameScreen, {
    __call = function(_, ...) return GameScreen.new(...) end,
})
