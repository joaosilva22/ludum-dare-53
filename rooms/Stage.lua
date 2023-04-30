Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.timer = Timer()

    self.shapes = {}
    self.timer:every(1.5, function() self:spawnShape() end)
end

function Stage:update(dt)
    self.area:update(dt)

    for i, shape in ipairs(self.shapes) do
        shape.x = shape.x + 50 * dt
        if shape.x > gw then
            shape.dead = true
            self.shapes[i+1].active = true
        end
    end
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
        camera:attach()
        self.area:draw()
        camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Stage:spawnShape()
    local shape_choices = {"Square", "Triangle"}
    local shape = shape_choices[love.math.random(#shape_choices)]
    local active = #self.shapes == 0 and true or false

    table.insert(self.shapes, self.area:addGameObject("Shape", -40, gh/2,
    {shape = shape, active = active}))
end