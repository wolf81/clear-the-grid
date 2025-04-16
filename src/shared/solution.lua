local Solution = {}

Solution.new = function()
    
    return setmetatable({
    }, Solution)
end

return setmetatable(Solution, {
    __call = function(_, ...) return Solution.new(...) end,
})
