local COLOR = { 1.0, 0.2, 0.2, 1.0 }

local PeekView = {}

PeekView.new = function(grid)
    local x, y, value, change = 0, 0, 0, 0

    local font_manager = ServiceLocator.get(FontManager)
    local font = font_manager:get('caption')
    local text_h = font:getHeight()

    local text = ''
    local text_x, text_y = 0, 0

    local active = false

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        if not active then return end

        love.graphics.push()

        love.graphics.setColor(COLOR)
        love.graphics.translate(-6, 0)
        love.graphics.setFont(font)
        love.graphics.print(text, text_x, text_y)

        love.graphics.pop()
    end

    local setMove = function(self, x_, y_, dir_, add_)
        local x, y, value, change = grid:peekMove(x_, y_, dir_, add_)

        if change == 0 then
            text = ''
        else
            text = change >= 0 and '+'..change or change
            local text_w = font:getWidth(text)

            text_x = x * GRID_SIZE - text_w
            text_y = (y - 1) * GRID_SIZE            
        end
    end

    local setActive = function(self, active_)
        active = active_
    end
    
    return setmetatable({
        draw        = draw,
        update      = update,
        setMove     = setMove,
        setActive   = setActive,
    }, PeekView)
end

return setmetatable(PeekView, {
    __call = function(_, ...) return PeekView.new(...) end,
})
