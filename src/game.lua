local Game = {}

local M_PI_2 = math.pi / 2

local DELAY = 0.1

local loadLevel = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, bytes = lovr.filesystem.read(path, -1)
    return Map.parse(contents)
end 

Game.new = function()
    local map = loadLevel(1)
    print(map)

    -- setup persective projection
    local width, height = lovr.system.getWindowDimensions()
    perspective = Mat4():perspective(math.rad(90), width/height, 1, 0)    

    -- setup camera position & target towards center of the grid
    local cols, rows = map:getSize()
    local target_x, target_z = cols / 2 * 1.1, -rows * 1.1

    local target = Vec3(target_x, 0, target_z)
    local position = Vec3(target.x, -8, target.z - 8)
    transform = Mat4():lookAt(position, target, vec3(0, 0, 1))

    -- Create a new thread called 'thread' using the code above
    local thread = lovr.thread.newThread('solver.lua')

    -- Create a channel for communication between threads
    local channel = lovr.thread.newChannel()

    -- Start the thread
    thread:start(channel, map:getData()) 

    local delay = 0

    local move = Move.empty()

    local update = function(self, dt)
        delay = delay - dt

        if delay < 0 then
            local message = channel:pop()
            if message then
                move = Move(unpack(message))
            end
        end

        while delay < 0 do
            delay = delay + DELAY
        end
    end

    local draw = function(self, pass)
        pass:setProjection(1, perspective)
        pass:setViewPose(1, transform, true)

        local mx, my = move:unpack()

        local cols, rows = map:getSize()

        for col, row, value in map:iter() do
            local x, z = col * 1.1, (rows - row) * 1.1

            -- draw squares that visually seem like a grid
            pass:setColor(0xff0000)
            if my == row and mx == col then
                pass:setColor(0x00ff00)
            end
            pass:plane(x, 0, z - 10, 1, 1, -M_PI_2, 1, 0, 0)

            -- draw number values slightly above each square
            pass:setColor(0xffffff)
            pass:text(value, x, -0.0001, z - 10, 1, M_PI_2, 1, 0, 0)
        end
    end
    
    return setmetatable({
        draw    = draw,
        update  = update,
    }, Game)
end

return setmetatable(Game, {
    __call = function(_, ...) return Game.new(...) end,
})
