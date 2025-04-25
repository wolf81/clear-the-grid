local InputManager = {}

InputManager.new = function()
    local pressed, released = {}, {}

    local update = function(self, dt)
        pressed = {}
        released = {}
    end

    local keyPressed = function(self, key) 
        pressed[key] = true
    end

    local keyReleased = function(self, key) 
        released[key] = true
    end

    local isPressed = function(self, key)
        return pressed[key] == true
    end

    local isReleased = function(self, key)
        return released[key] == true
    end
    
    return setmetatable({
        update      = update,
        isPressed   = isPressed,
        isReleased  = isReleased,
        keyPressed  = keyPressed,
        keyReleased = keyReleased,
    }, InputManager)
end

return setmetatable(InputManager, {
    __call = function(_, ...) return InputManager.new(...) end,
})
