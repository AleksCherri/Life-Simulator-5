LG = love.graphics
rand = math.random

-- Map configuration
MAP_WIDTH  = 100
MAP_HEIGHT = 100
MAP_SIZE   = MAP_WIDTH * MAP_HEIGHT

DAY_DURATION = 1024
SUN_MIN      = 0.0
SUN_MAX      = 1.0
MINERALS_MIN = 0
MINERALS_MAX = 256

-- Cell configuration
CELL_INIT_ENERGY   = 256.0
CELL_INIT_MINERALS = 256.0

LEAF_ENERGY_GEN   = 10
ROOT_MINERAL_EXTR = 10

CELL_ENERGY_CONS = {
    0.5, -- Leaf
    1.0, -- Root
    1.0, -- Stem
    0.2, -- Seed
    2.0, -- Spore
    3.0, -- Sprout
}

CELL_COSTS = {
    2.0,  -- Leaf
    1.0,  -- Root
    1.0,  -- Stem
    10.0, -- Seed
    15.0, -- Spore
    5.0,  -- Sprout
}

CELL_COLORS = {
    {0.0, 1.0, 0.0}, -- Leaf
    {1.0, 0.0, 0.0}, -- Root
    {0.5, 0.5, 0.5}, -- Stem
    {0.0, 1.0, 0.0}, -- Seed
    {0.5, 0.0, 1.0}, -- Spore
    {1.0, 0.5, 0.0}, -- Sprout
}

AI_LAYERS_SEED   = {10, 16, 1}
AI_LAYERS_SPORE  = {7, 14, 1}
AI_LAYERS_SPROUT = {10, 20, 16, 3}

AI_OFFSET_SEED = 0
AI_OFFSET_SPORE = 

CELL_NAMES = {'Leaf', 'Root', 'Stem', 'Seed', 'Spore', 'Sprout'}

MAP_CELLS    = {}
MAP_MINERALS = {}
CELL_GENOMES = {}
CELL_COUNTER = 0

-- Some useful functions
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

function countWeights(layers)
    local n = 0
    for i = 1, #layers do
        local layer, next_layer = layers[i], layers[i + 1]
        n = n + layer * 3
        if next_layer then n = n + layer * next_layer end
    end
end