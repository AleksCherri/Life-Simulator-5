require('shares')
local ai_module = require('ai_module')

local M = {}

local Cell = {}
Cell.__index = Cell

local dir_offsets = {-MAP_WIDTH, -1, MAP_WIDTH, 1}

function Cell.new(typ, x, y, direction, args)
    -- Common attributes
    args           = args or {}
    local energy   = args.energy or CELL_INIT_ENERGY
    local minerals = args.minerals or CELL_INIT_MINERALS

    x, y = clamp(x, 1, MAP_WIDTH), clamp(y, 1, MAP_HEIGHT) -- if not cyclic map
    direction      = direction % 4
    local idx      = pos2idx(x, y)
    local rotation = direction / 2 * math.pi

    local cell = {
        typ = typ,
        idx = idx,
        x   = x,
        y   = y,
        rotation  = rotation,
        direction = direction,
        energy    = energy,
        minerals  = minerals,
        alive     = true
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

function M.initCell(typ, x, y, direction, args)
    return Cell.new(typ, x, y, direction, args)
end

return M