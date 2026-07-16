LG = love.graphics
rand = math.random

-- Map configuration
MAP_WIDTH  = 100
MAP_HEIGHT = 100
MAP_SIZE   = MAP_WIDTH * MAP_HEIGHT

DAY_DURATION = 1024
SUN_MIN      = 0.0
SUN_MAX      = 1.0
MINERALS_MIN = 256
MINERALS_MAX = 0

CELL_INIT_ENERGY   = 256.0
CELL_INIT_MINERALS = 256.0

LEAF_ENERGY_GEN         = 10
ROOT_MINERAL_EXTRACTION = 10

CELL_NAMES = {[0] = 'Empty', 'Leaf', 'Root', 'Stem', 'Seed', 'Spore', 'Sprout'}

CELL_COLORS = {
    {0.0, 1.0, 0.0}, -- Leaf
    {1.0, 0.0, 0.0}, -- Root
    {0.5, 0.5, 0.5}, -- Stem
    {0.0, 1.0, 0.0}, -- Seed
    {0.5, 0.0, 1.0}, -- Spore
    {1.0, 0.5, 0.0}, -- Sprout
}

CELL_AI_CONFIG = {
    {10, 16, 2},    -- Seed
    {7, 14, 2},     -- Spore
    {10, 20, 16, 4} -- Sprout
}

MAP_CELLS      = {}
MAP_MINERALS   = {}
--BUFFER_ENERGY  = {}
--BUFFER_MINERAL = {}
--BUFFER_SPAWN   = {}
--BUFFER_DEATH   = {}
CELL_GENOMES   = {}
CELL_COUNTER   = 0

function clamp(value, lo, hi)
    if value < lo then return lo end
    if value > hi then return hi end
    return value
end

function pos2idx(x, y)
    return x + ((y - 1) * MAP_WIDTH)
end

function idx2pos(idx)
    return (idx - 1) % MAP_WIDTH + 1, math.floor((idx - 1) / MAP_WIDTH) + 1
end