class('Food').extends(playdate.graphics.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

-- constants
local FOOD_WIDTH = 20
local FALL_VELOCITY = {SLOW=40, MED=60, FAST=100} 
local FRAME_DUR = BAGEL_MODE and REFRESH_RATE // 10 or REFRESH_RATE // 3
local NUM_FRAMES = BAGEL_MODE and 6 or 4

local minXPosition = X_LOWER_BOUND + FOOD_WIDTH/2
local maxXPosition = X_UPPER_BOUND - FOOD_WIDTH/2 

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local foodTable = BAGEL_MODE and playdate.graphics.imagetable.new('img/bagel') or playdate.graphics.imagetable.new('img/seed') 
local foodOutlineTable = playdate.graphics.imagetable.new('img/seed-outline') 

local spawnMonochrome = false

function Food:init()
	
	Food.super.init(self)

	self.isFood = true
	self.type = NORMAL
	self.speed = 0 

	self.frame = 1
	self.animationIndex = 1 --math.random(#ANIMATION_SEQ)
	self.imgRow = 1 
	self.blockIndex = 1 

	self.imgTable = foodTable
	self:setImage(self.imgTable:getImage(1, self.imgRow))
	self:setZIndex(LAYERS.food)
	self:setCenter(0.5, 0.5)	

	self.captured = false 
	self.capturedPosition = nil
	self.scored = false
	self.endPosition = Point.new(0,0) 

	self.position = Point.new(0, 0)
	self.velocity = vector2D.new(0, 0)

	self.points = Points()
	self.dust = Dust()
	self:add()
	self:setVisible(false)
	self:setUpdatesEnabled(false)
end

function Food:spawn(foodType, speed, blockIndex)
	self.type = foodType
	self.blockIndex = blockIndex
	self.speed = speed
	self.hitGround = false
	self.delete = false
	self.scored = false
	self.position.x = BLOCKS[self.blockIndex].xCenter + 1
	self.position.y = 0
	self.velocity.y = self.speed
	self.imgRow = self.type
	if self.imgRow > 2 then
		self.imgRow = 2
	end
	self.imgTable = spawnMonochrome and foodOutlineTable or foodTable
	self:setImage(self.imgTable:getImage(1, self.imgRow))
	self:setCollideRect(4,1,12,18)
	self:setCollidesWithGroups({COLLIDE_PLAYER_GROUP, COLLIDE_TONGUE_GROUP})
	if debugHarmlessFoodOn then
		self:setCollidesWithGroups({COLLIDE_TONGUE_GROUP})
	end
	self:moveTo(self.position)
	self:setVisible(true)
	self:setUpdatesEnabled(true)
end

function Food:capture(endPosition)
	SFX:play(SFX.kCatchFood)
	self.velocity = vector2D.new(0, 0) 
	self.endPosition = endPosition
	self.capturedPosition = self.position
	self.captured = true
	self:clearCollideRect()
end

function Food:hit(how, direction)
	if how == GROUND or debugHarmlessFoodOn then
		self.hitGround = true
	end

	if self.hitGround then
		BLOCKS[self.blockIndex]:destroy()
	end

	if how == SPIT then
		self.dust:spawn(self.position, direction)
	else
		self.dust:spawn(self.position)
	end
	self:cleanup()
end

function Food:cleanup()
	self.velocity = vector2D.new(0, 0) 
	self.delete = true
	self.captured = false
	self.animationIndex = 1
	self:clearCollideRect()
	self:setVisible(false)
	self:setUpdatesEnabled(false)
end

function Food:update()

	local velocityStep = self.velocity * DT 
	self.position = self.position + velocityStep
	
	-- made it to ground level
	if self.position.y >= 223 and not self.captured and BLOCKS[self.blockIndex].placed then
		self:hit(GROUND)
	end

	if (self.captured and (self.position.y >= self.endPosition.y - 10)) or 
		self.position.y >= 250 then
		self:cleanup()
	end

	self:moveTo(self.position)
	self:updateImage()

	if self.frame % FRAME_DUR == 0 then 
		self.animationIndex += 1
		if self.animationIndex > NUM_FRAMES then
			self.animationIndex = 1
		end
	end
	self.frame += 1

	if globalScore.monochromeTicker > 0 then
		-- self.imgTable = foodOutlineTable
		spawnMonochrome = true
	else
		self.imgTable = foodTable
		-- spawnMonochrome = false
	end
end

function Food:updateImage() 
	if not self.captured then
		if self.type == 3 then
			self.imgRow = self.frame % 8 < 4 and 1 or 2
		end
		self:setImage(self.imgTable:getImage(self.animationIndex, self.imgRow))
	else
		self:setImage(self.imgTable:getImage(1, self.imgRow))
	end
end

