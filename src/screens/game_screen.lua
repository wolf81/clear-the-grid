local Board         = require 'src.ui.board'
local MoveList      = require 'src.ui.move_list'
local Cursor        = require 'src.ui.cursor'
local DirChooser    = require 'src.ui.dir_chooser'
local ResultView    = require 'src.ui.result_view'

local floor = math.floor

local GRID_COLOR = { 0.95, 0.95, 0.95, 1.0 }

local GameScreen = {}

local inRange = function(val, min, max)
    return val >= min and val <= max
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

local loadGrid = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, _ = love.filesystem.read(path, -1)
    
    local grid, err = ctg.parseGrid(contents)

    if err then
        error(err)
    end

    print(grid)

    return grid
end

GameScreen.new = function(level)
    level = level or 1
    local grid = loadGrid(level)

    local grid_w, grid_h = grid:getSize()

    -- draw a grid over the whole screen, visually like graph paper
    local background = newBackgroundImage()

    local input_mode = 'mouse' -- 'keyboard'

    local board         = Board(grid)       -- a grid in which each cell contains a number
    local cursor        = Cursor(grid)      -- an indicator for active cell
    local dir_chooser   = DirChooser(grid)  -- an indicator for possible directions
    local result_view   = ResultView(grid)  -- preview the result of a move
    local move_list     = MoveList(grid)

    local list_w, list_h    = move_list:getSize()
    local board_w, board_h  = board:getSize()

    local transform = love.math.newTransform()
    transform:translate((VIRTUAL_W - list_w - board_w) / 2, (VIRTUAL_H - board_h) / 2)

    -- a user can use mouse or keyboard navigation to move the cursor
    -- when clicking on the mouse button or return key, can toggle cursor highlight state
    -- when cursor is highlighted, possible directions are shown
    -- changing the active direction will show the result in the affected cell
    -- the move list will show past moves of the user

    -- local list_w, list_h = move_list:getSize()

    --[[
    board:onGridChange(function() 
        move_list:setMoves(grid:getMoves())

        if grid:isSolved() then
            local screen_manager = ServiceLocator.get(ScreenManager)
            Timer.after(0.5, function() 
                -- use random direction for slide transition
                local dirs = { 'up', 'down', 'left', 'right' }
                
                screen_manager:switch(GameScreen(level + 1), SlideTransition, 1.0, {
                    dir = dirs[math.random(#dirs)],
                    ease = 'easeInOut',
                })
            end)
        end
    end)
    --]]

    local loadContent = function(self) end

    local unloadContent = function(self) end

    local update = function(self, dt)
        board:update(dt)
        move_list:update(dt)

        local input_manager = ServiceLocator.get(InputManager)
        if input_manager:isReleased('r') then
            grid:revertMove()
            move_list:setMoves(grid:getMoves())
        end

        local mx, my = input_manager:getMouseState()
        mx, my = transform:inverse():transformPoint(mx, my)
        local cx = floor((mx + GRID_SIZE) / GRID_SIZE)
        local cy = floor((my + GRID_SIZE) / GRID_SIZE)
        cursor:setCoord(cx, cy)
    end

    local draw = function(self)
        love.graphics.draw(background)

        love.graphics.push()
        love.graphics.applyTransform(transform)
        -- local list_w, list_h = move_list:getSize()
        -- love.graphics.translate(-list_w / 2, 0)        
        board:draw()

        local cx, cy = cursor:getCoord()
        if inRange(cx, 1, grid_w) and inRange(cy, 1, grid_h) then
            cursor:draw()
        end

        love.graphics.pop()

        love.graphics.setColor(1, 1, 1, 1)
        move_list:draw()
    end
    
    return setmetatable({
        draw            = draw,
        update          = update,
        loadContent     = loadContent,
        unloadContent   = unloadContent,
    }, GameScreen)
end

return setmetatable(GameScreen, {
    __call = function(_, ...) return GameScreen.new(...) end,
})
