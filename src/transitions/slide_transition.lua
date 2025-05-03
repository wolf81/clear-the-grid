local min = math.min

local SlideTransition = {}

local DIRS = { 
    left    = { -1,  0 },
    right   = {  1,  0 },
    up      = {  0, -1 },
    down    = {  0,  1 },
}

local function easeOutQuad(t)
    return t * (2 - t)
end

SlideTransition.new = function(duration, from, to, opts, finished)
    local time, alpha   = 0.0, 0.0
    local ox, oy        = 0, 0

    -- the dir key can be used to set animation direction, e.g. { dir = 'left' }
    local dir = opts.dir or 'left'
    if DIRS[dir] == nil then
        error('Invalid direction, valid options are: left, right, up & down')
    end
    local dx, dy = unpack(DIRS[dir])

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

        alpha = time / duration
        ox = dx * easeOutQuad(alpha) * VIRTUAL_W
        oy = dy * easeOutQuad(alpha) * VIRTUAL_H

        -- TODO: this will prevent the last frame from drawing - is that an issue?
        if time == duration then finished() end    
    end

    local draw = function(self)
        love.graphics.push()
        love.graphics.translate(ox, oy)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(from_canvas)
        love.graphics.draw(to_canvas, -dx * VIRTUAL_W, -dy * VIRTUAL_H)

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
