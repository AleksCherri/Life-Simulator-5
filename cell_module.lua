require('main')

CELL_COLORS = {
    {0.0, 1.0, 0.0}, -- Leaf
    {1.0, 0.0, 0.0}, -- Root
    {0.5, 0.5, 0.5}, -- Stem
    {0.0, 1.0, 0.0}, -- Seed
    {0.5, 0.0, 1.0}, -- Spore
    {1.0, 0.5, 0.0}  -- Sprout
}

CELL_TYPES = {'Leaf', 'Root', 'Stem', 'Seed', 'Spore', 'Sprout'}

local M = {}

local cell_atlas = LG.newImage('cell_sprites.png')
cell_atlas:setFilter('nearest')
M.cell_counter = 0
M.cell_sprites = {}
for i = 0, 6 do M.cell_sprites[i] = LG.newQuad(8 * i, 0, 8, 8, cell_atlas) end
M.cell_batch = LG.newSpriteBatch(cell_atlas, Map.size)

function M.addCell(cell)
    if Map[cell.idx] then return false else Map[cell.idx] = cell end
    local r, g, b = CELL_COLORS[cell.type]
    M.cell_batch:setColor(r, g, b)
    M.cell_batch:set(
        cell.idx,
        M.cell_sprites[cell.type],
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
    M.cell_batch:set(cell.idx, cell_sprites[0], cell.x, cell.y, 0, 0.125, 0.125, 4, 4)
    M.cell_counter = cell_counter - 1
    return true
end

function M.initCell(type, x, y, direction)
    direction = (direction - 1) % 4
    local idx = pos2idx(x, y)
    local rotation = direction / 2 * math.pi
    local cell = {
        type = type,
        idx = idx,
        x = x,
        y = y,
        rotation = rotation,
        direction = direction + 1
    }
    return cell
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

return M