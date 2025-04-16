local Solution = {}

Solution.new = function(moves)
    
    return setmetatable({

    }, Solution)
end

Solution.empty = function()
    return Solution({})
end

return setmetatable(Solution, {
    __call = function(_, ...) return Solution.new(...) end,
})
