function love.load()
    TPS = 60

    MAP_WIDTH = 1000
    MAP_HEIGHT = 1000

    DAY_DURATION = 1024
    SUN_MIN, SUN_MAX = 0.0, 1.0
    MINERALS_MIN, MINERALS_MAX = 0, 256

    CELL_COLORS = {
        {0.0, 1.0, 0.0}, -- Leaf
        {1.0, 0.0, 0.0}, -- Root
        {0.5, 0.5, 0.5}, -- Stem
        {0.0, 1.0, 0.0}, -- Seed
        {0.5, 0.0, 1.0}, -- Spore
        {1.0, 0.5, 0.0}  -- Sprout
    }

    CELL_TYPES = {'Leaf', 'Root', 'Stem', 'Seed', 'Spore', 'Sprout'}

    --ffi = require('ffi')
    Ai = require('ai_module')

    love.window.setTitle('Life Simulator v5.0')
    love.window.updateMode(800, 600, {vsync=false, msaa=0, resizable=true})

    Map = {
    width = MAP_WIDTH,
    height = MAP_HEIGHT,
    size = MAP_WIDTH * MAP_HEIGHT,

    minerals = {},
    cells = {}
    }

    function addCell(cell)
        if Map[cell.idx] then return false else Map[cell.idx] = cell end
        local r, g, b = CELL_COLORS[cell.type]
        cell_batch:setColor(r, g, b)
        cell_batch:set(
            cell.idx,
            cell_sprites[cell.type],
            cell.x,
            cell.y,
            cell.rotation,
            0.125,
            0.125,
            4, 4
        )
        cell_counter = cell_counter + 1
        return true
    end

    function removeCell(cell)
        if Map[cell.idx] then Map[cell.idx] = nil else return false end
        cell_batch:setColor(0.0, 0.5, 1.0, 0.1)
        cell_batch:set(cell.idx, cell_sprites[0], cell.x, cell.y, 0, 0.125, 0.125, 4, 4)
        cell_counter = cell_counter - 1
        return true
    end

    function pos2idx(x, y)
        return x + ((y - 1) * MAP_WIDTH)
    end

    function clamp(value, min, max)
        return math.max(math.min(value, max), min)
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

    function initCell(type, x, y, direction)
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

    function Map:init()
        for i = 1, self.size do
            self.minerals[i] = math.random(MINERALS_MIN, MINERALS_MAX)
            self.cells[i] = nil
        end
    end
    Map:init()

    cell_counter = 0
    cell_atlas = love.graphics.newImage('cell_sprites.png')
    cell_atlas:setFilter('nearest')
    cell_sprites = {}
    for i = 0, 6 do cell_sprites[i] = love.graphics.newQuad(8 * i, 0, 8, 8, cell_atlas) end
    cell_batch = love.graphics.newSpriteBatch(cell_atlas, Map.size)
    initCellBatch()

    screen_width, screen_height = love.graphics.getDimensions()
    camera_x, camera_y, camera_zoom = (screen_width - MAP_WIDTH) / 2, (screen_height - MAP_HEIGHT) / 2, 1.0
    world_x, world_y = 0.0, 0.0
    highlight_x, highlight_y = 0, 0
    target_cell = {x=0, y=0, cell=nil}
    is_mouse_pressed = false

    tps_threshold = 1 / TPS
    tps_timer = 0.0
    pause = true
    draw_interface = true
end

function love.update(dt)
    if not pause then tps_timer = tps_timer + dt end
    if tps_timer >= tps_threshold then
        tps_timer = 0.0

        -- Main Logic
        local cell = initCell(
            math.random(1, 6),
            math.random(1, MAP_WIDTH),
            math.random(1, MAP_HEIGHT),
            math.random(1, 4)
        )

        addCell(cell)
    end
end

function love.draw()
    screen_width, screen_height = love.graphics.getDimensions()

    -- Game Sprites
    love.graphics.translate(camera_x, camera_y)
    love.graphics.scale(camera_zoom, camera_zoom)
    love.graphics.setColor(1.0, 1.0, 1.0)

    love.graphics.rectangle('fill', 0.5, 0.5, MAP_WIDTH, MAP_HEIGHT)
    love.graphics.draw(cell_batch)

    love.graphics.setColor(0.0, 0.5, 1.0, 0.5)
    love.graphics.rectangle('fill', highlight_x - 0.5, highlight_y - 0.5, 1.0, 1.0)
    love.graphics.setColor(1.0, 0.8, 0.0, 0.5)
    love.graphics.rectangle('fill', target_cell.x - 0.6, target_cell.y - 0.6, 1.2, 1.2)

    -- User Interface
    if draw_interface then
        love.graphics.setColor(0.0, 1.0, 0.0)
        love.graphics.scale(1 / camera_zoom, 1 / camera_zoom)
        love.graphics.translate(-camera_x, -camera_y)

        love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 10)
        love.graphics.print('TPS: ' .. math.floor(1 / tps_threshold), 10, 25)
        love.graphics.print('Cells: ' .. cell_counter, 10, 40)
        love.graphics.print('X, Y: ' .. highlight_x .. ' ' .. highlight_y, 10, 55)
        love.graphics.print('Target: ' .. target_cell.x .. ' ' .. target_cell.y, 10, 70)
        local cell = target_cell.cell
        if cell then love.graphics.print('Type: ' .. CELL_TYPES[cell.type] .. ' ' .. 'Dir: ' .. cell.direction, 10, 85) end

        if pause then
            love.graphics.setColor(1.0, 0.0, 0.0)
            love.graphics.print('Pause', screen_width / 2, 30, 0, 2, 2, 18)
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
    elseif key == 'up' then tps_threshold = clamp(tps_threshold / 1.1, 1, 500)
    elseif key == 'down' then tps_threshold = clamp(tps_threshold * 1.1, 1, 500)
    elseif key == 'u' then draw_interface = not(draw_interface)
    end
end