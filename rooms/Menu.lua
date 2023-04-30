Menu = Object:extend()

function Menu:new()
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.area = Area(self)
    self.timer = Timer()

    self.area:addGameObject("AnimatedText", gw/2, gh/2-50, {string="Packing Panic!"})

    self.opacity = 0
    local t1, t2
    t1 = function() self.timer:tween(1, self, {opacity=1}, "in-out-cubic", t2) end
    t2 = function() self.timer:tween(1, self, {opacity=0}, "in-out-cubic", t1) end
    t1()
end

function Menu:update(dt)
    self.timer:update(dt)
    if input:pressed("space") then 
        camera:fade(0.5, {0, 0, 0, 1}, function() gotoRoom("Game") end)
    end
end

function Menu:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach()
        self.area:draw()

        love.graphics.setColor(colors.white)
        love.graphics.polygon("line", jitter({ 20, 35, 250, 35, 250, 235, 20, 235 }))

        love.graphics.printf("Ludum Dare 53", 40, 45, gw - 80, "center")
        love.graphics.printf("Put your sorting skills to the test!", 40, gh/2, gw-80, "center")
        love.graphics.printf("Use Q, W, O, and P to pack items into the correct boxes based on their shape and color.", 40, gh/2+30, gw-80, "center")

        love.graphics.setColor({1, 1, 1, self.opacity})
        love.graphics.printf("Press space to play", 40, 245, gw - 80, "center")
    camera:detach()
    camera:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end