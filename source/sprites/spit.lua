
class('Spit').extends(AnimatedSprite)

local spitTable= gfx.imagetable.new('img/spit')
local SPIT_WIDTH = 80

function Spit:init()
    Spit.super.init(self, spitTable)

    local config = {tickStep = 1, loop = false,  onAnimationEndEvent = (function (self) self:setVisible(false) end)}
	self:addState(1, 1, 10, config)
	self:addState(2, 11, 20, config)
	self:addState(3, 21, 30, config)
	self:addState(4, 31, 40, config)
	self:setVisible(false)
	self:setCenter(0.5, 1)
	self:setZIndex(LAYERS.dust)
	self:add()

    self.inUse = false
end

function Spit:spawn(facing, playerPos)
    self.globalFlip = facing == LEFT and 0 or 1
	self:changeState(math.random(1,4))
	self:moveTo(playerPos.x + (facing * SPIT_WIDTH/2), playerPos.y - 8)
	self:setVisible(true)
	self:playAnimation()
    self.inUse = true
end