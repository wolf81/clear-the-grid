local json = require 'lib.json.json'

local Juin = {}

local function getFont(font_info)
    local size = font_info.size or 20

    local font = love.graphics.getFont(size)
    if font_info.file ~= nil then
        font = love.graphics.newFont(font_info.file, size)
    end

    return font
end

-- left top right bottom
local function getMargin(...)
    local args = {...}

    local l, t, r, b = 0, 0, 0, 0

    if #args == 1 then
        l, t, r, b = args[1], args[1], args[1], args[1]
    elseif #args == 2 then
        l, t, r, b = args[1], args[2], args[1], args[2]
    elseif #args == 4 then
        l, t, r, b = unpack(args)
    else
        error(string.format('Invalid number of arguments: %d', #args))
    end

    return l, t, r, b
end

local hexToRgb = function(hex)
    local r, g, b, a = 255, 255, 255, 255

    if #hex == 7 then
        r, g, b = hex:match('^#(%x%x)(%x%x)(%x%x)')
    elseif #hex == 9 then
        r, g, b, a = hex:match('^#(%x%x)(%x%x)(%x%x)(%x%x)')
    else
        error('Failed to parse hex color.')
    end

    return { 
        tonumber(r, 16) / 255, 
        tonumber(g, 16) / 255, 
        tonumber(b, 16) / 255, 
        tonumber(a, 16) / 255,
    }
end

local createState = function(tbl)
    return {
        fg_color = hexToRgb(tbl.fg_color or '#ffffffff'), -- white
        bg_color = hexToRgb(tbl.bg_color or '#00000000'), -- transparent
    }
end

local createStates = function(tbl)
    local states = {}

    for state_name, state_info in pairs(tbl) do
        states[state_name] = createState(state_info)
    end

    if states['normal'] == nil then
        states['normal'] = createState({})
    end

    return states
end

local createLabel = function(tbl, toWorld)
    local x, y = unpack(tbl.pos)
    local w, h = 0, 0

    local window_w, window_h = love.window.getMode()
    if x <= 1.0 then
        x, y = toWorld(x * window_w, y * window_h)
    end

    local states = createStates(tbl.states or {})
    local state = 'normal'

    local font = getFont(tbl.font or {})
    local left, top, right, bottom = getMargin(unpack(tbl.margin or { 0 }))

    local text = tbl.text or ''
    w = font:getWidth(text)
    h = font:getHeight()
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

    return {
        z_index = tbl.z_index or 0,

        update = function(dt) end,

        setState = function(state_) state = state_ end,

        draw = function()
            love.graphics.push()
            love.graphics.translate(ox, oy)

            love.graphics.setColor(states[state].bg_color )
            love.graphics.rectangle('fill', x - left, y - top, w + left + right, h + top + bottom)

            love.graphics.setFont(font)
            love.graphics.setColor(states[state].fg_color)
            love.graphics.print(tbl.text or '', x, y)

            love.graphics.pop()
        end,
    }
end

local createImage = function(tbl, toWorld)
    local image = love.graphics.newImage(tbl.file)

    local x, y = unpack(tbl.pos)
    local w, h = image:getDimensions()
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

    local window_w, window_h = love.window.getMode()
    if x <= 1.0 then
        x, y = toWorld(x * window_w, y * window_h)
    end

    local states = createStates(tbl.states or {})
    local state = 'normal'

    return {
        z_index = tbl.z_index or 0,

        update = function(dt) end,

        setState = function(state_) state = state_ end,

        draw = function()
            love.graphics.push()

            love.graphics.translate(ox, oy)
            love.graphics.draw(image, x, y)
            
            love.graphics.pop()
        end,        
    }
end

local createButton = function(tbl, toWorld, opts)
    local x, y = unpack(tbl.pos)
    local w, h = 0, 0

    local window_w, window_h = love.window.getMode()
    if x <= 1.0 then
        x, y = toWorld(x * window_w, y * window_h)
    end

    local states = createStates(tbl.states or {})
    local state = 'normal'

    local font = getFont(tbl.font or {})
    local left, top, right, bottom = getMargin(unpack(tbl.margin or { 20, 10 }))

    local text = tbl.text or ''
    w = font:getWidth(text)
    h = font:getHeight()
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

    local action = function() print('click') end

    if tbl.click ~= nil then
        action = function() opts.screen[tbl.click]() end
    end

    return {
        z_index = tbl.z_index or 0,

        update = function(dt)
            local mx, my = toWorld(love.mouse.getPosition())
            local hovered = (
                mx > x - w / 2 - left and 
                mx < x + w / 2 + right and
                my > y - h / 2 - top and 
                my < y + h / 2 + bottom)
            local pressed = hovered and love.mouse.isDown(1)

            if hovered and not pressed and state == 'pressed' then
                action()
            end

            if pressed then
                state = 'pressed'
            elseif hovered then
                state = 'hovered'
            else
                state = 'normal'
            end
        end,

        setState = function(state_) state = state_ end,

        draw = function()
            love.graphics.push()
            love.graphics.translate(ox, oy)

            love.graphics.setColor(states[state].bg_color)
            love.graphics.rectangle('fill', x - left, y - top, w + left + right, h + top + bottom)

            love.graphics.setFont(font)
            love.graphics.setColor(states[state].fg_color)
            love.graphics.print(text, x, y)

            love.graphics.pop()
        end,        
    }
end

Juin.new = function(file, screen, toWorld)
    local contents, err = love.filesystem.read(file)
    if not contents then
        error(err)
    end

    local items = json.decode(contents)

    local controls = {}
    local control_info = {}

    -- map screen coords to world coords - used for determining mouse position
    toWorld = toWorld or function(x, y) return x, y end

    for idx, obj in ipairs(items) do
        if obj.type == 'label' then
            table.insert(controls, createLabel(obj, toWorld))
        elseif obj.type == 'button' then
            table.insert(controls, createButton(obj, toWorld, { 
                screen = screen, 
            }))
        elseif obj.type == 'image' then
            table.insert(controls, createImage(obj, toWorld))
        end

        if obj.id ~= nil then
            control_info[obj.id] = #controls
        end
    end

    -- sort by z-index, ensuring controls with a higher value appear on top
    table.sort(controls, function(a, b) return a.z_index < b.z_index end)

    local draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        for _, control in ipairs(controls) do
            control.draw()
        end
    end

    local update = function(self, dt) 
        for _, control in ipairs(controls) do
            control.update(dt)
        end
    end

    local getControl = function(self, id)
        local idx = control_info[id]
        if idx ~= nil then
            return controls[idx]
        end

        return nil
    end

    return setmetatable({
        draw        = draw,
        update      = update,
        toWorld     = toWorld,
        getControl  = getControl,
    }, Juin)
end

Juin.UI = function(file, screen, toWorld)
    return Juin(file, screen, toWorld)
end

return setmetatable(Juin, {
    __call = function(_, ...) return Juin.new(...) end,
})
