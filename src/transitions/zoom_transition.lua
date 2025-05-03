local min = math.min

local function easeOutQuad(t)
    return t * (2 - t)
end

local ZoomTransition = {}

ZoomTransition.new = function(duration, from, to, finished)
    local time = 0.0
    local ox = 0
    local scale = 1.0
    local blend = 0

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
        scale = math.abs(math.cos(time / duration * math.pi))

        ox = - blend * VIRTUAL_W

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local ox = VIRTUAL_W / 2 - (VIRTUAL_W * scale) / 2
        local oy = VIRTUAL_H / 2 - (VIRTUAL_H * scale) / 2

        if blend < 0.5 then
            love.graphics.draw(from_canvas, ox, oy, 0, scale, scale)
        else
            love.graphics.draw(to_canvas, ox, oy, 0, scale, scale)
        end
    end

    return setmetatable({
        draw    = draw,
        update  = update,  
    }, ZoomTransition)
end

return setmetatable(ZoomTransition, {
    __call = function(_, ...) return ZoomTransition.new(...) end,
})
