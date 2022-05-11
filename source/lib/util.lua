
function blockIndexToX(i)
    return X_LOWER_BOUND + (BLOCK_WIDTH * (i-1))
end

function xToBlockIndex(x)
    return math.floor((x - X_LOWER_BOUND) / BLOCK_WIDTH) + 1
end

function enum( t )
	local result = {}

	for index, name in pairs(t) do
		result[name] = index * 10
	end

	return result
end

function math.ring(a, min, max)
    if min > max then
        min, max = max, min
    end
    return min + (a-min)%(max-min)
end

function math.ring_int(a, min, max)
    return math.ring(a, min, max+1)
end

function table.random( t )
    if type(t)~="table" then return nil end
    return t[math.ceil(math.random(#t))]
end

LAYERS = enum({
    'sky',
    'comet',
    'buildings',
    'fireworks',
    'hills',
    'block',
    'dust',
    'angel',
    'food',
    'tongue',
    'points',
    'player',
    'text',
    'menu',
    'cursor',
    'frame',
})
