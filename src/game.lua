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
    local map = loadLevel(15)
    print(map)

    local state = 'processing' -- 'done'

    -- setup persective projection
    local window_w, window_h = lovr.system.getWindowDimensions()
    local aspect = window_w / window_h
    local near, far = 1, 0
    perspective = Mat4():perspective(math.rad(90), aspect, near, far)    

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
    local map_w, map_h, map_data = map:unpack()
    thread:start(channel, {
        w = map_w,
        h = map_h,
        data = map_data
    }) 

    local delay = 0

    local move = Move.empty()

    -- a list of moves when state == 'done' 
    local moves = {}

    local update = function(self, dt)
        delay = delay - dt

        if state == 'processing' then
            if delay < 0 then

                for i = 1, channel:getCount() do
                    local message = channel:pop()

                    if message.type == 'test' then
                        move = Move(unpack(message.data))
                        delay = 0
                    end

                    if message.type == 'done' then
                        move = Move.empty()

                        -- show whole solution from start?
                        state = 'done'

                        for _, raw_move in ipairs(message.data) do
                            table.insert(moves, Move(unpack(raw_move)))
                        end

                        delay = 0.2
                    end
                end
            end
        else -- state == 'done'
            if delay < 0 then
                if #moves == 0 then
                    state = 'processing'
                else
                    local move = table.remove(moves, 1)
                    map:applyMove(move)
                end

                delay = 1.0
            end
        end

        while delay < 0 do
            delay = delay + DELAY
        end
    end

    local draw = function(self, pass)
        pass:setProjection(1, perspective)
        pass:setViewPose(1, transform, true)

        local mx, my = 0, 0
        if not move:isEmpty() then
            mx, my, dir, add = move:unpack()
        end

        local cols, rows = map:getSize()

        for col, row, value in map:iter() do
            local x, z = col * 1.1, (rows - row) * 1.1

            -- draw squares that visually seem like a grid
            pass:setColor(0x888899)
            if my == row and mx == col then
                pass:setColor(0xfff000)
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
