local Move = {}

Move.new = function()
    
    return setmetatable({
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
