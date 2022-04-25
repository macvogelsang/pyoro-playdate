
class('Tongue').extends(playdate.graphics.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

-- constants
local EXTEND_VELOCITY = 200
local RETRACT_MULTIPLIER = -5
local TONGUE_WIDTH = 11
local SEGMENT_WIDTH = 5 -- lower width means more overlap between segment sprites

-- local variables - these are "class local" but since we only have one tongue this isn't a problem
local minXPosition = X_LOWER_BOUND + TONGUE_WIDTH/2
local maxXPosition = X_UPPER_BOUND - TONGUE_WIDTH/2 

-- contain a sprite for tongue end and a sprite to repeat for tongue segments
local tongueImages = playdate.graphics.imagetable.new('img/tongue')

function Tongue:init(x, y, direction)
	
	Tongue.super.init(self)

	self.direction = direction
	self:setImage(tongueImages:getImage(1), self.direction == RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped)
	self:setZIndex(900)
	self:setCenter(0.5, 0.5)	
	self:moveTo(x, y)
	self:setCollideRect(1,1,12,12)
	self:setGroups({COLLIDE_TONGUE_GROUP})

	self.segments = {}
	
	self.startPosition = Point.new(x,y) 
	self.position = Point.new(x, y)
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
end


function Tongue:reset()
	-- self.position = Point.new(INIT_X, INIT_Y)
	self.velocity = vector2D.new(0,0)
end


function Tongue:update()

	-- update tongue position based on current velocity
	local velocityStep = self.velocity * DT 
	self.position = self.position + velocityStep
	self.position.x = self.direction == LEFT and math.floor(self.position.x) or math.ceil(self.position.x)
	self.position.y = math.floor(self.position.y)
	
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
	if not self.retracting then
		self:drawSegment()
	else
		local numSegmentsFromStart = math.abs(self.position.x - self.startPosition.x)/SEGMENT_WIDTH
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
		end
	end

	if self.food then
		self.food.position = self.position
	end

end

function Tongue:retract() 
	if not self.retracting then
		self.velocity = self.velocity * RETRACT_MULTIPLIER
		self.retracting = true
		self:clearCollideRect()
	end
end

function Tongue:drawSegment()
	if math.abs(self.position.x - self.startPosition.x)/SEGMENT_WIDTH > #self.segments then
		local segment = gfx.sprite.new()
		segment:setImage(tongueImages:getImage(2), self.direction == RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped)
		segment:moveTo(self.position.x, self.position.y)
		segment:setZIndex(890)
		segment:add()
		table.insert(self.segments, segment)
	end
end

function Tongue:removeSegmentsUntil(numSegments)
	while #self.segments > numSegments do 
		local segment = table.remove(self.segments)
		segment:remove()
	end
end

function Tongue:hasFood() 
	return self.food ~= nil
end


