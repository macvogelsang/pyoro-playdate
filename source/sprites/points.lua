class('Points').extends(gfx.sprite)

local imgTable = gfx.imagetable.new('img/scores')
local FLASH_FRAMES = 3
local OFFSET_DELAY = 0.05 * REFRESH_RATE -- time in seconds to offset points popping 

function Points:init(value, position, flashing, offset)
    Points.super.init(self) 

    self:setCenter(0.5, 0.5)
	self:setZIndex(LAYERS.points)
    self:setImage(imgTable:getImage(1, 1))
    self:add()
    self:despawn()
end

function Points:spawn(value, position, flashing, offset)

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
    self:moveTo(position)
    self.playedSound = false

    self:setVisible(true)
    self:setUpdatesEnabled(true)
end

function Points:despawn()
    self:setVisible(false)
    self:setUpdatesEnabled(false)
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
            self:despawn()
        end
    end
end