GameOver = GameObject:extend()

function GameOver:new(area, x, y, opts)
    GameOver.super.new(self, area, x, y, opts)

    self.animated_text = nil
    slow(0.05, 5)

    self.score_x = -gw
    self.thank_x = gw
    self.space_x = -gw
    self.timer:after(0.05, function() self.timer:tween(0.05, self, {score_x=0}, "in-out-elastic") end)
    self.timer:after(0.10, function() self.timer:tween(0.05, self, {thank_x=0}, "in-out-elastic") end)
    self.timer:after(0.15, function() self.timer:tween(0.05, self, {space_x=0}, "in-out-elastic") end)

    self.opacity = 0
    local t1, t2
    t1 = function() self.timer:tween(1, self, {opacity=1}, "in-out-cubic", t2) end
    t2 = function() self.timer:tween(1, self, {opacity=0}, "in-out-cubic", t1) end
    t1()
end

function GameOver:update(dt)
    if self.animated_text == nil then
        self.animated_text = self.area:addGameObject("AnimatedText", gw/2, -50, {string="Game Over!", font_size=48})
        self.timer:tween(0.05, self.animated_text, {y=gh/2-40}, "in-out-elastic")
    end

    GameOver.super.update(self, dt)
end

function GameOver:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor({0,0,0,0.8})
    love.graphics.rectangle("fill", 0, 0, gw, gh)
    love.graphics.setColor(colors.white)
    love.graphics.printf("Score: 10238", self.score_x, gh/2, gw, "center")
    love.graphics.printf("Thank you for playing!", self.thank_x, gh/2+20, gw, "center")
    love.graphics.setColor({1, 1, 1, self.opacity})
    love.graphics.printf("Press space to play again", self.space_x, gh/2+60, gw, "center")
    love.graphics.setColor(colors.white)
    love.graphics.pop()
end