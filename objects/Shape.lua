Shape = GameObject:extend()

function Shape:new(area, x, y, opts)
    Shape.super.new(self, area, x, y, opts)

    -- TODO: width, height, size, and wobble should be params
    self.w, self.h = opts.w or 40, opts.h or 40
    self.hl_w, self.hl_h = 1, 1
    self.r = 0
    self.active = false
    self.polygons = {}

    self.color = opts.color or colors.white
    self.shape = opts.shape or "Square"

    self:createPolygons()
    self:wobble()
end

function Shape:update(dt)
    Shape.super.update(self, dt)
    self:createPolygons()
end

function Shape:draw()
    pushRotate(self.x, self.y, self.r)

    if self.active then 
        love.graphics.setColor(colors.active)
        local points = fn.map(self.polygons[2], function(v, k) 
            if k % 2 == 1 then 
                return self.x + v + random(-1, 1) 
            else 
                return self.y + v + random(-1, 1) 
            end 
        end)
        love.graphics.setLineWidth(3)
        love.graphics.polygon("line", points)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor(self.color)
    local points = fn.map(self.polygons[1], function(v, k) 
        if k % 2 == 1 then 
            return self.x + v + random(-1, 1) 
        else 
            return self.y + v + random(-1, 1) 
        end 
    end)
    love.graphics.polygon("fill", points)

    love.graphics.pop()
end

function Shape:die()
    self.dead = true
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject("ExplodeParticle", self.x, self.y)
    end
    camera:shake(8, 1, 60)
    sounds.hurt:play()
end

function Shape:createPolygons()
    if self.shape == "Square" then
        self.polygons[1] = {
            -self.w/2, -self.h/2,
            self.w/2, -self.h/2,
            self.w/2, self.h/2,
            -self.w/2, self.h/2, 
        }
        self.polygons[2] = {
            -self.hl_w/2, -self.hl_h/2,
            self.hl_w/2, -self.hl_h/2,
            self.hl_w/2, self.hl_h/2,
            -self.hl_w/2, self.hl_h/2, 
        }
    end

    if self.shape == "Triangle" then
        self.polygons[1] = {
            0, -self.h/2,
            self.w/2, self.h/2,
            -self.w/2, self.h/2,
        }
        self.polygons[2] = {
            0, -self.hl_h/2,
            self.hl_w/2, self.hl_h/2,
            -self.hl_w/2, self.hl_h/2,
        }
    end

    if self.shape == "Circle" then
        local w1, w2 = math.atan(0.21), math.atan(0.72) -- magic values
        local radius = self.w / 2
	    local a = radius
	    local b = radius*math.sin(w1)
	    local c = radius*math.cos(w2)
	    local d = radius*math.sin(w2)
        self.polygons[1] = {
            a, b,  c, d,  d, c,  b, a, 
            -b, a, -d, c, -c, d, -a, b, 
            -a, -b, -c, -d, -d, -c, -b, -a, 
            b, -a,  d, -c,  c, -d,  a, -b
        }
        local radius1 = self.hl_w / 2
        local a1 = radius1
	    local b1 = radius1*math.sin(w1)
	    local c1 = radius1*math.cos(w2)
	    local d1 = radius1*math.sin(w2)
        self.polygons[2] = {
            a1, b1,  c1, d1,  d1, c1,  b1, a1, 
            -b1, a1, -d1, c1, -c1, d1, -a1, b1, 
            -a1, -b1, -c1, -d1, -d1, -c1, -b1, -a1, 
            b1, -a1,  d1, -c1,  c1, -d1,  a1, -b1
        }
    end
end

function Shape:wobble()
    local t1, t2 
    t1 = function() self.timer:tween(0.75, self, {r = 0-0.5}, "linear", t2) end
    t2 = function() self.timer:tween(0.75, self, {r = 0+0.5}, "linear", t1) end
    t1()
end

function Shape:activate()
    self.active = true

    local p1, p2
    p1 = function() self.timer:tween(0.25, self, {hl_w = 65, hl_h = 65}, "linear", p2) end
    p2 = function() self.timer:tween(0.25, self, {hl_w = 55, hl_h = 55}, "linear", p1) end

    self.timer:tween(0.25, self, {hl_w = 60, hl_h = 60}, "out-elastic", p1)
end

function Shape:flash()
    local old_color = self.color
    self.color = colors.red
    self.timer:after(0.15, function() self.color = old_color end)
    local p = function() self.timer:tween(0.15, self, {w=30, h=30}, "in-out-elastic") end
    self.timer:tween(0.15, self, {w=15, h=15}, "in-out-elastic", p) --, function() self.timer:tween(0.25, self, {w=60, h=60}, "in-out-elastic") end)
    camera:shake(8, 1, 60)
    sounds.hurt:play()
end

function Shape:pop()
    self.dead = true
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject("ExplodeParticle", self.x, self.y)
    end
end