require('shares')
local cell_module = require('cell_module')

-- Simulation configuration
local TPS = 60

local VIEW_MODES = {'Normal', 'Energy', 'Cell Minerals', 'Map Minerals'}

local tps_threshold = 1.0 / TPS
local tps_timer     = 0.0
local pause         = true

-- Camera variables
local view_mode = 0 -- 0: normal, 1: energy, 2: cell minerals, 3: map minerals
local target_cell = {x = 0, y = 0, cell = nil}
local screen_width, screen_height = LG.getDimensions()
local camera_x = (screen_width - MAP_WIDTH) / 2
local camera_y = (screen_height - MAP_HEIGHT) / 2
local camera_zoom = 1.0
local world_x, world_y = 0.0, 0.0
local highlight_x, highlight_y = 0, 0
local draw_interface = true
local is_mouse_pressed = false

function regenMap()
    MAP_CELLS, MAP_MINERALS = {}, {}
    CELL_GENOMES = {}
    CELL_COUNTER = 0

    for i = 1, MAP_SIZE do
        MAP_MINERALS[i] = rand(MINERALS_MIN, MINERALS_MAX)
    end

    initCellBatch()
    initMineralBatch()

    addCell(cell_module.initCell(
        6,
        rand(1, MAP_WIDTH),
        rand(1, MAP_HEIGHT),
        rand(0, 3)
    ))
end

function initCellBatch()
    cell_batch:clear()
    cell_batch:setColor(0.0, 0.5, 1.0, 0.1)
    for y = 1, MAP_HEIGHT do 
        for x = 1, MAP_WIDTH do    
            cell_batch:add(cell_sprites[0], x, y, 0, 0.125, 0.125, 4, 4)
        end
    end
end

function initMineralBatch()
    mineral_batch:clear()
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local a = MAP_MINERALS[pos2idx(x, y)] / MINERALS_MAX
            mineral_batch:setColor(0.0, 0.0, a, 0.5)
            mineral_batch:add(x, y, 0, 1, 1, 0.5, 0.5)
        end
    end
end

function updateMinerals(idx)
    local x, y = idx2pos(idx)
    local a = MAP_MINERALS[idx] / MINERALS_MAX
    mineral_batch:setColor(0.0, 0.0, a, 0.5)
    minerals_batch:set(idx, x, y, 0, 1, 1, 0.5, 0.5)
end

function addCell(cell)
    if MAP_CELLS[cell.idx] then return false else MAP_CELLS[cell.idx] = cell end
    CELL_COUNTER = CELL_COUNTER + 1
    local r, g, b = CELL_COLORS[cell.typ]
    cell_batch:setColor(r, g, b)
    cell_batch:set(
        cell.idx,
        cell_sprites[cell.typ],
        cell.x,
        cell.y,
        cell.rotation,
        0.125,
        0.125,
        4, 4
    )
    return true
end

function removeCell(idx)
    local cell = MAP_CELLS[idx]
    if not cell then return false else MAP_CELLS[idx] = nil end

    MAP_MINERALS[idx] = MAP_MINERALS[idx] + cell.minerals + CELL_COSTS[cell.typ]
    CELL_COUNTER      = CELL_COUNTER - 1
    local x, y        = idx2pos(idx)
    cell_batch:setColor(0.0, 0.5, 1.0, 0.1)
    cell_batch:set(idx, cell_sprites[0], x, y, 0, 0.125, 0.125, 4, 4)
    updateMinerals(idx)
    return true
end

function tick()
    local BUFFER_ENERGY  = {}
    local BUFFER_MINERAL = {}
    local BUFFER_SPAWN   = {}
    local BUFFER_DEATH   = {}
    local BUFFER_UPDATE  = {}
    local spawn_idx, death_idx = 0, 0

    for i = 1, MAP_SIZE do
        local cell = MAP_CELLS[i]
        if cell then
            local res = cell:act()
            if cell.typ <= 3 then
                for idx, v in pairs(res.energy) do
                    BUFFER_ENERGY[idx] = (BUFFER_ENERGY[idx] or 0.0) + v
                end
                for idx, v in pairs(res.minerals) do
                    BUFFER_MINERALS[idx] = (BUFFER_MINERALS[idx] or 0.0) + v
                end
            elseif cell.typ == 6 then
                for i = 1, #res.spawns do
                    spawn_idx = spawn_idx + 1
                    BUFFER_SPAWN[spawn_idx] = res.spawns[i]
                end
            end
            if cell.alive == 0 then
                death_idx = death_idx + 1
                BUFFER_DEATH[death_idx] = cell.idx
            end
        end
    end

    if CELL_COUNTER <= 0 then regenMap() end
end

function love.load()
    --[[function update_minerals()
        local sx, sy = math.max(math.floor(-camera_x / camera_zoom), 1), math.max(math.floor(-camera_y / camera_zoom), 1)
        local w, h = math.min(math.ceil(screen_width / camera_zoom) + sx, MAP_WIDTH), math.min(math.ceil(screen_height / camera_zoom) + sy, MAP_HEIGHT)
        for y = sy, h do
            for x = sx, w do
                local c
                local idx = pos2idx(x, y)
                if Map.minerals[idx] then c = Map.minerals[idx] / MINERALS_MAX else c = 0.0 end
                mineral_batch:setColor(0.0, 0.0, 1.0, c)
                mineral_batch:set(idx, x + 3.5, y + 3.5, 0, 1, 1, 4, 4)
            end
        end
    end]]

    local cell_atlas = LG.newImage('cell_sprites.png')
    cell_atlas:setFilter('nearest')
    cell_sprites = {}
    for i = 0, 6 do cell_sprites[i] = LG.newQuad(8 * i, 0, 8, 8, cell_atlas) end
    cell_batch = LG.newSpriteBatch(cell_atlas, MAP_SIZE)

    local img_data = love.image.newImageData(1, 1)
    img_data:setPixel(0, 0, 1, 1, 1, 1)
    local rectimg = LG.newImage(img_data)
    rectimg:setFilter('nearest')
    mineral_batch = LG.newSpriteBatch(rectimg, MAP_SIZE)

    regenMap()
end

function love.update(dt)
    if not pause then tps_timer = tps_timer + dt end
    while tps_timer >= tps_threshold do
        tps_timer = tps_timer - tps_threshold
        tick()
    end
end

function love.draw()
    screen_width, screen_height = LG.getDimensions()

    LG.translate(camera_x, camera_y)
    LG.scale(camera_zoom, camera_zoom)
    LG.setColor(1.0, 1.0, 1.0)

    LG.rectangle('fill', 0.5, 0.5, MAP_WIDTH, MAP_HEIGHT)
    LG.draw(cell_batch)

    if view_mode == 3 then LG.draw(mineral_batch) end

    LG.setColor(0.0, 0.5, 1.0, 0.5)
    LG.rectangle('fill', highlight_x - 0.5, highlight_y - 0.5, 1.0, 1.0)
    LG.setColor(1.0, 0.8, 0.0, 0.5)
    LG.rectangle('fill', target_cell.x - 0.6, target_cell.y - 0.6, 1.2, 1.2)

    -- User Interface
    if draw_interface then
        LG.setColor(1.0, 0.0, 0.5)
        LG.scale(1 / camera_zoom, 1 / camera_zoom)
        LG.translate(-camera_x, -camera_y)

        LG.print(
            'FPS: '      .. love.timer.getFPS() ..
            '\nTPS: '    .. math.floor(1 / tps_threshold) ..
            '\nCells: '  .. CELL_COUNTER ..
            '\nX, Y: '   .. highlight_x .. ' ' .. highlight_y ..
            '\nTarget: ' .. target_cell.x .. ' ' .. target_cell.y,
            10, 10
        )

        LG.print(
            'View Mode: ' .. VIEW_MODES[view_mode + 1] ..
            '\nZoom: '    .. string.format('%.2f', camera_zoom),
            10, screen_height - 30
        )

        local cell = target_cell.cell
        if cell then 
            LG.print(
                'Type: '       .. CELL_NAMES[cell.typ] ..
                '\nDir: '      .. cell.direction ..
                '\nEnergy: '   .. cell.energy ..
                '\nMinerals: ' .. cell.minerals,
                10, 85
            )
        end

        if pause then
            LG.setColor(1.0, 0.0, 0.0)
            LG.print('Pause', screen_width / 2, 30, 0, 2, 2, 18)
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then is_mouse_pressed = true
    elseif button == 2 then
        target_cell.x = highlight_x
        target_cell.y = highlight_y
        target_cell.cell = MAP_CELLS[pos2idx(highlight_x, highlight_y)]
    end
end

function love.mousereleased(x, y, button, istouch)
    if button == 1 then is_mouse_pressed = false end
end

function love.mousemoved(x, y, dx, dy, isTouch)
    if is_mouse_pressed then camera_x, camera_y = camera_x + dx, camera_y + dy end
    world_x, world_y = (x - camera_x) / camera_zoom, (y - camera_y) / camera_zoom
    highlight_x, highlight_y = math.floor(world_x + 0.5), math.floor(world_y + 0.5)
end

function love.wheelmoved(x, y)
    local mx, my = love.mouse.getPosition()
    camera_zoom = camera_zoom * 1.1 ^ y
    camera_x = mx - world_x * camera_zoom
    camera_y = my - world_y * camera_zoom
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'space' then pause = not(pause) 
    elseif key == 'up' then tps_threshold = clamp(tps_threshold / 1.1, 0.002, 1.0)
    elseif key == 'down' then tps_threshold = clamp(tps_threshold * 1.1, 0.002, 1.0)
    elseif key == 'u' then draw_interface = not(draw_interface)
    elseif key == 'e' then view_mode = (view_mode + 1) % 4
    end
end

function love.quit()
    -- Just for case
end