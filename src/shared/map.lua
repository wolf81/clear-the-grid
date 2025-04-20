local abs, ceil = math.abs, math.ceil

local Map = {}

Map.new = function(w, h, data)
    if not data then
        data = Utils.newArray(w * h, 0)
    else
        assert(type(data) == 'table', 'Invalid type for data, should be a table.')
        assert(#data == w * h, 'Invalid data, length not equal to map size.')
        -- clone the data
        data = { unpack(data) }
    end

    local score = 0

    for i = 1, #data do
        if data[i] ~= 0 then score = score + 1 end
    end

    local hash = nil

    local getHash = function(self)
        if not hash then
            -- a very simple hash method, but guaranteed no collisions
            hash = string.format('%d.%d.%s', w, h, table.concat(data))
        end

        return hash
    end

    local getSize = function(self)
        return w, h
    end

    local getArea = function(self)
        return #data
    end

    local getData = function(self) 
        return data 
    end

    local clone = function(self)
        return Map(w, h, data)
    end

    local unpack = function(self)
        return w, h, data
    end

    local getValue = function(self, x, y)
        if x < 1 or x > w or y < 1 or y > h then return 0 end

        local i = (y - 1) * w + x

        return data[i]
    end

    local applyMove = function(self, move)
        local x, y, dir, add = move:unpack()
        local i = (y - 1) * w + x
        local source_value = data[i]

        if source_value == 0 then
            return false, string.format(
                'The move %s is invalid. The source cell %s,%s is empty.', 
                move, 
                x, 
                y)
        end

        local dx, dy = Direction(dir):unpack()
        local dx = x + dx * source_value
        local dy = y + dy * source_value
        local di = (dy - 1) * w + dx

        -- don't allow moves to cells containing 0
        if data[di] == 0 then
            return false, string.format(
                'The move %s is invalid. The destination cell %s,%s is empty.', 
                move,
                dx,
                dy)
        end

        data[i] = 0

        if add then
            data[di] = data[di] + source_value
        else
            data[di] = abs(data[di] - source_value)
        end

        -- adjust score for updated cells
        score = score - 1
        if data[di] == 0 then
            score = score - 1
        end

        return true
    end

    local getScore = function(self)
        return score
    end

    local iter = function(self)
        local i = 0

        return function()
            i = i + 1

            if i > #data then return nil end

            local x, y = (i - 1) % w + 1, ceil(i / w)

            return x, y, data[i]
        end
    end

    return setmetatable({
        iter        = iter,
        clone       = clone,
        unpack      = unpack,
        getSize     = getSize,
        getArea     = getArea,
        getData     = getData,
        getHash     = getHash,
        getValue    = getValue,
        toString    = toString,
        getScore    = getScore,
        applyMove   = applyMove,
    }, Map)
end

Map.parse = function(contents)
    local lines = Utils.splitLines(contents)
    local chars = Utils.splitChars(lines[1])

    local w, h = tonumber(chars[1]), tonumber(chars[2])
    local data = {}

    for row = 1, h do
        local line = lines[row + 1]
        chars = Utils.splitChars(line)

        for _, char in ipairs(chars) do
            table.insert(data, tonumber(char))
        end
    end

    return Map(w, h, data)
end

Map.__tostring = function(map)
    local s = ''

    local w, _ = map:getSize()

    for x, y, value in map:iter() do
        s = s .. value .. ' '
        if x == w then s = s .. '\n' end
    end

    return string.gsub(s, '%s+$', '')
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
