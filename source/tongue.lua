
class('Tongue').extends(playdate.graphics.sprite)


-- local references
local Point = playdate.geometry.point
local Rect = playdate.geometry.rect
local vector2D = playdate.geometry.vector2D
local affineTransform = playdate.geometry.affineTransform
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

-- constants
local dt = 0.033

local MAX_VELOCITY = 600
local SPEED_OF_RUNNING = 50			-- thea velocity at which we decide the player is running rather than walking
local GROUND_FRICTION = 0.8
local STAND, RUN1, RUN2, RUN3, TURN, JUMP, CROUCH = 1, 2, 3, 4, 5, 6, 7


-- timer used for player jumps
-- local jumpTimer = playdate.frameTimer.new(5, 45, 45, playdate.easingFunctions.outQuad)
-- jumpTimer:pause()
-- jumpTimer.discardOnCompletion = false

-- local variables - these are "class local" but since we only have one player this isn't a problem
local tongueWidth = 11
local segmentWidth = 7
local minXPosition = X_LOWER_BOUND + tongueWidth/2
local maxXPosition = X_UPPER_BOUND - tongueWidth/2 

playerStates = {}
local spriteHeight = 32
local facing = RIGHT
local RUN_VELOCITY = 14 
local MAX_RUN_VELOCITY = 240
local runImageIndex = 1
local tongueImages = playdate.graphics.imagetable.new('img/tongue')

local EXTEND_VELOCITY = 120
local RETRACT_VELOCITY = 180

function Tongue:init(x, y, direction)
	
	Tongue.super.init(self)

	self.direction = direction
	self:setImage(tongueImages:getImage(1), self.direction == RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped)
	self:setZIndex(900)
	self:setCenter(0.5, 0.5)	
	self:moveTo(x, y)
	-- self:setCollideRect(0,0,18,18)

	self.segments = {}
	
	self.startPosition = Point.new(x,y) 
	self.position = Point.new(x, y)
	self.retracted = false
	self.retracting = false
	self.canCollide = true

	if direction == LEFT then
		self.velocity = vector2D.new(-EXTEND_VELOCITY,-EXTEND_VELOCITY)
	else
		self.velocity = vector2D.new(EXTEND_VELOCITY,-EXTEND_VELOCITY)
	end

	self:add()
	
end


function Tongue:reset()
	-- self.position = Point.new(INIT_X, INIT_Y)
	self.velocity = vector2D.new(0,0)
end


-- called every frame, handles new input and does simple physics simulation
function Tongue:update()

	-- update tongue position based on current velocity
	local velocityStep = self.velocity * dt
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

	if not self.retracting then
		self:drawSegment()
	else
		local numSegmentsFromStart = abs(self.position.x - self.startPosition.x)/segmentWidth
		self:removeSegmentsUntil(numSegmentsFromStart)
	end

	if self.position.y > self.startPosition.y then
		self.retracted = true
		self:removeSegmentsUntil(0)
		self:remove()
	end

end

function Tongue:retract() 
	if not self.retracting then
		self.velocity = self.velocity * -4
		self.canCollide = false
		self.retracting = true
	end
end


function Tongue:drawSegment()
	if abs(self.position.x - self.startPosition.x)/segmentWidth > #self.segments then
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


