require 'src.constants'
require 'src.dependencies'

-- don't buffer output while app is running
-- this way we see immediate feedback in e.g. Sublime Text console - not after app is closed
io.stdout:setvbuf('no')

-- aspect fit a virtual view to the window
local projector = Projector(VIRTUAL_W, VIRTUAL_H)

-- keep track of user input
local input_manager = InputManager(function(x, y) 
    return projector:toWorld(x, y)
end)

-- load fonts at the start of the game
local font_manager = FontManager()

-- handle display of current screen & screen transitions
local screen_manager = ScreenManager()

function love.load(args)
    -- registered as a service for screen coord transforms
    -- seems unclean - figure out a better approach
    ServiceLocator.register(projector)

    ServiceLocator.register(input_manager)

    font_manager:register('default', 'fnt/Kalam/Kalam-Bold.ttf', 24)
    font_manager:register('heading', 'fnt/Kalam/Kalam-Bold.ttf', 32)
    font_manager:register('caption', 'fnt/Kalam/Kalam-Bold.ttf', 20)

    ServiceLocator.register(font_manager)

    -- enable the OS sending repeated key presses while key is down
    love.keyboard.setKeyRepeat(true)

    screen_manager:switch(MenuScreen(), CrossfadeTransition, 0.25)
    ServiceLocator.register(screen_manager)
end

function love.resize(w, h)
    projector:resize(w, h)
end

function love.update(dt)
    Timer.update(dt)

    screen_manager:update(dt)

    input_manager:update(dt)
end

function love.draw()
    projector:attach()    

    screen_manager:draw()

    projector:detach()
end

function love.keyreleased(key, scancode)
    input_manager:keyReleased(key)
end

function love.keypressed(key, scancode, isrepeat)
    input_manager:keyPressed(key)
end
