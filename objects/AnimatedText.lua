AnimatedText = GameObject:extend()

function AnimatedText:new(area, x, y, opts)
    AnimatedText.super.new(self, area, x, y, opts)

    self.colors = {
        colors.red,
        colors.orange,
        colors.yellow,
        colors.green,
        colors.blue,
        colors.violet,
    }

    self.font_size = opts.font_size or 32
    self.font = love.graphics.newFont("resources/fonts/m5x7.ttf", self.font_size)
    self.font:setFilter("nearest", "nearest")

    self.gap = 0.5 * self.font_size

    self.text_w = (#self.string-1)*self.gap
    self.text_h = self.font:getHeight()

    self.amplitude = 5 -- set the amplitude of the sine wave
    self.frequency = 0.1 -- set the frequency of the sine wave
    self.time = 0 -- set the initial time value
end

function AnimatedText:draw()
    pushRotate(self.x, self.y, self.r)

    for i = 1, #self.string do -- loop through each character in the text
        local char = self.string:sub(i, i) -- get the current character
        local charX = self.x + (i - 1) * self.gap -- calculate the x position of the current character
        local color = self.colors[(i-1) % #self.colors + 1]
        local offset = self.amplitude * math.sin(2 * math.pi * self.frequency * self.time + i * math.pi / 2) -- calculate the vertical offset of the current character
        local old_font = love.graphics.getFont()
        love.graphics.setFont(self.font)
        love.graphics.setColor(colors.white)
        love.graphics.setColor(color)
        love.graphics.print(char, charX-self.text_w/2, self.y-self.text_h/2+offset) -- draw the current character with the vertical offset applied
        love.graphics.setColor(colors.white)
        love.graphics.setFont(old_font)
        self.time = self.time + love.timer.getDelta() -- update the time value based on the frame rate
    end

    love.graphics.pop()
end

function AnimatedText:update(dt)
    AnimatedText.super.update(self, dt)
end