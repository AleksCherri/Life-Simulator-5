local MAP_WIDTH = 10
local MAP_HEIGHT = 10

local DAY_DURATION = 1024
local SUN_MIN, SUN_MAX = 0.0, 1.0
local MINERALS_MIN, MINERALS_MAX = 0, 256

local Ai = require('ai_module')
local ffi = require('ffi')
local game = love

local Map = {
    width = MAP_WIDTH,
    height = MAP_HEIGHT,
    size = MAP_WIDTH * MAP_HEIGHT,

    minerals = {},
    cells = {}
}

function Map:init()
    for i = 1, self.size do
        self.minerals[i] = math.random(MINERALS_MIN, MINERALS_MAX)
        self.cells[i] = nil
    end
end

function game.load()
    Map:init()
    imgx = 400
    imgy = 300
    mousePressed = false
end

function game.update(dt)
    if mousePressed then
        imgx, imgy = game.mouse.getPosition()
    end
end

function game.draw()
    game.graphics.print('meh', imgx, imgy)
end

function game.mousepressed(x, y, button, istouch)
    mousePressed = true
end

function game.mousereleased(x, y, button, istouch)
    mousePressed = false
end