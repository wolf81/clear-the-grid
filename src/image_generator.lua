local M = {}

-- render to a texture of given width / height
M.render = function(w, h, func)
    local canvas = love.graphics.newCanvas(w, h)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 1)
    canvas:renderTo(func)
    love.graphics.setCanvas()

    local image_data = canvas:newImageData()

    image_data:encode('png', string.format('test-%d-%d.png', w, h))

    return love.graphics.newImage(image_data)
end

return M
