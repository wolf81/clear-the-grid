local Hud = {}

Hud.new = function()
    local update = function(self, dt)
        -- body
    end  

    local draw = function(self)
        -- body
    end

    return setmetatable({
        draw        = draw,
        update      = update,
    }, Hud)
end

return setmetatable(Hud, {
    __call = function(_, ...) return Hud.new(...) end,
})
