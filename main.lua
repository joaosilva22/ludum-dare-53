Object = require "libraries/classic-master/classic"
Camera = require "libraries/STALKER-X-master/Camera"
Input = require "libraries/boipushy-master/Input"
Timer = require "libraries/hump-master/timer"
fn = require "libraries/Moses-master/moses"

require "rooms/Game"
require "rooms/Stage"
require "rooms/Menu"
require "objects/GameObject"
require "objects/Area"
require "objects/Shape"
require "objects/Conveyor"
require "objects/ExplodeParticle"
require "objects/Box"
require "objects/PulseEffect"
require "objects/Cross"
require "objects/AnimatedText"
require "objects/GameOver"

function love.load()
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")
    love.mouse.setVisible(false)

    local font = love.graphics.newFont("resources/fonts/m5x7.ttf", 16)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    colors = {}
    colors.white = {1, 1, 1}
    colors.black = {0, 0, 0} -- no
    colors.active = {1, 1, 0} -- no
    colors.cyan = {0, 1, 1}
    colors.magenta = {1, 0, 1}
    colors.yellow = {1, 1, 0} -- no
    colors.red = {1, 0, 0} -- no
    colors.green = {0, 1, 0}
    colors.blue = {0, 0, 1}
    colors.gray = {0.5, 0.5, 0.5} -- no
    colors.orange = {1, 0.65, 0}
    colors.violet = {0.5, 0, 1}

    sounds = {}
    sounds.hurt = love.audio.newSource("resources/sounds/hurt.wav", "static")
    sounds.success = love.audio.newSource("resources/sounds/success.wav", "static")
    sounds.success_1 = love.audio.newSource("resources/sounds/success1.wav", "static")
    sounds.success_2 = love.audio.newSource("resources/sounds/success2.wav", "static")
    sounds.collision = love.audio.newSource("resources/sounds/collision.wav", "static") 
    sounds.power_up = love.audio.newSource("resources/sounds/powerUp2.wav", "static") 

    input = Input()
    input:bind("q", "q")
    input:bind("w", "w")
    input:bind("o", "o")
    input:bind("p", "p")
    input:bind("space", "space")

    camera = Camera()
    timer = Timer()

    current_room = nil

    slow_amount = 1

    resize(2)
    gotoRoom("Menu")
end

function love.update
    (dt)
    timer:update(dt)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end        
end

function love.draw()
    if current_room then current_room:draw(dt) end
end

function resize(s)
    love.window.setMode(s*gw, s*gh)
    sx, sy = s, s
end

function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end

function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

function random(min, max)
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function jitter(points)
    return fn.map(points, function(v, k)
        if k % 2 == 1 then
            return v + random(-1, 1)
        else
            return v + random(-1, 1)
        end
    end)
end

function UUID()
    local fn = function(x)
        local r = math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween(duration, _G, {slow_amount = 1}, 'in-out-cubic', function() print("Done!") end)
end