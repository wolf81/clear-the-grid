local WIDTH         = 300
local BORDER_COLOR  = { 1.0, 0.2, 0.2, 1.0 }
local TEXT_COLOR    = { 0.2, 0.2, 0.8, 1.0 }
local LINE_COLOR    = { 0.95, 0.95, 0.95, 1.0 }
local LINE_HEIGHT   = 48

local MoveList = {}

local function newBackgroundImage()
    local font_manager = ServiceLocator.get(FontManager)
    local heading_font = font_manager:get('heading')
    local heading = 'MOVES'
    local text_w = heading_font:getWidth(heading)
    local text_x = math.floor((WIDTH - text_w) / 2)
    local text_h = heading_font:getHeight()
    local text_y = LINE_HEIGHT + math.floor((LINE_HEIGHT - text_h) / 2)

    -- create a background image representing graph paper
    return ImageGenerator.render(WIDTH, VIRTUAL_H, function() 
        love.graphics.setLineWidth(1)
        love.graphics.setColor(LINE_COLOR)

        for y = LINE_HEIGHT * 2, VIRTUAL_H, LINE_HEIGHT do
            love.graphics.line(0, y, WIDTH, y)            
        end

        love.graphics.setLineWidth(4)
        love.graphics.line(0, LINE_HEIGHT * 2, WIDTH, LINE_HEIGHT * 2)

        love.graphics.setColor(TEXT_COLOR)
        love.graphics.setFont(heading_font)
        love.graphics.print(heading, text_x, text_y)

        love.graphics.setColor(BORDER_COLOR)
        love.graphics.setLineWidth(2)
        love.graphics.line(0, 0, 0, VIRTUAL_H)        
    end)
end 

MoveList.new = function()
    local moves = {}

    local background = newBackgroundImage()

    local font_manager = ServiceLocator.get(FontManager)
    local font = font_manager:get('heading')

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        love.graphics.push()

        love.graphics.translate(VIRTUAL_W - WIDTH, 0)

        love.graphics.draw(background)        

        love.graphics.setColor({ 0.7, 0.7, 0.7, 1.0 })
        love.graphics.setFont(font)

        love.graphics.translate(100, LINE_HEIGHT + 10)

        for i, move in ipairs(moves) do
            local x, y, dir, add = unpack(move)
            local text = string.format('%d %d %s %s', x, y, dir, add and '+' or '-')
            love.graphics.print(text, 0, i * LINE_HEIGHT - 4)
        end

        love.graphics.pop()

        love.graphics.setColor(1, 1, 1, 1)
    end

    local setMoves = function(self, moves_)
        moves = moves_
    end

    local getSize = function(self)
        return WIDTH, VIRTUAL_H
    end
    
    return setmetatable({
        draw        = draw,
        update      = update,
        getSize     = getSize,
        setMoves    = setMoves,
    }, MoveList)
end

return setmetatable(MoveList, {
    __call = function(_, ...) return MoveList.new(...) end,
})
