local Game = {}

local M_PI_2 = math.pi / 2

local loadLevel = function(index)
    local path = string.format('dat/0XX/%d.txt', index)
    print(string.format('loading level: %s', path))

    local contents, bytes = lovr.filesystem.read(path, -1)
    return Map.parse(contents)
end 

Game.new = function()
    local map = loadLevel(1)
    print(map)
    local grid = map:getData()

    -- setup persective projection
    local width, height = lovr.system.getWindowDimensions()
    perspective = Mat4():perspective(math.rad(90), width/height, 1, 0)    

    -- setup camera position & target towards center of the grid
    local rows, cols = #grid, #grid[1]
    local target_x, target_z = cols / 2 * 1.1, -rows * 1.1

    local target = Vec3(target_x, 0, target_z)
    local position = Vec3(target.x, -8, target.z - 8)
    transform = Mat4():lookAt(position, target, vec3(0, 0, 1))

    local move = Move(1, 1, Direction('U'), false)
    print(move)

    -- Create a new thread called 'thread' using the code above
    local thread = lovr.thread.newThread('solver.lua')

    -- Create a channel for communication between threads
    local channel = lovr.thread.newChannel()

    -- Start the thread
    thread:start(channel, map:getData()) 

    local update = function(self, dt)
        local message = channel:pop()
        if message then
            print(message)    
        end
    end

    local draw = function(self, pass)
        pass:setProjection(1, perspective)
        pass:setViewPose(1, transform, true)

        local rows, cols = #grid, #grid[1]
        for row = 1, rows do
            for col = 1, cols do            
                local x, z = col * 1.1, (rows - row) * 1.1

                pass:setColor(0xff0000)
                pass:plane(x, 0, z - 10, 1, 1, -M_PI_2, 1, 0, 0)

                pass:setColor(0xffffff)
                pass:text(grid[row][col], x, -0.0001, z - 10, 1, M_PI_2, 1, 0, 0)
            end
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
