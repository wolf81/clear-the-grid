local MenuScreen = {}

MenuScreen.new = function()
    local ui = nil

    local loadContent = function(self)
        local projector = ServiceLocator.get(Projector)
        
        ui = juin.UI('dat/menu_screen.json', self, function(x, y)
            return projector:toWorld(x, y) 
        end)
    end

    local unloadContent = function(self) end

    local update = function(self, dt)
        ui:update(dt)
    end

    local draw = function(self)
        ui:draw()
    end

    local newGame = function(self)
        local screen_manager = ServiceLocator.get(ScreenManager)
        screen_manager:switch(GameScreen(), ZoomTransition, 1.5)
    end

    local quit = function(self)
        love.event.quit()
    end

    return setmetatable({
        draw            = draw,
        update          = update,
        loadContent     = loadContent,
        unloadContent   = unloadContent,
        -- button actions
        tutorial        = showTutorial,
        newGame         = newGame,
        quit            = quit,
    }, MenuScreen)
end

return setmetatable(MenuScreen, {
    __call = function(_, ...) return MenuScreen.new(...) end,
})
