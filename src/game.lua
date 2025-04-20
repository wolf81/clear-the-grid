local Grid = require 'src.grid'
local Hud = require 'src.hud'

local Game = {}

local DELAY = 0.1

local loadLevel = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, bytes = lovr.filesystem.read(path, -1)
    return Map.parse(contents)
end 

Game.new = function()
    local map = loadLevel(15)
    print(map)

    local skybox_texture = lovr.graphics.newTexture({
        left    = 'gfx/neg_z.png',
        right   = 'gfx/neg_x.png',
        top     = 'gfx/pos_y.png',
        bottom  = 'gfx/neg_y.png',
        front   = 'gfx/pos_x.png',
        back    = 'gfx/pos_z.png'
    })

    local floor_material = lovr.graphics.newMaterial({
        texture = 'gfx/grass.jpg',
        uvScale = { 10, 10 },
    })

    -- a grid is a visual representation of a map
    local grid = Grid(map)

    local hud = Hud()
    hud:setLevel(15)

    local state = 'processing' -- 'done'

    -- setup perspective projection for showing grid
    local window_w, window_h = lovr.system.getWindowDimensions()
    local aspect = window_w / window_h
    local near, far = 1, 0
    local perspective = Mat4():perspective(math.rad(90), aspect, near, far)

    -- setup camera position & target towards center of the grid
    local cols, rows = map:getSize()
    local target = Vec3(0, 0, 0)
    local position = Vec3(target.x, 8, target.z - 4)
    transform = Mat4():lookAt(position, target, vec3(0, 0, 1))
    transform:rotate(math.pi, 0, 1, 0)

    -- Create a new thread called 'thread' using the code above
    local thread = lovr.thread.newThread('solver.lua')

    -- Create a channel for communication between threads
    local channel = lovr.thread.newChannel()

    -- Start the thread
    local map_w, map_h, map_data = map:unpack()
    thread:start(channel, {
        w = map_w,
        h = map_h,
        data = map_data
    }) 

    local delay = 0

    -- a list of moves when state == 'done' 
    local moves = {}

    local update = function(self, dt)
        delay = delay - dt

        if state == 'processing' then
            if delay < 0 then

                for i = 1, channel:getCount() do
                    local message = channel:pop()

                    if message.type == 'test' then
                        grid:addMove(Move(unpack(message.data)))
                        delay = 0
                    end

                    if message.type == 'done' then
                        -- show whole solution from start?
                        state = 'done'

                        for _, raw_move in ipairs(message.data) do
                            table.insert(moves, Move(unpack(raw_move)))
                        end

                        grid:setSolution(moves)
                        hud:setSolution(moves)

                        delay = 0.2
                    end
                end
            end
        else -- state == 'done'
            if delay < 0 then
                if #moves == 0 then
                    state = 'processing'
                else
                    map:applyMove(table.remove(moves, 1))
                end

                delay = 1.0
            end
        end

        while delay < 0 do
            delay = delay + DELAY
        end      

        grid:update(dt)  
        hud:update(dt)
    end

    local draw = function(self, pass)
        pass:setProjection(1, perspective)
        pass:setViewPose(1, transform, true)

        pass:skybox(skybox_texture)

        pass:setMaterial(floor_material)
        pass:circle(0, -1, 0, 10, -math.pi / 2, 1, 0, 0)
        pass:setMaterial()
                
        grid:draw(pass)
        hud:draw(pass)
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, Game)
end

return setmetatable(Game, {
    __call = function(_, ...) return Game.new(...) end,
})
