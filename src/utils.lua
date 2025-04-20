local gmatch, random = string.gmatch, math.random

local M = {}

-- generate a 2-dimensional array with value as default, or 0
M.newArray = function(length, value)
    local arr = {}

    for i = 1, length do
        arr[i] = value or 0
    end

    return arr
end

M.splitLines = function(str)
    local lines = {}
    for line in gmatch(str, '([^\n]+)') do
        table.insert(lines, line)
    end
    return lines
end

M.splitChars = function(str)
    local words = {}
    for word in gmatch(str, '%S+') do
        table.insert(words, word)
    end
    return words
end

return M
