local Board     = require 'src.board'
local MoveList  = require 'src.move_list'

local GRID_COLOR = { 0.97, 0.97, 0.97, 1.0 }

local Game = {}

local loadGrid = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, _ = love.filesystem.read(path, -1)
    
    local grid, err = ctg.parseGrid(contents) --> table: 0000000000A73540

    if err then
        error(err)
    end

    print(grid)

    return grid
end

local function newBackgroundImage()
    -- create a background image representing graph paper
    return ImageGenerator.render(VIRTUAL_W, VIRTUAL_H, function() 
        love.graphics.setLineWidth(1)
        love.graphics.setColor(GRID_COLOR)

        for x = -16, VIRTUAL_W, 32 do
            love.graphics.line(x, 0, x, VIRTUAL_H)            
        end

        for y = -16, VIRTUAL_H, 32 do
            love.graphics.line(0, y, VIRTUAL_W, y)            
        end
    end)
end 

Game.new = function()
    local level = 1

    local grid = loadGrid(level)

    -- draw a grid over the whole screen, visually like graph paper
    local background = newBackgroundImage()

    -- a board is a visual representation of a grid
    local board = Board(grid)

    local move_list = MoveList(grid)
    local list_w, list_h = move_list:getSize()

    board:onGridChange(function() 
        move_list:setMoves(grid:getMoves())

        if grid:isSolved() then
            -- TODO: load next level
        end
    end)

    local update = function(self, dt)
        board:update(dt)
        move_list:update(dt)
    end

    local draw = function(self)
        love.graphics.draw(background)        
        board:draw()
        move_list:draw()
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, Game)
end

return setmetatable(Game, {
    __call = function(_, ...) return Game.new(...) end,
})
