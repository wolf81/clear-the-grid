local floor = math.floor

local Projector = {}

Projector.new = function(virtual_w, virtual_h)
    local canvas = love.graphics.newCanvas(virtual_w, virtual_h)

    local transform = love.math.newTransform()

    local resize = function(self, window_w, window_h)
        transform:reset()

        local sx, sy = window_w / virtual_w, window_h / virtual_h
        transform:scale(sx, sy)

        local ox = floor((window_w - virtual_w * sx) / 2)
        local oy = floor((window_h - virtual_h * sy) / 2)
        transform:translate(ox, oy)
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
        love.graphics.applyTransform(transform)
        love.graphics.draw(canvas)
        love.graphics.pop()
    end

    local toWorld = function(self, x, y)
        return transform:inverseTransformPoint(x, y)
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
