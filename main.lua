function love.load()
    MAP_WIDTH = 10
    MAP_HEIGHT = 10

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

    -- ffi = require('ffi')
    Ai = require('ai_module')

    Map = {
    width = MAP_WIDTH,
    height = MAP_HEIGHT,
    size = MAP_WIDTH * MAP_HEIGHT,

    minerals = {},
    cells = {}
    }

    function addCell(cell)
        local color = CELL_COLORS[cell.id]
        cell_batch:setColor(color[1], color[2], color[3])
        cell_batch:add(
        cell_sprites[cell.id],
        cell.x,
        cell.y,
        cell.rotation,
        0.125,
        0.125,
        0, 0
        )
    end

    function Map:init()
        for i = 1, self.size do
            self.minerals[i] = math.random(MINERALS_MIN, MINERALS_MAX)
            self.cells[i] = nil
        end
    end

    Map:init()

    cell_atlas = love.graphics.newImage('cell_sprites.png')
    cell_sprites = {}
    for i = 1, 6 do
        cell_sprites[i] = love.graphics.newQuad(8 * i, 0, 8, 8, cell_atlas)
    end
    cell_batch = love.graphics.newSpriteBatch(cell_atlas, Map.size)

    screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
    camera_x, camera_y, camera_zoom = screen_width / 2, screen_height / 2, 1.0
    is_mouse_pressed = false
end

function love.update(dt)
end

function love.draw()
    love.graphics.translate(camera_x, camera_y)
    love.graphics.scale(camera_zoom, camera_zoom)
    love.graphics.setColor(1.0, 1.0, 1.0)

    love.graphics.rectangle('fill', 0.0, 0.0, MAP_WIDTH, MAP_HEIGHT)
    love.graphics.draw(cell_batch)

    love.graphics.scale(1 / camera_zoom, 1 / camera_zoom)
    love.graphics.translate(-camera_x, -camera_y)
    love.graphics.setColor(0.0, 1.0, 0.0)

    love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 10)
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then is_mouse_pressed = true end
end

function love.mousereleased(x, y, button, istouch)
    if button == 1 then is_mouse_pressed = false end
end

function love.mousemoved(x, y, dx, dy, isTouch)
    if is_mouse_pressed then
        camera_x = camera_x + dx
        camera_y = camera_y + dy
    end
end

function love.wheelmoved(x, y)
    camera_zoom = camera_zoom * 1.1 ^ y
end