local M = {}
local rand = math.random
local AI = {}
AI.__index = AI

function AI.new(layers, weights, mult)
    if mult == nil then mult = 100.0 end
    if weights == nil then weights = M.genWeights(layers, mult) end
    return setmetatable({
        layers = layers,
        nLayers = #layers,
        weights = weights
    }, AI)
end

function M.genAi(layers, weights, mult)
    return AI.new(layers, weights, mult)
end

-- Weights are stored as a table with the following structure: (bias, threshold, diactivation constant, N connection weights to next layer) - for each node
function M.genWeights(layers, mult)
    local scale = mult * 2
    local weights, idx = {}, 1

    for i = 1, #layers - 1 do
        local layer = layers[i]
        local next_layer = layers[i+1]
        for _ = 1, layer * (3 + next_layer) do
            weights[idx] = (rand() - 0.5) * scale
            idx = idx + 1
        end
    end

    return weights
end

function AI:mutate(mult)
    if mult == nil then mult = 0.1 end
    local nW = #self.weights
    local scale = mult * 2

    for _ = 1, rand(1, nW) do
        local idx = rand(1, nW)
        self.weights[idx] = self.weights[idx] + (rand() - 0.5) * scale
    end
end

function AI:act(data)
    local layers, len, weights = self
    local idx, offset = 1, 0

    for i = 2, len do
        local layer, prev_layer = layers[i], layers[i - 1]
        local next_offset = offset + prev_layer
        for j = 1, prev_layer do
            -- Calculating bias value
            if data[j + offset] then local bias = data[j + offset] else local bias = 0.0 end
            local value = bias + weigths[idx]
            if value <= weights[idx + 1] then
                value = weights[idx + 2]
            end

            -- Applying weights to the following nodes
            for k = 1, layer do
                local ofs = next_offset + k
                if data[ofs] then local bias = data[ofs] else local bias = 0.0 end
                data[ofs] = bias + value * weights[idx + k + 2]
            end
            idx = idx + layer + 3
            offset = next_offset
        end
    end

    local result = {}
    for i = 1, layers[len] do
        result[i] = data[offset + i]
    end
    return result
end

return M