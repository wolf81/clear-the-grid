local MenuScreen = {}

MenuScreen.new = function()
    local layout = nil

    local loadContent = function(self)
        local contents = love.filesystem.read('dat/menu_screen.json')
        layout = Layout(contents, self)
    end

    local unloadContent = function(self) end

    local update = function(self, dt)
        layout:update(dt)
    end

    local draw = function(self)
        layout:draw()
    end

    local newGame = function(self)
        local screen_manager = ServiceLocator.get(ScreenManager)
        screen_manager:switch(GameScreen())
    end

    return setmetatable({
        draw            = draw,
        update          = update,
        newGame         = newGame,
        loadContent     = loadContent,
        unloadContent   = unloadContent,
    }, MenuScreen)
end

return setmetatable(MenuScreen, {
    __call = function(_, ...) return MenuScreen.new(...) end,
})
