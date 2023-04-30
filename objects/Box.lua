Box = GameObject:extend()

function Box:new(area, x, y, opts)
    Box.super.new(self, area, x, y, opts)

    self.w, self.h = 110, 70
    self.r = 0

    self.possible_colors = opts.possible_colors or {}
    self.possible_shapes = opts.possible_shapes or {}
    self.slide_in = opts.slide_in or "left"
    self.action_key = opts.action_key or "UNDEFINED"

    if self.slide_in == "left" then
        self.x = -self.w/2
        self.timer:tween(1, self, {x=x}, "out-cubic")
    end
    if self.slide_in == "right" then
        self.x = gw+self.w/2
        self.timer:tween(1, self, {x=x}, "out-cubic")
    end

    self.polygons = {}
    self.polygons[1] = {
        -self.w/2, -self.h/2,
        self.w/2, -self.h/2,
        self.w/2, self.h/2,
        -self.w/2, self.h/2, 
    }

    self.shapes = {}
    self.shape_1 = self:createShape(self.x-25, self.y+10)
    self.shape_2 = self:createShape(self.x, self.y+10)
    self.shape_3 = self:createShape(self.x+25, self.y+10)
    self.shapes[1] = self.shape_1
    self.shapes[2] = self.shape_2
    self.shapes[3] = self.shape_3
    self.fulfilled = {false, false, false}
end

function Box:update(dt)
    Box.super.update(self, dt)

    self.shape_1.x = self.x-25
    self.shape_2.x = self.x
    self.shape_3.x = self.x+25
end

function Box:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(colors.white)
    local points = fn.map(self.polygons[1], function(v, k) 
        if k % 2 == 1 then 
            return self.x + v + random(-1, 1) 
        else 
            return self.y + v + random(-1, 1) 
        end 
    end)
    love.graphics.polygon("line", points)

    love.graphics.printf("["..self.action_key.."]", self.x-self.w/2, self.y-self.h/2 + 10, self.w, "center")

    love.graphics.pop()
end

function Box:createShape(x, y)
    local color = self.possible_colors[love.math.random(#self.possible_colors)]
    local shape = self.possible_shapes[love.math.random(#self.possible_shapes)]
    return self.area:addGameObject("Shape", x, y, 
    {color = color, shape = shape, w = 15, h = 15})
end

function Box:pulse()
    self.area:addGameObject("PulseEffect", self.x, self.y, {parent=self})
end

function Box:bigPulse()
    self.area:addGameObject("PulseEffect", self.x, self.y, {parent=self, color=colors.yellow, line_width=4})
end

function Box:fulfillShape(s)
    for i, shape in ipairs(self.shapes) do
        if self.fulfilled[i] == false and s.color == shape.color and s.shape == shape.shape then
            shape.color = colors.gray
            self.fulfilled[i] = true
            -- print("Fulfilling shape " .. i)
            -- for _, fulfilled in ipairs(self.fulfilled) do
            --     print(fulfilled)
            -- end
            break
        end
    end
end

function Box:getUnfulfilledShapes()
    local result = {}
    for i, shape in ipairs(self.shapes) do
        if not self.fulfilled[i] then
            -- print("Unfulfilled " .. i)
            table.insert(result, shape)
        end
    end
    -- for _, fulfilled in ipairs(self.fulfilled) do
    --     print(fulfilled)
    -- end
    -- print("Has " .. #result .. " unfulfilled shapes")
    return result
end

function Box:isComplete()
    for _, fulfilled in ipairs(self.fulfilled) do
        if fulfilled == false then
            return false
        end
    end
    return true
end

function Box:die()
    if self.slide_in == "left" then
        self.timer:tween(1, self, {x=-self.w/2}, "out-cubic", function() self.dead = true end)
    end
    if self.slide_in == "right" then
        self.timer:tween(1, self, {x=gw+self.w/2}, "out-cubic", function() self.dead = true end)
    end
    self:bigPulse()
    sounds.success_2:play()
end