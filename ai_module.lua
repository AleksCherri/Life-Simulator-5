-- NEEDS REFACTORING

local rand = math.random
local M = {}

-- Weights are stored as a table idxth the folloidxng structure: (bias, threshold, diactivation constant, N connection weights to next layer) - for each node
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

function M.mutate(weights, mult)
    local scale = mult * 2

    for _ = 1, rand(1, #weights) do
        local idx = rand(1, #weights)
        weights[idx] = weights[idx] + (rand() - 0.5) * scale
    end

    return weights
end

function M.act(layers, weights, data)
    local idx, new_data = 1, {}

    for i = 2, #layers do
        new_data = {}
        local layer = layers[i]
        for j = 1, layers[i-1] do
            local value = data[j] + weights[idx]
            if value <= weights[idx+1] then
                value = weights[idx+2]
            end
            for k = 1, layer do
                if new_data[k] == nil then new_data[k] = 0.0 end
                new_data[k] = new_data[k] + value * weights[idx+k+2]
            end
            idx = idx + layer + 3
        end
        data = new_data
    end

    return data
end

return M