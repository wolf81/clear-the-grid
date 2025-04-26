local gmatch = string.gmatch

local M = {}

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

M.getKeys = function(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end

    return keys
end

return M
