local abs = math.abs

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

function splitLines(str)
    local lines = {}
    for line in string.gmatch(str, "([^\n]+)") do
        table.insert(lines, line)
    end
    return lines
end

function splitChars(str)
    local words = {}
    for word in string.gmatch(str, "%S+") do
        table.insert(words, word)
    end
    return words
end

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
        data = generateMap(w, h)
    end

    local getSize = function(self)
        return w, h
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
        map:setData(data)
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

        if dx >= 1 and dx <= w and dy >= 1 and dy <= h then
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

        return string.format('The move %s is invalid. The destination cell %s,%s is outside the grid boundaries.', move, tx, ty)
    end

    local isSolved = function(self)
        for y = 1, h do
            for x = 1, w do
                if data[y][x] ~= 0 then 
                    return false 
                end
            end
        end

        return true
    end

    local toString = function(self)
        local s = ''

        for y = 1, h do
            for x = 1, w do
                s = s .. data[y][x] .. ' '
            end
            s = s .. '\n'
        end

        return string.gsub(s, '%s+$', '')
    end

    return setmetatable({
        clone       = clone,
        getSize     = getSize,
        setData     = setData,
        getData     = getData,
        encode      = encode,
        decode      = decode,
        getValue    = getValue,
        toString    = toString,
        applyMove   = applyMove,
        isSolved    = isSolved,
    }, Map)
end

Map.parse = function(contents)
    local lines = splitLines(contents)
    local chars = splitChars(lines[1])
    local w, h = tonumber(chars[1]), tonumber(chars[2])
    local map = Map(w, h)

    local data = {}

    for row = 1, h do
        table.insert(data, {})

        local line = lines[row + 1]
        chars = splitChars(line)

        for col, char in ipairs(chars) do
            data[row][col] = tonumber(char)
        end
    end

    map:setData(data)

    return map
end

Map.decode = function(map)
    return map:decode()
end

Map.__tostring = function(map)
    return map:toString()
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
