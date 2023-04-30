Conveyor = GameObject:extend()

function Conveyor:new(area, x, y, opts)
    Conveyor.super.new(self, area, x, y, opts)

    self.xp = 0
    self.xp_percent = 0
    self.errors = 0
    self.game_over = false

    self.current_level = 1
    self.levels = {
        {
            threshold=499,
            conveyor_speed=50,
            spawn_period=1.5,
            colors={colors.cyan, colors.white},
        },
        {
            threshold=1499,
            conveyor_speed=60,
            spawn_period=1.35,
            colors={colors.cyan, colors.magenta, colors.white},
        },
        {
            threshold=3499,
            conveyor_speed=72,
            spawn_period=1.21,
            colors={colors.cyan, colors.magenta, colors.white, colors.green},
        },
        {
            threshold=7499,
            conveyor_speed=86,
            spawn_period=1,
            colors={colors.cyan, colors.magenta, colors.white, colors.green, colors.blue},
        },
        {
            threshold=15499,
            conveyor_speed=104,
            spawn_period=0.9,
            colors={colors.cyan, colors.magenta, colors.white, colors.green, colors.blue, colors.orange},
        },
        {
            threshold=31499,
            conveyor_speed=125,
            spawn_period=0.81,
            colors={colors.cyan, colors.magenta, colors.white, colors.green, colors.blue, colors.orange, colors.violet},
        },
        {
            threshold=99999999999999999,
            conveyor_speed=150,
            spawn_period=0.72,
            colors={colors.cyan, colors.magenta, colors.white, colors.green},
        }
    }
    self.spawn_timer = self.timer:every(self.levels[self.current_level].spawn_period, function() self:spawn() end)

    self.crosses = {
        self.area:addGameObject("Cross", gw/2-20, gh-20),
        self.area:addGameObject("Cross", gw/2, gh-20),
        self.area:addGameObject("Cross", gw/2+20, gh-20),
    }

    self.shapes = {}

    self.boxes = {}
    local b1 = self.area:addGameObject("Box", 75, 75, {
        possible_colors=self.levels[self.current_level].colors,
        possible_shapes={"Square", "Triangle", "Circle"},
        slide_in="left",
        action_key="Q",
    })
    local b2 = self.area:addGameObject("Box", 195, 75, {
        possible_colors=self.levels[self.current_level].colors,
        possible_shapes={"Square", "Triangle", "Circle"},
        slide_in="right",
        action_key="O",
    })
    local b3 = self.area:addGameObject("Box", 75, 195, {
        possible_colors=self.levels[self.current_level].colors,
        possible_shapes={"Square", "Triangle", "Circle"},
        slide_in="left",
        action_key="W",
    })
    local b4 = self.area:addGameObject("Box", 195, 195, {
        possible_colors=self.levels[self.current_level].colors,
        possible_shapes={"Square", "Triangle", "Circle"},
        slide_in="right",
        action_key="P",
    })
    table.insert(self.boxes, b1)
    table.insert(self.boxes, b3)
    table.insert(self.boxes, b2)
    table.insert(self.boxes, b4)
end

function Conveyor:update(dt)
    Conveyor.super.update(self, dt)

    for i, shape in ipairs(self.shapes) do
        -- TODO: Set speed in the shape object
        shape.x = shape.x + self.levels[self.current_level].conveyor_speed * dt
        if shape.x > gw then
            shape:die()
            table.remove(self.shapes, i)

            self:incrementErrors()
            
            if #self.shapes > 0 then
                self.shapes[1]:activate()
            end
        end
    end

    if not self.game_over then
        if input:pressed("q") then self:putShapeInBox(self.boxes[1]) end
        if input:pressed("w") then self:putShapeInBox(self.boxes[2]) end
        if input:pressed("o") then self:putShapeInBox(self.boxes[3]) end
        if input:pressed("p") then self:putShapeInBox(self.boxes[4]) end
    else
        if input:pressed("space") then 
            camera:fade(0.5, {0, 0, 0, 1}, function() gotoRoom("Game") end)
        end
    end
end

function Conveyor:draw()
    pushRotate(self.x, self.y, self.r)

    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", 0, 0, self.xp_percent*gw, 10)

    love.graphics.setColor(colors.white)
    love.graphics.printf("Score: " .. self.xp, 20, 15, gw-40, "left")

    love.graphics.setColor(colors.white)
    love.graphics.printf("Level " .. self.current_level, 20, 15, gw-40, "right")

    love.graphics.pop()
end

function Conveyor:spawn()
    -- print("SPAWN BEGIN-------------------------------------")
    local all_possibilities = {}
    for i, box in ipairs(self.boxes) do
        -- print("Box " .. i)
        for _, shape in ipairs(box:getUnfulfilledShapes()) do
            table.insert(all_possibilities, {color=shape.color, shape=shape.shape})
        end
    end

    -- print("All possibilities: " .. #all_possibilities)

    for _, shape in ipairs(self.shapes) do
        for i, possibility in ipairs(all_possibilities) do
            if possibility.color == shape.color and possibility.shape == shape.shape then
                -- print("Removing " .. shape.shape .. " from spawning pool because it's already been spawned.")
                table.remove(all_possibilities, i)
                break
            end
        end
    end

    -- print("Can spawn one of " .. #all_possibilities .. " shapes/color combinations")

    if #all_possibilities == 0 then
        return
    end

    local choice = all_possibilities[love.math.random(#all_possibilities)]

    local shape = self.area:addGameObject("Shape", -40, gh/2, 
    {shape=choice.shape, color=choice.color, w=30, h=30})

    local active = #self.shapes == 0 and true or false
    if #self.shapes == 0 then
        shape:activate()
    end

    table.insert(self.shapes, shape)
    -- print("SPAWN END-------------------------------------")
end

function Conveyor:putShapeInBox(box)
    box:pulse()
    for _, shape in ipairs(box:getUnfulfilledShapes()) do
        if #self.shapes > 0 and shape.color == self.shapes[1].color and shape.shape == self.shapes[1].shape then
            local active_shape = self.shapes[1]
            active_shape.active = false
            box:fulfillShape(shape)
            table.remove(self.shapes, 1)
            self:addXP(100)

            if #self.shapes > 0 then
                self.shapes[1]:activate()
            end

            sounds.success_1:play()
            self.timer:tween(0.5, active_shape, {x=box.x, y=box.y}, "in-out-cubic", function() 
                active_shape:pop()
                self:replaceBoxes()
            end)

            return
        end
    end

    -- TODO: If we fail, play a sound
    if #self.shapes > 0 then 
        self.shapes[1]:flash()
        self:incrementErrors()
    end
end

function Conveyor:replaceBoxes()
    for i, box in ipairs(self.boxes) do
        if box:isComplete() then
            self.boxes[i] = self.area:addGameObject("Box", box.x, box.y, {
                possible_colors=self.levels[self.current_level].colors,
                possible_shapes=box.possible_shapes,
                slide_in=box.slide_in,
                action_key=box.action_key,
            })
            box:die()
            self:addXP(500)
        end
    end
end

function Conveyor:addXP(amount)
    self.xp = self.xp + amount

    local level = self.levels[self.current_level]
    if self.xp > level.threshold then
        self.current_level = self.current_level+1
        self.timer:cancel(self.spawn_timer)
        self.spawn_timer = self.timer:every(self.levels[self.current_level].spawn_period, function() self:spawn() end)
        -- self.area:addGameObject("LevelUp", 0, 0, {strings=level.strings})
        -- for i=1, #self.shapes do
        --     self.shapes[i]:pop()
        -- end
        -- self.shapes = {}
        local t = function() self.timer:tween(0.15, self, {xp_percent=0}, "in-out-cubic") end
        self.timer:tween(0.15, self, {xp_percent=1}, "in-out-cubic", t)
        sounds.power_up:play()
    else
        local threshold = self.levels[self.current_level].threshold
        local prev_threshold = 0
        if self.current_level > 1 then
            prev_threshold = self.levels[self.current_level-1].threshold
        end
        self.timer:tween(0.15, self, {xp_percent=(self.xp-prev_threshold)/(threshold-prev_threshold)}, "in-out-cubic")
    end
end

function Conveyor:incrementErrors()
    self.errors = self.errors + 1
    self.crosses[self.errors]:activate()
    if self.errors == 3 then
        self:gameOver()
    end
end

function Conveyor:gameOver()
    self.area:addGameObject("GameOver", 0, 0)
    for i=1, #self.shapes do
        self.shapes[i]:pop()
    end
    self.shapes = {}
    self.timer:cancel(self.spawn_timer)
    self.game_over = true
end