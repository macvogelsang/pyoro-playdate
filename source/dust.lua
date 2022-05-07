class('Dust').extends(playdate.graphics.sprite)

local LIFESPAN = 0.25 * REFRESH_RATE
local FRAME_DUR = LIFESPAN / 3

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local imgTable = playdate.graphics.imagetable.new('img/dust')
function Dust:init()
	Dust.super.init(self)
    self.lifespan = LIFESPAN 
    self:setImage(imgTable:getImage(1))
    self:setZIndex(LAYERS.dust)
    self:add()
end

function Dust:despawn()
    self:setVisible(false)
    self:setUpdatesEnabled(false)
end

function Dust:spawn(position)
    self.lifespan = LIFESPAN
    self:moveTo(position)
    self:setVisible(true)
    self:setUpdatesEnabled(true)
end

function Dust:update()
    self:setImage(imgTable:getImage(4 - math.ceil(self.lifespan / FRAME_DUR)))
    self.lifespan -= 1

    if self.lifespan <= 0 then
        self:despawn()
    end
end