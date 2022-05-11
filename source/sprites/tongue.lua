
class('Tongue').extends(gfx.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

-- constants
local EXTEND_VELOCITY = 200
local RETRACT_MULTIPLIER = -5
local TONGUE_WIDTH = 11
local SEGMENT_WIDTH = 10 -- lower width means more overlap between segment sprites
local MAX_SEGMENTS = PLAY_AREA_WIDTH / SEGMENT_WIDTH
-- local variables - these are "class local" but since we only have one tongue this isn't a problem
local minXPosition = X_LOWER_BOUND + TONGUE_WIDTH/2
local maxXPosition = X_UPPER_BOUND - TONGUE_WIDTH/2 

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local tongueImages = gfx.imagetable.new('img/tongue')

local function createSegment()
	local segment = gfx.sprite.new()
	segment:setImage(tongueImages:getImage(2))
	segment:setZIndex(LAYERS.tongue - 1)
	segment:setVisible(false)
	segment:setCenter(0.5,0.5)
	segment:add()
	return segment
end

local tonguePool = POOL.create( createSegment, MAX_SEGMENTS)

function Tongue:init(x, y, direction, withCrank)
	
	Tongue.super.init(self)

	self.direction = direction
	self:setImage(tongueImages:getImage(1), self.direction == RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped)
	self:setZIndex(LAYERS.tongue)
	self:setCenter(0.5, 0.5)	
	self:setCollideRect(1,1,12,12)
	self:setGroups({COLLIDE_TONGUE_GROUP})

	self.withCrank = withCrank or false
	self.crankChange = 0
	self.segments = {}
	
	self.startPosition = Point.new(x,y - 2) 
	self.position = self.startPosition:copy()
	self:moveTo(self.position)
	self.retracted = false
	self.retracting = false

	self.food = nil

	if direction == LEFT then
		self.velocity = vector2D.new(-EXTEND_VELOCITY,-EXTEND_VELOCITY)
	else
		self.velocity = vector2D.new(EXTEND_VELOCITY,-EXTEND_VELOCITY)
	end
	
	self:setVisible(false)
	self:add()
	if self.withCrank then
		self:setUpdatesEnabled(false)
	end

	SFX:play(SFX.kTongueOut)
end


function Tongue:reset()
	self.velocity = vector2D.new(0,0)
end

function Tongue:updateForCrank(crankPos, crankChange)
	local crankAmount = crankPos - 10
	self.position.y = self.startPosition.y - crankAmount
	self.position.x = self.startPosition.x + (self.direction * crankAmount)
	self.crankChange = crankChange
	self:update()
end

function Tongue:update()

	-- update tongue position based on current velocity
	if not self.withCrank or self.retracting then
		local velocityStep = self.velocity * DT 
		self.position = self.position + velocityStep
	end
	
	-- don't move outside the walls of the game
	if self.position.x < minXPosition then
		self:retract()
	elseif self.position.x > maxXPosition then
		self:retract()
	elseif self.position.y < 0 then
		self:retract()
	end

	self:moveTo(self.position)

	-- only draw tongue after it extends a bit
	if math.abs(self.position.y - self.startPosition.y) >= 10 then
		self:setVisible(true)
	end

	-- handle tongue segments (aka tongue extension)
	local numSegmentsFromStart = (math.abs(self.position.x - self.startPosition.x))/SEGMENT_WIDTH 
	if not self.retracting and self.crankChange >= 0 then
		self:drawSegmentsUntil(numSegmentsFromStart - 1)
	else
		self:removeSegmentsUntil(numSegmentsFromStart)
	end

	-- is the tongue retracted?
	if self.position.y > self.startPosition.y then
		self.retracted = true
		self:removeSegmentsUntil(0)
		self:remove()
	end

	-- is the tongue colliding?
	if not self.food then
		local collisions = self:overlappingSprites()
		if #collisions > 0 then
			self.food = table.remove(collisions)
			self:retract()
			self.food:capture(self.startPosition)
			SFX:play(SFX.kCatchFood)
		end
	end

	if self.food then
		self.food.position = self.position
	end

end

function Tongue:retract() 
	if not self.retracting then
		SFX:stop(SFX.kTongueOut)
		SFX:play(SFX.kTongueRetract)
		self.velocity = self.velocity * RETRACT_MULTIPLIER
		self.retracting = true
		self:clearCollideRect()
		if self.withCrank then
			self:setUpdatesEnabled(true)
		end
	end
end

function Tongue:drawSegmentsUntil(numSegments)
	local lastDrawnX = #self.segments > 0 and self.segments[#self.segments].x or self.startPosition.x
	local lastDrawnY = #self.segments > 0 and self.segments[#self.segments].y or self.startPosition.y

	while #self.segments < numSegments do
		local segment = tonguePool:obtain() 
		segment:setImage(tongueImages:getImage(2), self.direction == RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped)
		segment:moveTo(lastDrawnX + (self.direction * SEGMENT_WIDTH), lastDrawnY - SEGMENT_WIDTH)
		lastDrawnX = segment.x
		lastDrawnY = segment.y
		segment:setVisible(true)
		table.insert(self.segments, segment)
	end
end

function Tongue:removeSegmentsUntil(numSegments)
	while #self.segments > numSegments do 
		local segment = table.remove(self.segments)
		segment:setVisible(false)
		tonguePool:free(segment)
	end
end



function Tongue:hasFood() 
	return self.food ~= nil
end


