local FontManager = {}

FontManager.new = function()
    local registry = {}

    local register = function(self, name, path, size)
        if registry[name] ~= nil then
            error(string.format('Font already registered: %s', name))
        end

        local info = love.filesystem.getInfo(path, 'file')
        if not info then
            error(string.format('File not found: %s', path))
        end

        registry[name] = love.graphics.newFont(path, size)
    end

    local get = function(self, name)
        local font = registry[name]
        
        if not font then 
            error(string.format('No font registered with name: %s', name))
        end

        return font 
    end
    
    return setmetatable({
        get         = get,
        register    = register,
    }, FontManager)
end

return setmetatable(FontManager, {
    __call = function(_, ...) return FontManager.new(...) end,
})
