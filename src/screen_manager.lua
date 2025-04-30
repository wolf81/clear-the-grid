local CrossfadeTransition = require 'src.crossfade_transition'

local ScreenManager = {}

ScreenManager.new = function()
    local transition = nil

    local screen = {
        unloadContent   = function() end,
        loadContent     = function() end,
        update          = function() end,
        draw            = function() end,
    }

    local switch = function(self, screen_, transition_)
        if getmetatable(screen) == getmetatable(screen_) then return end

        screen_:loadContent()

        transition = transition_ or CrossfadeTransition(0.5, screen, screen_, function() 
            screen:unloadContent()
            transition = nil
        end)

        screen = screen_
    end
    
    local update = function(self, dt)
        if transition ~= nil then
            transition:update(dt)
        else
            screen:update(dt)
        end
    end

    local draw = function(self)
        if transition ~= nil then
            transition:draw()
        else
            screen:draw()
        end
    end

    return setmetatable({
        draw    = draw,
        update  = update,
        switch  = switch,
    }, ScreenManager)
end

return setmetatable(ScreenManager, {
    __call = function(_, ...) return ScreenManager.new(...) end,
})
