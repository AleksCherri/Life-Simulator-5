local MAP_WIDTH = 10
local MAP_HEIGHT = 10

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
end

function game.update(dt)
end

function game.draw()
    game.graphics.print('meh', 400, 300)
end