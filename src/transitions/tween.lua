local pow, sin, M_PI = math.pow, math.sin, math.pi

local M = {}

M.linear = function(t) return t end

M.easeIn = function(t) return t * t end

M.easeOut = function(t) return t * (2 - t) end

M.easeInOut = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end

M.easeInElastic = function(t)
    local c4 = (2 * M_PI) / 3

    if t == 0 then
        return 0
    elseif t == 1 then
        return 1
    else
        return -pow(2, 10 * (t - 1)) * sin((t * 10 - 10.75) * c4)
    end
end

M.easeOutElastic = function(t)
    local c4 = (2 * M_PI) / 3

    if t == 0 then
        return 0
    elseif t == 1 then
        return 1
    else
        return pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1
    end
end

M.easeInOutElastic = function(t)
    local c5 = (2 * M_PI) / 4.5

    if t == 0 then
        return 0
    elseif t == 1 then
        return 1
    elseif t < 0.5 then
        return -(pow(2, 20 * t - 10) * sin((20 * t - 11.125) * c5)) / 2
    else
        return (pow(2, -20 * t + 10) * sin((20 * t - 11.125) * c5)) / 2 + 1
    end
end

return M
