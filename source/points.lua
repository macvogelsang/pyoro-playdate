class('Points').extends(playdate.graphics.sprite)

local imgTable = playdate.graphics.imagetable.new('img/scores')
local FLASH_FRAMES = 3
local OFFSET_DELAY = 0.05 * REFRESH_RATE -- time in seconds to offset points popping 

function Points:init(value, position, flashing, offset)
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

    self.startFrame = offset and (offset - 1) * OFFSET_DELAY or 0
    self.frame = 1
    self.lifespan = REFRESH_RATE * 0.5
    self.playedSound = false

    self:setImage(imgTable:getImage(1, imgY))
    self:setCenter(0.5, 0.5)
    self:moveTo(position)
	self:setZIndex(LAYERS.points)

    self:add()
    self:setVisible(false)
end

function Points:update()
    self.frame += 1
    if self.frame >= self.startFrame then

        self:setVisible(true)

        if self.flashing and not self.playedSound then
            SFX:play(SFX.kPoints50, true)
            self.playedSound = true
        end

        if (self.value >= 300 or self.flashing) and self.lifespan % FLASH_FRAMES == 0 then
            self:setImage(self:getImage():invertedImage())
        end

        self.lifespan -= 1

        if self.lifespan <= 0 then
            self:remove()
            self = nil
        end
    end
end