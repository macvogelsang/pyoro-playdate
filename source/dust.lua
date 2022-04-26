class('Dust').extends(playdate.graphics.sprite)

local LIFESPAN = 0.25 * REFRESH_RATE
local FRAME_DUR = LIFESPAN / 3

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local imgTable = playdate.graphics.imagetable.new('img/dust')
function Dust:init(position)
	Dust.super.init(self)
    self.lifespan = LIFESPAN 
    self:setImage(imgTable:getImage(1))
    self:moveTo(position)
    self:add()
end

function Dust:update()
    self:setImage(imgTable:getImage(4 - math.ceil(self.lifespan / FRAME_DUR)))
    self.lifespan -= 1

    if self.lifespan <= 0 then
        self:remove() 
        self = nil
    end
end