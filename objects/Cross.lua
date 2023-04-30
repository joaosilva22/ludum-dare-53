Cross = GameObject:extend()

function Cross:new(area, x, y, opts)
    Cross.super.new(self, area, x, y, opts)

    self.color = colors.gray

    self.w, self.h = 10, 10
end

function Cross:update(dt)
    Cross.super.update(self, dt)
end

function Cross:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(4)
    love.graphics.line(self.x-self.w/2, self.y-self.h/2, self.x+self.w/2, self.y+self.h/2)
    love.graphics.line(self.x+self.w/2, self.y-self.h/2, self.x-self.w/2, self.y+self.h/2)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function Cross:activate()
    self.color = colors.red
    local t = function() self.timer:tween(0.15, self, {w=10, h=10}, "in-out-elastic") end
    self.timer:tween(0.15, self, {w=20, h=20}, "in-out-elastic", t)
end