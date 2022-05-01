
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

local OFFSET_DELAY = 0.3 * REFRESH_RATE -- time in seconds to offset angel falling
local RESTORE_SEQ = {1,2,3,4,5,4,5,4,5,4}

local spawn_monochrome = false

function Angel:init(block, offset)
	
	Angel.super.init(self)

	self.speed = FALL_VELOCITY
	self.offset = offset or 1
	self.startFrame = offset and (offset - 1) * OFFSET_DELAY or 1
	self.frame = 1
	self.imgTable = spawn_monochrome and imgOutlineTable or imgTable
	self.block = block

	self.state = DOWN

	self:setImage(imgTable:getImage(1, self.state))

	self:setZIndex(LAYERS.angel)
	self:setCenter(0.5, 1)	

	self.position = Point.new(block.xCenter, -20)
	self.velocity = vector2D.new(0, self.speed)

	self:moveTo(self.position)
	self:add()

	self.playedSound = false	
end

function Angel:reverse()
	-- play sound
	self.state = UP
	self.block:place()
	self.velocity = self.velocity * -1 
	SFX:play({'restore' .. tostring(RESTORE_SEQ[self.offset])}, true)
end

function Angel:update()
	if self.frame >= self.startFrame then
		if not self.playedSound then
			SFX:play(SFX.kTenshi, true)
			self.playedSound = true
		end

		local velocityStep = self.velocity * DT 
		self.position = self.position + velocityStep
		
		-- don't move outside the walls of the game
		if self.position.y >= 238 then
			self:reverse()
		end

		self:moveTo(self.position)
		self:updateImage()
	end

	self.frame = self.frame + 1

	if self.position.y <= -50 then
		self:remove()
		self = nil
	end

	GameState:subscribe('monochrome', self, function(is_monochrome)
        if is_monochrome then
            self.imgTable = imgOutlineTable
			spawn_monochrome = true
        end
    end)

end

function Angel:updateImage() 
	local imgCol = (self.frame % FLASH_CYCLE_LEN) < FLASH_CYCLE_LEN/2 and 1 or 2 
	self:setImage(self.imgTable:getImage(imgCol, self.state))
end


