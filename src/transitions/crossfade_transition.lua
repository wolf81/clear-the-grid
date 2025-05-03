local min = math.min

local CrossfadeTransition = {}

CrossfadeTransition.new = function(duration, from, to, opts, finished)
    local time = 0.0
    local alpha = 0.0

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
        alpha = (time / duration)

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.setColor(1, 1, 1, 1.0 - alpha)
        love.graphics.draw(from_canvas)

        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(to_canvas)

        love.graphics.setColor(1, 1, 1, 1)
    end

    return setmetatable({
        draw    = draw,
        update  = update,
    }, CrossfadeTransition)
end

return setmetatable(CrossfadeTransition, {
    __call = function(_, ...) return CrossfadeTransition.new(...) end,
})
