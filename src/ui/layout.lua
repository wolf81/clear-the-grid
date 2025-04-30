local json = require 'lib.json.json'

local Layout = {}

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

local createLabel = function(tbl, font)
    local x, y = unpack(tbl.pos)
    local w, h = 0, 0

    local states = createStates(tbl.states or {})
    local state = 'normal'

    local text = tbl.text or ''
    w = font:getWidth(text) + 20
    h = font:getHeight() + 10
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

    return {
        z_index = tbl.z_index or 0,

        update = function(dt) end,

        setState = function(state_) state = state_ end,

        draw = function()
            love.graphics.push()
            love.graphics.translate(ox, oy)

            love.graphics.setColor(states[state].bg_color )
            love.graphics.rectangle('fill', x, y, w, h)

            love.graphics.setColor(states[state].fg_color)
            love.graphics.print(tbl.text or '', x, y)

            love.graphics.pop()
        end,
    }
end

local createImage = function(tbl)
    local image = love.graphics.newImage(tbl.file)

    local x, y = unpack(tbl.pos)
    local w, h = image:getDimensions()
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

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

local createButton = function(tbl, font, screen)
    local x, y = unpack(tbl.pos)
    local w, h = 0, 0

    local states = createStates(tbl.states or {})
    local state = 'normal'

    local text = tbl.text or ''
    w = font:getWidth(text) + 20
    h = font:getHeight() + 10
    local ox, oy = math.floor(-w / 2), math.floor(-h / 2)

    local action = function() print('click') end

    if tbl.click ~= nil then
        action = function() screen[tbl.click]() end
    end

    return {
        z_index = tbl.z_index or 0,

        update = function(dt)
            local mx, my = love.mouse.getPosition()
            local pressed = love.mouse.isDown(1)
            local hovered = (
                mx > x - w / 2 and 
                mx < x + w / 2 and
                my > y - h / 2 and 
                my < y + h / 2)

            if not pressed and state == 'pressed' then
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
            love.graphics.rectangle('fill', x, y, w, h)

            love.graphics.setColor(states[state].fg_color)
            love.graphics.print(text, x + 10, y + 5)

            love.graphics.pop()
        end,        
    }
end

Layout.new = function(file, screen)
    local items = json.decode(file)

    local controls = {}
    local control_info = {}

    -- TODO: should reset on leave?
    local font = love.graphics.getFont()

    for idx, obj in ipairs(items) do
        if obj.type == 'label' then
            table.insert(controls, createLabel(obj, font))
        elseif obj.type == 'button' then
            table.insert(controls, createButton(obj, font, screen))
        elseif obj.type == 'image' then
            table.insert(controls, createImage(obj))
        end

        if obj.id ~= nil then
            control_info[obj.id] = #controls
        end
    end

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
        getControl  = getControl,
        update      = update,
        draw        = draw,
    }, Layout)
end

return setmetatable(Layout, {
    __call = function(_, ...) return Layout.new(...) end,
})
