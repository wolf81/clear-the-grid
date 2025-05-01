local InputManager = {}

InputManager.new = function(toWorld)
    toWorld = toWorld or function(x, y) return x, y end

    local pressed, released = {}, {}

    local update = function(self, dt)
        released = {}
        pressed = {}
    end

    local keyPressed = function(self, key) 
        pressed[key] = true
    end

    local keyReleased = function(self, key) 
        released[key] = true
    end

    local isPressed = function(self, ...)
        for _, key in ipairs({...}) do
            if pressed[key] then return true end
        end

        return false
    end

    local isReleased = function(self, ...)
        for _, key in ipairs({...}) do
            if released[key] then return true end
        end
        
        return false
    end

    local getMouseState = function(self)
        local mx, my = toWorld(love.mouse.getPosition())
        local is_down = love.mouse.isDown(1)
        return mx, my, is_down
    end
    
    return setmetatable({
        update          = update,
        isPressed       = isPressed,
        isReleased      = isReleased,
        keyPressed      = keyPressed,
        keyReleased     = keyReleased,
        getMouseState   = getMouseState,
    }, InputManager)
end

return setmetatable(InputManager, {
    __call = function(_, ...) return InputManager.new(...) end,
})
