local M = {}

M.render = function(w, h, func)
    local canvas = love.graphics.newCanvas(w, h)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 1)
    canvas:renderTo(func)
    love.graphics.setCanvas()

    local image_data = canvas:newImageData()

    return love.graphics.newImage(image_data)
end

return M
