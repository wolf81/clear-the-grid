local Grid = {}

Grid.new = function()
    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        -- body
    end

    return setmetatable({
        update      = update,
        draw        = draw,
    }, Grid)
end

return setmetatable(Grid, {
    __call = function(_, ...) return Grid.new(...) end,
})
