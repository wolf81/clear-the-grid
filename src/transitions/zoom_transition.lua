local min, abs, cos, M_PI = math.min, math.abs, math.cos, math.pi

local function easeOutQuad(t)
    return t * (2 - t)
end

local ZoomTransition = {}

ZoomTransition.new = function(duration, from, to, opts, finished)
    local time, alpha   = 0.0, 0.0
    local scale, rotate = 1.0, 0.0
    local ox, oy        = VIRTUAL_W / 2, VIRTUAL_H / 2

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
        -- the alpha value indicates the progress in transition
        alpha = easeOutQuad(time / duration)
        scale = abs(cos(alpha * M_PI)) -- use abs to make value stay in 0..1 range
        -- rotate is synced with scale
        rotate = scale * -M_PI

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.push()
        -- translate to the center, to scale & rotate from center point
        love.graphics.translate(ox, oy)
        -- negate scale to draw for left to right, top to bottom
        love.graphics.scale(-scale, -scale)
        -- rotate image
        love.graphics.rotate(rotate)

        -- on zoom out draw current screen, on zoom in draw next screen
        if alpha < 0.5 then
            love.graphics.draw(from_canvas, -ox, -oy, 0)
        else
            love.graphics.draw(to_canvas, -ox, -oy, 0)
        end

        love.graphics.pop()
    end

    return setmetatable({
        draw    = draw,
        update  = update,  
    }, ZoomTransition)
end

return setmetatable(ZoomTransition, {
    __call = function(_, ...) return ZoomTransition.new(...) end,
})
