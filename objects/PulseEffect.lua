PulseEffect = GameObject:extend()

function PulseEffect:new(area, x, y, opts)
    PulseEffect.super.new(self, area, x, y, opts)

    self.line_width = opts.line_width or 2
    self.color = opts.color or colors.white

    self.w, self.h = self.parent.w, self.parent.h
    self.timer:tween(0.15, self, {w=self.w+20, h=self.h+20}, "in-out-cubic", function() self.dead = true end)

    self.polygons = {}
    self.polygons[1] = {
        -self.w/2, -self.h/2,
        self.w/2, -self.h/2,
        self.w/2, self.h/2,
        -self.w/2, self.h/2, 
    }
end

function PulseEffect:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setLineWidth(self.line_width)
    love.graphics.setColor(self.color)
    local points = fn.map(self.polygons[1], function(v, k) 
        if k % 2 == 1 then 
            return self.x + v + random(-1, 1) 
        else 
            return self.y + v + random(-1, 1) 
        end 
    end)
    love.graphics.polygon("line", points)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function PulseEffect:update(dt)
    PulseEffect.super.update(self, dt)

    self.polygons[1] = {
        -self.w/2, -self.h/2,
        self.w/2, -self.h/2,
        self.w/2, self.h/2,
        -self.w/2, self.h/2, 
    }

    if self.parent then self.x, self.y = self.parent.x, self.parent.y end 
end