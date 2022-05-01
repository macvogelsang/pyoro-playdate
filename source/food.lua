import 'dust'

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

local spawn_monochrome = false

function Food:init(foodType, speed, blockRef)
	
	Food.super.init(self)

	self.type = foodType
	self.speed = FALL_VELOCITY[speed]
	self.frame = 1
	self.animationIndex = 1 --math.random(#ANIMATION_SEQ)
	self.imgTable = spawn_monochrome and foodOutlineTable or foodTable
	self.imgRow = foodType 
	self.blockRef = blockRef

	if self.imgRow > 2 then
		self.imgRow = 2
	end

	self:setImage(self.imgTable:getImage(1, self.imgRow))

	self:setZIndex(LAYERS.food)
	self:setCenter(0.5, 0.5)	
	self:setCollideRect(4,1,12,18)
	self:setCollidesWithGroups({COLLIDE_PLAYER_GROUP, COLLIDE_TONGUE_GROUP})
	if debugHarmlessFoodOn then
		self:setCollidesWithGroups({COLLIDE_TONGUE_GROUP})
	end

	self.captured = false 
	self.capturedPosition = nil
	self.scored = false
	self.endPosition = Point.new(0,0) 

	self.position = Point.new(self.blockRef.xCenter + 1, 0)
	self.velocity = vector2D.new(0, self.speed)

	self:moveTo(self.position)
	self:add()
end


function Food:capture(endPosition)
	SFX:play(SFX.kCatchFood)
	self.velocity = vector2D.new(0, 0) 
	self.endPosition = endPosition
	self.capturedPosition = self.position
	self.captured = true
	self:clearCollideRect()
end

function Food:hit(ground)
	self.hitGround = debugHarmlessFoodOn and true or ground 
	Dust(self.position)	
	self:cleanup()
end

function Food:cleanup()
	self.velocity = vector2D.new(0, 0) 
	self.delete = true
	self:remove()
end

function Food:update()

	local velocityStep = self.velocity * DT 
	self.position = self.position + velocityStep
	
	-- made it to ground level
	if self.position.y >= 229 and not self.captured and self.blockRef.placed then
		self:hit(true)
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

	GameState:subscribe('monochrome', self, function(is_monochrome)
        if is_monochrome then
            self.imgTable = foodOutlineTable
			spawn_monochrome = true
        end
    end)
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


