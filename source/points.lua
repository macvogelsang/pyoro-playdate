class('Points').extends(playdate.graphics.sprite)

local imgTable = playdate.graphics.imagetable.new('img/scores')
local FLASH_FRAMES = 3

function Points:init(value, position, flashing)
    Points.super.init(self) 
    self.flashing = flashing
    self.value = value
    local imgY = 1
    if self.value == 10 then
        imgY = 1
    elseif self.value == 50 then
        imgY =  2
    elseif self.value == 100 then
        imgY = 3
    elseif self.value == 300 then
        imgY = 4
    elseif self.value == 1000 then
        imgY = 5
    end

    self.lifespan = REFRESH_RATE * 0.5

    self:setImage(imgTable:getImage(1, imgY))
    self:setCenter(0.5, 0.5)
    self:moveTo(position)
	self:setZIndex(960)
    self:add()
end

function Points:update()
    if (self.value >= 300 or self.flashing) and self.lifespan % FLASH_FRAMES == 0 then
        self:setImage(self:getImage():invertedImage())
    end

    self.lifespan -= 1

    if self.lifespan <= 0 then
        self:remove()
        self = nil
    end
end