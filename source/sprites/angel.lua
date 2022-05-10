
class('Angel').extends(gfx.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

-- constants
local FALL_VELOCITY = 360 
local DOWN, UP = 1, 2
local FLASH_CYCLE_LEN = 4 * FRAME_LEN

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local imgTable = gfx.imagetable.new('img/angel')
local imgOutlineTable = gfx.imagetable.new('img/angel-outline')

local OFFSET_DELAY = 300 -- time in milliseconds to offset angel falling
local RESTORE_SEQ = {1,2,3,4,5,4,5,4,5,4}

local spawnMonochrome = false

function Angel:init(blockIndex, xpos)
	Angel.super.init(self)

	self.speed = FALL_VELOCITY
	self.blockIndex = blockIndex

	self:setImage(imgTable:getImage(1, 1))
	self:setZIndex(LAYERS.angel)
	self:setCenter(0.5, 1)	

	self.initialPosition = Point.new(xpos, -20)
	self.velocity = vector2D.new(0, self.speed)
	self.position = Point.new(0,0)
	self:add()
	self:despawn()
end

function Angel:despawn()
	self.state = DOWN
	self.frame = 1
	self.velocity.y = self.speed
	self:setUpdatesEnabled(false)
	self:setVisible(false)
	self.position = self.initialPosition:copy()
	self:moveTo(self.initialPosition)
end

function Angel:spawn(offset)
	self.offset = offset or 1
	self.imgTable = spawnMonochrome and imgOutlineTable or imgTable
	playdate.timer.performAfterDelay(OFFSET_DELAY * (self.offset - 1), function() 
		self:setUpdatesEnabled(true)
		self:setVisible(true)
		SFX:play(SFX.kTenshi, true)
	end)
end

function Angel:reverse()
	-- play sound
	self.state = UP
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

	local monochromeTicker = globalScore.monochromeTicker
	if monochromeTicker > 0 then
		spawnMonochrome = true		
		if monochromeTicker >= self.blockIndex then
			self.imgTable = imgOutlineTable
		end
	else 
		spawnMonochrome = false	
	end

	self:moveTo(self.position)
	self:updateImage()

	self.frame = self.frame + 1

	if self.position.y <= -50 then
		self:despawn()
	end

end

function Angel:updateImage() 
	local imgCol = (self.frame % FLASH_CYCLE_LEN) < FLASH_CYCLE_LEN/2 and 1 or 2 
	self:setImage(self.imgTable:getImage(imgCol, self.state))
end


