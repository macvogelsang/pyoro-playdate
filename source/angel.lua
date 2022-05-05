
class('Angel').extends(playdate.graphics.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

-- constants
local FALL_VELOCITY = 360 
local DOWN, UP = 1, 2
local FLASH_CYCLE_LEN = 4 * FRAME_LEN

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local imgTable = playdate.graphics.imagetable.new('img/angel')
local imgOutlineTable = playdate.graphics.imagetable.new('img/angel-outline')

local OFFSET_DELAY = 300 -- time in milliseconds to offset angel falling
local RESTORE_SEQ = {1,2,3,4,5,4,5,4,5,4}

local spawnMonochrome = false

function Angel:init(block, offset)
	
	Angel.super.init(self)

	self.speed = FALL_VELOCITY
	self.offset = offset or 1
	self.frame = 1
	self.imgTable = spawnMonochrome and imgOutlineTable or imgTable
	self.block = block

	self.state = DOWN

	self:setImage(imgTable:getImage(1, self.state))

	self:setZIndex(LAYERS.angel)
	self:setCenter(0.5, 1)	

	self.position = Point.new(block.xCenter, -20)
	self.velocity = vector2D.new(0, self.speed)

	self:moveTo(self.position)

	playdate.timer.performAfterDelay(OFFSET_DELAY * (self.offset - 1), function() 
		self:spawn()
	end)

end

function Angel:spawn()
	self:add()
	SFX:play(SFX.kTenshi, true)
end

function Angel:reverse()
	-- play sound
	self.state = UP
	self.block:place()
	self.velocity = self.velocity * -1 
	SFX:play({'restore' .. tostring(RESTORE_SEQ[self.offset])}, true)
end

function Angel:update()

	local velocityStep = self.velocity * DT 
	self.position = self.position + velocityStep
	
	-- don't move outside the walls of the game
	if self.position.y >= 238 then
		self:reverse()
	end

	if globalScore.monochromeMode then
		self.imgTable = imgOutlineTable
		spawnMonochrome = true
	else
		self.imgTable = imgTable
		spawnMonochrome = false
	end

	self:moveTo(self.position)
	self:updateImage()

	self.frame = self.frame + 1

	if self.position.y <= -50 then
		self:remove()
		self.imgTable = imgTable
		self = nil
	end


end

function Angel:updateImage() 
	local imgCol = (self.frame % FLASH_CYCLE_LEN) < FLASH_CYCLE_LEN/2 and 1 or 2 
	self:setImage(self.imgTable:getImage(imgCol, self.state))
end


