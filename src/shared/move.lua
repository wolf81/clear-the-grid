local Move = {}

Move.new = function(x, y, direction, add)
    assert(x ~= nil, 'x is required')
    assert(y ~= nil, 'y is required')
    assert(direction ~= nil, 'direction is required')
    assert(add ~= nil, 'add is required')

    local tostring = function(self)
        return string.format('%s %s %s %s', x, y, direction, add == true and '+' or '-')
    end
    
    return setmetatable({
        tostring = tostring,
    }, Move)
end

Move.__tostring = function(self)
    return self:tostring()
end

Move.empty = function(self)
    return Move(1, 1, 'U', false)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
