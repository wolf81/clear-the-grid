require 'src.constants'
require 'src.dependencies'

local Game = require 'src.game'

-- show output while running
io.stdout:setvbuf('no')

local projector = Projector(VIRTUAL_W, VIRTUAL_H)
print(VIRTUAL_W, VIRTUAL_H)

local game = Game(1)

function love.load(args)

end

function love.resize(w, h)
    local w, h = love.graphics.getDimensions()
    projector:resize(w, h)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    projector:attach()    

    game:draw()

    projector:detach()
end

function love.keyreleased(key, scancode)
    if key == 'escape' then
        love.event.quit()
    end
end
