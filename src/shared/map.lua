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
        local i = (y - 1) * w + x
        return data[i]
    end

    local applyMove = function(self, move)
        local x, y, dir, add = move:unpack()
        local i = (y - 1) * w + x
        local source_value = data[i]

        if source_value == 0 then
            return string.format(
                'The move %s is invalid. The source cell %s,%s is empty.', 
                move, 
                x, 
                y)
        end

        local dx, dy = Direction(dir):unpack()
        local dx = x + dx * source_value
        local dy = y + dy * source_value
        local di = (dy - 1) * w + dx

        if self:inBounds(dx, dy) then
            local target_value = data[di]
            if target_value == 0 then
                return string.format(
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

            return ''
        end

        return string.format(
            'The move %s is invalid. The destination cell %s,%s is outside the grid boundaries.', 
            move, 
            dx, 
            dy)
    end

    local isSolved = function(self)
        for _, _, value in self:iter() do
            if value ~= 0 then return false end
        end

        return true
    end

    local iter = function(self)
        local i = 0

        return function()
            i = i + 1

            if i > #data then return nil end

            local x, y = i % w, ceil(i / w)

            return x + 1, y, data[i]
        end
    end

    local inBounds = function(self, x, y)
        return x >= 1 and x <= w and y >= 1 and y <= h
    end

    return setmetatable({
        iter        = iter,
        clone       = clone,
        unpack      = unpack,
        getSize     = getSize,
        getArea     = getArea,
        getData     = getData,
        getHash     = getHash,
        inBounds    = inBounds,
        getValue    = getValue,
        toString    = toString,
        isSolved    = isSolved,
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
