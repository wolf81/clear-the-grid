local abs = math.abs

local Map = {}

Map.new = function(...)
    local args = {...}

    local w, h = 0, 0
    local data = {}

    if #args == 1 then
        assert(type(args[1]) == 'table', 'Invalid argument, table expected.')
        data = args[1]
        h = #data
        w = #data[1]
    end

    if #args == 2 then
        w, h = unpack(args)
        assert(type(w) == 'number', 'Invalid argument #1, number expected.')
        assert(type(h) == 'number', 'Invalid argument #2, number expected.')
        data = Utils.newArray(w, h, 0)
    end

    local getSize = function(self)
        return w, h
    end

    local getArea = function(self)
        return w * h
    end

    local getData = function(self) 
        return data 
    end

    local setData = function(self, data_)
        assert(type(data_) == 'table', 'Invalid type for data, should be a table.')
        assert(#data_ == h, 'Invalid data, number of rows is not equal to height.')
        assert(#data_[1] == w, 'Invalid data, number of columns is not equal to width.')

        data = data_
    end

    local clone = function(self)
        local map = Map(w, h)

        local copy = {}
        for y = 1, h do
            copy[y] = {}
            for x = 1, w do
                copy[y][x] = data[y][x]
            end
        end

        map:setData(copy)
        return map
    end

    local getValue = function(self, x, y)
        return data[y][x]
    end

    local applyMove = function(self, move)
        local x, y, dir, add = move:unpack()
        local source_value = data[y][x]

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

        if self:inBounds(dx, dy) then
            local target_value = data[dy][dx]
            if target_value == 0 then
                return string.format(
                    'The move %s is invalid. The destination cell %s,%s is empty.', 
                    move,
                    dx,
                    dy)
            end

            data[y][x] = 0
            if add then
                data[dy][dx] = data[dy][dx] + source_value
            else
                data[dy][dx] = abs(data[dy][dx] - source_value)
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
        local y = 1
        local x = 0

        return function()
            x = x + 1
            if x > w then
                x = 1
                y = y + 1
            end
            if y > h then
                return nil
            end
            return x, y, data[y][x]
        end
    end

    local inBounds = function(self, x, y)
        return x >= 1 and x <= w and y >= 1 and y <= h
    end

    return setmetatable({
        iter        = iter,
        clone       = clone,
        getSize     = getSize,
        getArea     = getArea,
        setData     = setData,
        getData     = getData,
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
    local map = Map(w, h)

    local data = {}

    for row = 1, h do
        table.insert(data, {})

        local line = lines[row + 1]
        chars = Utils.splitChars(line)

        for col, char in ipairs(chars) do
            data[row][col] = tonumber(char)
        end
    end

    map:setData(data)

    return map
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
