class('Dust').extends(gfx.sprite)

local LIFESPAN = 0.25 * REFRESH_RATE
local DUST_FRAMES = 3
local BIG_DUST_FRAMES = 8
local DUST_FRAME_DUR = LIFESPAN / DUST_FRAMES
local BIG_DUST_FRAME_DUR = LIFESPAN / BIG_DUST_FRAMES

local DIRECTIONAL_OFFSET = 10

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local dustTable = gfx.imagetable.new('img/dust')
local bigDustTable = gfx.imagetable.new('img/dust2')

function Dust:init()
	Dust.super.init(self)
    self.direction = 0
    self.bigDust = false
    self.lifespan = LIFESPAN 
    self:setImage(dustTable:getImage(1))
    self:setZIndex(LAYERS.dust)
    self:add()
end

function Dust:despawn()
    self:setVisible(false)
    self:setUpdatesEnabled(false)
end

function Dust:spawn(position, direction)
    self.lifespan = LIFESPAN
    self.direction = direction or 0 
    if self.direction ~= 0 then
        self:moveTo(position.x + (self.direction * DIRECTIONAL_OFFSET), position.y - DIRECTIONAL_OFFSET)
    else
        self:moveTo(position)
    end
    self:setVisible(true)
    self:setUpdatesEnabled(true)
end

function Dust:update()
    if self.direction ~= 0 then
        self:setImage(bigDustTable:getImage(BIG_DUST_FRAMES + 1 - math.ceil(self.lifespan / BIG_DUST_FRAME_DUR)), self.direction == LEFT and gfx.kImageUnflipped or gfx.kImageFlippedX)
    else
        self:setImage(dustTable:getImage(DUST_FRAMES + 1 - math.ceil(self.lifespan / DUST_FRAME_DUR)))
    end

    self.lifespan -= 1

    if self.lifespan <= 0 then
        self:despawn()
    end
end