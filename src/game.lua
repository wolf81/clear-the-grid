local Board = require 'src.board'
local Hud = require 'src.hud'

local Game = {}

local loadGrid = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, _ = love.filesystem.read(path, -1)
    
    local grid, err = ctg.parseGrid(contents) --> table: 0000000000A73540

    if err then
        error(err)
    end

    -- TODO: the grid metatable should have a __tostring method
    -- from the C-side it's nicer if there is a toString method
    print(grid)

    return grid
end 

Game.new = function()
    local level = 1

    local grid = loadGrid(level)

    -- a board is a visual representation of a grid
    local board = Board(grid)

    local hud = Hud()

    local update = function(self, dt)
        board:update(dt)
        hud:update()
    end

    local draw = function(self)
        board:draw()

        hud:draw()
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, Game)
end

return setmetatable(Game, {
    __call = function(_, ...) return Game.new(...) end,
})
