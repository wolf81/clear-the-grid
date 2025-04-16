local Direction = {}

local VALID_DIRS = {
    U = {  0, -1 },
    D = {  0,  1 },
    L = { -1,  0 }, 
    R = {  1,  0 },
}

Direction.new = function(dir)
    assert(VALID_DIRS[dir], 
        'Invalid direction, should be one of \'U\', \'D\' \'L\' or \'R\'.')

    local dx, dy = unpack(VALID_DIRS[dir])

    local tostring = function(self)
        return dir
    end
    
    return setmetatable({
        tostring = tostring,
    }, Direction)
end

Direction.__tostring = function(self)
    return self:tostring()
end

return setmetatable(Direction, {
    __call = function(_, ...) return Direction.new(...) end,
})
