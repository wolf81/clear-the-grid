local min = math.min

local SlideTransition = {}

local function easeOutQuad(t)
    return t * (2 - t)
end

SlideTransition.new = function(duration, from, to, finished)
    local time = 0.0
    local ox = 0

    love.graphics.setColor(1, 1, 1, 1)

    local from_canvas = love.graphics.newCanvas(VIRTUAL_W, VIRTUAL_H)
    love.graphics.setCanvas(from_canvas)
    from:draw()

    love.graphics.setColor(1, 1, 1, 1)
    local to_canvas = love.graphics.newCanvas(VIRTUAL_W, VIRTUAL_H)
    love.graphics.setCanvas(to_canvas)
    to:draw()

    love.graphics.setCanvas()

    local update = function(self, dt)
        time = min(time + dt, duration)
        blend = easeOutQuad(time / duration)

        ox = - blend * VIRTUAL_W

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.push()
        love.graphics.translate(ox, 0)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(from_canvas)
        love.graphics.draw(to_canvas, VIRTUAL_W)

        love.graphics.pop()
    end

    return setmetatable({
        draw    = draw,
        update  = update,    
    }, SlideTransition)
end

return setmetatable(SlideTransition, {
    __call = function(_, ...) return SlideTransition.new(...) end,
})
