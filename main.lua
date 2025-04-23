require 'src.constants'
require 'src.dependencies'

-- show output while running
io.stdout:setvbuf('no')

local projector = Projector(VIRTUAL_W, VIRTUAL_H)
print(VIRTUAL_W, VIRTUAL_H)

function love.load(args)

end

function love.resize(w, h)
    local w, h = love.graphics.getDimensions()
    projector:resize(w, h)
end

function love.update(dt)

end

function love.draw()
    projector:attach()    

    -- Your game drawing code
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', 0, 0, 2000, 2000)

    projector:detach()
end

function love.keyreleased(key, scancode)
    if key == 'escape' then
        love.event.quit()
    end
end
