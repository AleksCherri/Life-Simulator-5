local ai_module = require('ai_module')

CELL_COLORS = {
    {0.0, 1.0, 0.0}, -- Leaf
    {1.0, 0.0, 0.0}, -- Root
    {0.5, 0.5, 0.5}, -- Stem
    {0.0, 1.0, 0.0}, -- Seed
    {0.5, 0.0, 1.0}, -- Spore
    {1.0, 0.5, 0.0}  -- Sprout
}

CELL_TYPES = {'Leaf', 'Root', 'Stem', 'Seed', 'Spore', 'Sprout'}

CELL_AI_CONFIG = {
    {10, 16, 2},    -- Seed
    {7, 14, 2},     -- Spore
    {10, 20, 16, 4} -- Sprout
}

local INIT_ENERGY = 256.0
local INIT_MINERALS = 256.0

local LEAF_ENERGY_GEN = 10
local ROOT_MINERAL_EXTRACTION = 10

local M = {}
local Cell = {}
Cell.__index = Cell

local cell_atlas = LG.newImage('cell_sprites.png')
cell_atlas:setFilter('nearest')
M.cell_sprites = {}
for i = 0, 6 do M.cell_sprites[i] = LG.newQuad(8 * i, 0, 8, 8, cell_atlas) end
M.cell_batch = LG.newSpriteBatch(cell_atlas, Map.size)

local dir_offsets = {-MAP_WIDTH, -1, MAP_WIDTH, 1}

function Cell:leafAct()
    self.energy = self.energy + LEAF_ENERGY_GEN
end

function Cell:rootAct()
end

function Cell:stemAct()
end

function Cell:seedAct()
end

function Cell:sporeAct()
end

function Cell:sproutAct()
end

local cell_actions = {
    leafAct,
    rootAct,
    stemAct,
    seedAct,
    sporeAct,
    sproutAct
}

function Cell.new(typ, x, y, direction, args)
    local energy, minerals, teamhash, message
    if args == nil then args = {} end
    if args.energy then energy = args.energy else energy = INIT_ENERGY end
    if args.minerals then minerals = args.minerals else minerals = INIT_MINERALS end
    if args.teamhash then teamhash = args.teamhash else teamhash = math.random() end
    if args.message then message = args.message else message = 0.0 end

    x, y = clamp(x, 1, MAP_WIDTH), clamp(y, 1, MAP_HEIGHT)
    direction = direction % 4
    local idx = pos2idx(x, y)
    local rotation = direction / 2 * math.pi

    local cell = {
        typ = typ,
        idx = idx,
        x = x,
        y = y,
        rotation = rotation,
        direction = direction,
        energy = energy,
        minerals = minerals,
        teamhash = teamhash,
        message = message,
        state = 1,
        act = cell_actions[typ]
    }

    if typ < 3 then
        cell.target = Map[idx + dir_offsets[direction+1]]
    elseif typ > 3 then
        local genome
        if args.genome == nil then 
            genome = {}
            for i = 1, 3 do genome[i] = ai_module.genAi(CELL_AI_CONFIG[i]) end
        else genome = args.genome end
        cell.genome, cell.ai = genome, genome[typ - 3]
    end

    return setmetatable(cell, Cell)
end

function M.addCell(cell)
    if Map[cell.idx] then return false else Map[cell.idx] = cell end
    local r, g, b = CELL_COLORS[cell.typ]
    M.cell_batch:setColor(r, g, b)
    M.cell_batch:set(
        cell.idx,
        M.cell_sprites[cell.typ],
        cell.x,
        cell.y,
        cell.rotation,
        0.125,
        0.125,
        4, 4
    )
    M.cell_counter = M.cell_counter + 1
    return true
end

function M.removeCell(cell)
    if Map[cell.idx] then Map[cell.idx] = nil else return false end
    M.cell_batch:setColor(0.0, 0.5, 1.0, 0.1)
    M.cell_batch:set(cell.idx, M.cell_sprites[0], cell.x, cell.y, 0, 0.125, 0.125, 4, 4)
    M.cell_counter = M.cell_counter - 1
    return true
end

function M.initCell(typ, x, y, direction, args)
    return Cell.new(typ, x, y, direction, args)
end

function M.initCellBatch()
    M.cell_batch:clear()
    M.cell_batch:setColor(0.0, 0.5, 1.0, 0.1)
    for y = 1, MAP_HEIGHT do 
        for x = 1, MAP_WIDTH do    
            M.cell_batch:add(M.cell_sprites[0], x, y, 0, 0.125, 0.125, 4, 4)
        end
    end
end

function M.regen()
    M.initCellBatch()
    M.aiqueue = {}
    M.cell_counter = 0

    M.addCell(M.initCell(
        6,
        math.random(1, MAP_WIDTH),
        math.random(1, MAP_HEIGHT),
        math.random(1, 4)
    ))
end

return M