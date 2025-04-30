local min = math.min

local CrossfadeTransition = {}

CrossfadeTransition.new = function(duration, from, to, finished)
    local time = 0.0
    local blend = 0.0

    local update = function(self, dt)
        time = min(time + dt, duration)
        blend = (time / duration)

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.setColor(1, 1, 1, 1.0 - blend)
        from:draw()

        love.graphics.setColor(1, 1, 1, blend)
        to:draw()
    end

    return setmetatable({
        draw    = draw,
        update  = update,
    }, CrossfadeTransition)
end

return setmetatable(CrossfadeTransition, {
    __call = function(_, ...) return CrossfadeTransition.new(...) end,
})
