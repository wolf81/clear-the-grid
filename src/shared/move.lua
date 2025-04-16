local Move = {}

Move.new = function(x, y, direction, add)
    assert(x ~= nil, 'x is required')
    assert(y ~= nil, 'y is required')
    assert(direction ~= nil, 'direction is required')
    assert(add ~= nil, 'add is required')

    local unpack = function(self)
        return x, y, direction, add
    end

    local toString = function(self)
        return string.format('%s %s %s %s', x, y, direction, add == true and '+' or '-')
    end

    local clone = function(self)
        return Move(x, y, direction, add)
    end
    
    return setmetatable({
        clone       = clone,
        unpack      = unpack,
        toString    = toString,
    }, Move)
end

Move.__tostring = function(move)
    return move:toString()
end

Move.empty = function()
    return Move(1, 1, 'U', false)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
