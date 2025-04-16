require 'src.dependencies'

local Game = require 'src.game'

-- show output while running
io.stdout:setvbuf('no')

function lovr.load(args)
    game = Game()
end

function lovr.update(dt)
    game:update(dt)
end

function lovr.draw(pass)
    game:draw(pass)
end

function lovr.keyreleased(key, scancode)
    if key == 'escape' then
        lovr.event.quit()
    end
end
