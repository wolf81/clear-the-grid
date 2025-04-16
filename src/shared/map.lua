local Map = {}

local function generateMap(w, h)
    local data = {}

    for y = 1, h do
        data[y] = {}
        for x = 1, w do
            data[y][x] = 0
        end
    end

    return data
end

Map.new = function(w, h)
    local data = generateMap(w, h)

    local getSize = function()
        return w, h
    end
    
    return setmetatable({
        getSize = getSize,
    }, Map)
end

Map.parse = function(lines)
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
