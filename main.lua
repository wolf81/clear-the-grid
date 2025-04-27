require 'src.constants'
require 'src.dependencies'

local Game = require 'src.game'

-- don't buffer output while app is running
-- this way we see immediate feedback in e.g. Sublime Text console - not after app is closed
io.stdout:setvbuf('no')

-- aspect fit a virtual view to the window
local projector = Projector(VIRTUAL_W, VIRTUAL_H)

-- keep track of user input
local input_manager = InputManager()

-- load fonts at the start of the game
local font_manager = FontManager()

local game = nil

function love.load(args)
    ServiceLocator.register(input_manager)

    font_manager:register('default', 'fnt/Kalam/Kalam-Bold.ttf', 24)
    font_manager:register('heading', 'fnt/Kalam/Kalam-Bold.ttf', 32)
    font_manager:register('caption', 'fnt/Kalam/Kalam-Bold.ttf', 20)

    ServiceLocator.register(font_manager)

    -- enable the OS sending repeated key presses while key is down
    love.keyboard.setKeyRepeat(true)

    game = Game(1)
end

function love.resize(w, h)
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
end

function love.keypressed(key, scancode, isrepeat)
    input_manager:keyPressed(key)
end
