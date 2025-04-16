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

Map.new = function(w, h)
    local data = generateMap(w, h)

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
        toString    = toString,
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

Map.__tostring = function(map)
    return map:toString()
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
