local M = {}

-- generate a 2-dimensional array with value as default, or 0
M.newArray = function(w, h, value)
    local arr = {}

    for y = 1, h do
        arr[y] = {}
        for x = 1, w do
            arr[y][x] = value or 0
        end
    end

    return arr
end

M.splitLines = function(str)
    local lines = {}
    for line in string.gmatch(str, '([^\n]+)') do
        table.insert(lines, line)
    end
    return lines
end

M.splitChars = function(str)
    local words = {}
    for word in string.gmatch(str, '%S+') do
        table.insert(words, word)
    end
    return words
end

return M
