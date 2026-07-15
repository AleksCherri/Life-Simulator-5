local id = ...

local input_ch = love.thread.getChannel('toThread' .. id)
local output_ch = love.thread.getChannel('fromThread' .. id)

while true do
    local data = input_ch:demand()
end