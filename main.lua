require 'src.constants'
require 'src.dependencies'

local Game = require 'src.game'

-- show output while running
io.stdout:setvbuf('no')

local projector = Projector(VIRTUAL_W, VIRTUAL_H)
print(VIRTUAL_W, VIRTUAL_H)

local input_manager = InputManager()

local game = Game(1)

function love.load(args)
    ServiceLocator.register(input_manager)
end

function love.resize(w, h)
    local w, h = love.graphics.getDimensions()
    projector:resize(w, h)
end

function love.update(dt)
    game:update(dt)

    input_manager:update(dt)
end

function love.draw()
    projector:attach()    

    game:draw()

    projector:detach()
end

function love.keyreleased(key, scancode)
    input_manager:keyReleased(key)

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keypressed(key, scancode, isrepeat)
    input_manager:keyPressed(key)
end
