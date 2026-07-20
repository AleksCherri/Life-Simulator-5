local shares = require('shares')

local M = {}

local rand = math.random

-- Weights are stored as a table with the following structure: (bias, threshold, diactivation constant, *weights) per node
function M.genWeights(mult)
    local scale = mult * 2
    local weights, idx = {}, 1
    for i = 1, shares.AI_LEN_COMMON do
        weights[i] = (rand() - 0.5) * scale
    end
    return weights
end

function M.mutateWeights(weights, strenght)
    strenght    = strenght or 0.1
    local scale = mult * 2
    local w_len = shares.AI_LEN_COMMON
    local new_weights = {}
    for i = 1, w_len do new_weights[i] = weights[i] end
    for _ = 1, rand(1, w_len) do
        local idx = rand(1, w_len)
        new_weights[idx] = new_weights[idx] + (rand() - 0.5) * scale
    end
    return new_weights
end

function M.run(weights, layers, idx_offset, inputs)
    local len    = #layers
    local idx    = 1 + idx_offset
    local offset = 0
    local data   = {}
    for i = 1, layers[1] do data[i] = inputs[i] end

    for i = 2, len do
        local layer       = layers[i]
        local prev_layer  = layers[i - 1]
        local next_offset = offset + prev_layer
        for j = 1, prev_layer do
            -- Calculating value
            local value = (data[j + offset] or 0.0) + weights[idx]
            if value <= weights[idx + 1] then
                value = weights[idx + 2]
            end

            -- Applying weights to the following nodes
            for k = 1, layer do
                local ofs = next_offset + k
                data[ofs] = (data[ofs] or 0.0) + value * weights[idx + k + 2]
            end
            idx = idx + layer + 3
            offset = next_offset
        end
    end

    local result = {}
    for i = 1, layers[len] do
        local value = data[offset + i] + weights[idx]
        if value <= weights[idx + 1] then
            value = weights[idx + 2]
        end
        result[i] = value
        idx = idx + 3
    end
    return result
end

return M