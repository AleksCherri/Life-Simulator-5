LG = love.graphics

function love.load()
    TPS = 60

    MAP_WIDTH = 1000
    MAP_HEIGHT = 1000

    DAY_DURATION = 1024
    SUN_MIN, SUN_MAX = 0.0, 1.0
    MINERALS_MIN, MINERALS_MAX = 0, 256

    VIEW_MODES = {'Normal', 'Energy', 'Cell Minerals', 'Map Minerals'}

    Map = {
    width = MAP_WIDTH,
    height = MAP_HEIGHT,
    size = MAP_WIDTH * MAP_HEIGHT,

    minerals = {},
    cells = {}
    }

    cell_module = require('cell_module')

    function pos2idx(x, y)
        return x + ((y - 1) * MAP_WIDTH)
    end

    function clamp(value, min, max)
        return math.max(math.min(value, max), min)
    end

    function Map:init()
        for i = 1, self.size do
            self.minerals[i] = math.random(MINERALS_MIN, MINERALS_MAX)
            self.cells[i] = nil
        end
    end
    Map:init()

    local img_data = love.image.newImageData(1, 1)
    img_data:setPixel(0, 0, 1, 1, 1, 1)
    rectimg = LG.newImage(img_data)
    rectimg:setFilter('nearest')
    mineral_batch = LG.newSpriteBatch(rectimg, Map.size)
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            mineral_batch:add(0, x - 0.5, y - 0.5, 0, 0.125, 0.125, 4, 4)
        end
    end

    cell_module.initCellBatch()

    screen_width, screen_height = LG.getDimensions()
    camera_x, camera_y, camera_zoom = (screen_width - MAP_WIDTH) / 2, (screen_height - MAP_HEIGHT) / 2, 1.0
    world_x, world_y = 0.0, 0.0

    view_mode = 0 -- 0: normal, 1: energy, 2: cell minerals, 3: map minerals
    highlight_x, highlight_y = 0, 0
    target_cell = {x=0, y=0, cell=nil}
    draw_interface = true
    is_mouse_pressed = false

    tps_threshold = 1 / TPS
    tps_timer = 0.0
    pause = true
end

function love.update(dt)
    if not pause then tps_timer = tps_timer + dt end
    if tps_timer >= tps_threshold then
        tps_timer = 0.0

        -- Main Logic
        local cell = cell_module.initCell(
            math.random(1, 6),
            math.random(1, MAP_WIDTH),
            math.random(1, MAP_HEIGHT),
            math.random(1, 4)
        )
        cell_module.addCell(cell)
    end
end

function love.draw()
    screen_width, screen_height = LG.getDimensions()

    -- Game Sprites
    LG.translate(camera_x, camera_y)
    LG.scale(camera_zoom, camera_zoom)
    LG.setColor(1.0, 1.0, 1.0)

    LG.rectangle('fill', 0.5, 0.5, MAP_WIDTH, MAP_HEIGHT)
    LG.draw(cell_module.cell_batch)

    if view_mode == 3 then
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
        LG.draw(mineral_batch)
    end

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
            'FPS: ' .. love.timer.getFPS() ..
            '\nTPS: ' .. math.floor(1 / tps_threshold) ..
            '\nCells: ' .. cell_module.cell_counter ..
            '\nX, Y: ' .. highlight_x .. ' ' .. highlight_y ..
            '\nTarget: ' .. target_cell.x .. ' ' .. target_cell.y,
            10, 10
        )
        LG.print(
            'View Mode: ' .. VIEW_MODES[view_mode + 1] ..
            '\nZoom: ' .. string.format('%.2f', camera_zoom),
            10, screen_height - 30
        )
        local cell = target_cell.cell
        if cell then LG.print('Type: ' .. CELL_TYPES[cell.type] .. ' ' .. 'Dir: ' .. cell.direction, 10, 85) end

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
        target_cell.cell = Map[pos2idx(highlight_x, highlight_y)]
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
    camera_x, camera_y = mx - world_x * camera_zoom, my - world_y * camera_zoom
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'space' then pause = not(pause) 
    elseif key == 'up' then tps_threshold = clamp(tps_threshold / 1.1, 0.002, 1.0)
    elseif key == 'down' then tps_threshold = clamp(tps_threshold * 1.1, 0.002, 1.0)
    elseif key == 'u' then draw_interface = not(draw_interface)
    elseif key == 'e' then view_mode = (view_mode + 1) % 4
    end
end