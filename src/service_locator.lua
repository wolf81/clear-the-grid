local M = {}

local registry = {}

M.get = function(T)
    local service = registry[T]

    if not service then
        error('No service registered with requested metatable.')
    end

    return registry[T] 
end

M.register = function(service)
    local mt = getmetatable(service)

    if mt == nil then
        error('Can only register a service with a metatable.')
    end

    if registry[mt] ~= nil then
        error('A service was already registered with the same metatable.')
    end

    registry[mt] = service
end

return M
