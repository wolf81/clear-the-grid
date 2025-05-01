local floor = math.floor

local Projector = {}

Projector.new = function(virtual_w, virtual_h)
    local canvas = love.graphics.newCanvas(virtual_w, virtual_h)

    local scale = 1
    local ox, oy = 0, 0 -- offsets for letterboxing

    local resize = function(self, window_w, window_h)
        local sx, sy = window_w / virtual_w, window_h / virtual_h
        scale = math.min(sx, sy)

        ox = math.floor((window_w - virtual_w * scale) / 2)
        oy = math.floor((window_h - virtual_h * scale) / 2)
    end

    local attach = function(self)
        love.graphics.push() -- pop in detach()

        -- draw on canvas
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0) -- start with black canvas
        love.graphics.origin()
    end

    local detach = function(self)
        love.graphics.pop() -- push in attach()

        love.graphics.setCanvas() -- stop drawing to canvas
        love.graphics.clear(0, 0, 0) -- black letterbox

        -- render canvas to screen
        love.graphics.push()
        love.graphics.translate(ox, oy)
        love.graphics.scale(scale)
        love.graphics.draw(canvas)
        love.graphics.pop()
    end

    local toWorld = function(self, x, y)
        return floor(x * 1/scale), floor(y * 1/scale)
    end
    
    -- setup initial size
    resize(nil, love.graphics.getWidth(), love.graphics.getHeight())

    return setmetatable({
        resize  = resize,
        attach  = attach,
        detach  = detach,
        toWorld = toWorld,
    }, Projector)
end

return setmetatable(Projector, {
    __call = function(_, ...) return Projector.new(...) end,
})
