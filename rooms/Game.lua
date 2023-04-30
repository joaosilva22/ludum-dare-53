Game = Object:extend()

function Game:new()
    self.area = Area(self)
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.area:addGameObject("Conveyor", gw/2, gh/2)

    camera:fade(0.5, {0, 0, 0, 0}, function() self.running = true end)
end

function Game:update(dt)
    self.area:update(dt)
end

function Game:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach()
        self.area:draw()
        camera:detach()
        camera:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end