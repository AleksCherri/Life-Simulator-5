local shares    = require('shares')
local ai_module = require('ai_module')

local M = {}

local x_offsets = {0, -1, 0, 1}
local y_offsets = {-1, 0, 1, 0}

function M.initCell(typ, x, y, direction, args)
    -- Common attributes
    args           = args or {}
    local energy   = args.energy   or shares.CELL_INIT_ENERGY
    local minerals = args.minerals or shares.CELL_INIT_MINERALS
    local parent   = args.parent

    --x, y = clamp(x, 1, shares.MAP_WIDTH), clamp(y, 1, shares.MAP_HEIGHT) -- if not cyclic map
    x, y = (x - 1) % shares.MAP_WIDTH + 1, (y - 1) % shares.MAP_HEIGHT + 1
    direction      = direction % 4
    local idx      = shares.pos2idx(x, y)

    local cell = {
        idx,
        typ,
        direction,
        energy,
        minerals,
        0, -- age
        parent,
    }

    if typ == 3 or typ == 4 or typ == 6 then
        for i = 0, 2 do
            local dir = (direction + i) % 4
            cell[8 + i] = pos2idx(x + x_offsets[dir], y + y_offsets[dir])
        end
    end
    if typ >= 4 then
        local genome = args.genome
        if genome == nil then genome = ai_module.genWeights() 
        elseif rand() < ai_module.GENOME_MUTATION_CHANCE then 
            genome = ai_module.mutateWeights(genome)
        end
        cell[11] = genome
    end

    return cell
end

return M