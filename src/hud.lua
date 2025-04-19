local Hud = {}

Hud.new = function()
    local window_w, window_h = lovr.system.getWindowDimensions()

    -- setup orthographic projection for showing 'hud'
    local orthographic = Mat4():orthographic(window_w, window_h, -10, 10)
    local identity = Mat4():identity()

    local font = lovr.graphics.getDefaultFont()

    local solution = {}

    local level = 'Level 0'

    local update = function(self, dt)
        if #solution > 0 then
            local step = solution[1]

            step.delay = step.delay - dt

            if step.delay < 0 then
                table.remove(solution, 1)
            end
        end
    end  

    local draw = function(self, pass)
        font:setPixelDensity(1)

        pass:setProjection(1, orthographic)
        pass:setViewPose(1, identity)
        pass:setDepthTest()

        pass:setColor(1, 1, 1)

        pass:text(level, window_w / 2, 30, 0)

        if #solution > 0 then
            pass:text(solution[1].text, window_w / 2, window_h - 30, 0)
        end

        font:setPixelDensity()
    end

    local setSolution = function(self, moves)
        solution = {}

        for _, move in ipairs(moves) do
            table.insert(solution, {
                text = tostring(move),
                delay = 1.0,
            })
        end
    end

    local setLevel = function(self, index)
        level = string.format('Level %s', index)
    end

    return setmetatable({
        draw        = draw,
        update      = update,
        setSolution = setSolution,
        setLevel    = setLevel,
    }, Hud)
end

return setmetatable(Hud, {
    __call = function(_, ...) return Hud.new(...) end,
})
