local Move = {}

Move.new = function(x, y, dir, add)
    assert(x ~= nil, 'x is required')
    assert(y ~= nil, 'y is required')
    assert(dir ~= nil, 'direction is required')
    assert(add ~= nil, 'add is required')

    local unpack = function(self)
        return x, y, dir, add
    end

    return setmetatable({
        unpack      = unpack,
    }, Move)
end

Move.__tostring = function(move)
    local x, y, dir, add = move:unpack()
    return string.format('%s %s %s %s', x, y, dir, add == true and '+' or '-')
end

Move.empty = function()
    return Move(1, 1, 'U', false)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
