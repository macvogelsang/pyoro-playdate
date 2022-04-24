
function blockIndexToX(i)
    return X_LOWER_BOUND + (BLOCK_WIDTH * (i-1))
end

function xToBlockIndex(x)
    return math.floor((x - X_LOWER_BOUND) / BLOCK_WIDTH) + 1
end