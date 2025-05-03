local tween = require 'src.transitions.tween'

local ScreenManager = {}

ScreenManager.new = function()
    local transition = nil

    local screen = {
        unloadContent   = function() end,
        loadContent     = function() end,
        update          = function() end,
        draw            = function() end,
    }

    local switch = function(self, screen_, T, duration, opts)        
        if getmetatable(screen) == getmetatable(screen_) then 
            if screen == screen_ then
                return 
            end
        end

        duration = duration or 0.5

        -- custom options table for a transition
        opts = opts or {}
        opts.ease = opts.ease or 'linear'
        if not tween[opts.ease] then
            error(string.format('Tween function does not exist: %s', opts.ease))
        end

        T = T or CrossfadeTransition

        screen_:loadContent()

        transition = transition_ or T(duration, screen, screen_, opts, function() 
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
