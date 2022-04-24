
class('Player').extends(playdate.graphics.sprite)

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
local STAND, LOWER, CATCH, MUNCH, TURN, JUMP, CROUCH = 1, 2, 3, 4, 5, 6, 7
local MUNCH_TIME_SEC = 0.5
local MUNCH_SPEED = 6 -- how many long is each munch cycle

local INIT_X = 192
local INIT_Y = 228

-- timer used for player jumps
local jumpTimer = playdate.frameTimer.new(5, 45, 45, playdate.easingFunctions.outQuad)
jumpTimer:pause()
jumpTimer.discardOnCompletion = false

-- local variables - these are "class local" but since we only have one player this isn't a problem

local playerWidth = 19
local LEFT_WALL = X_LOWER_BOUND + playerWidth/2 
local RIGHT_WALL = X_UPPER_BOUND - playerWidth/2

local RUN_VELOCITY = 14 
local MAX_RUN_VELOCITY = 240


function Player:init()
	
	Player.super.init(self)

	self.playerImages = playdate.graphics.imagetable.new('img/player')
	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(1000)
	self:setCenter(0.5, 1)	-- set center point to center bottom middle
	self:moveTo(INIT_X, INIT_Y)
	self:setCollideRect(1,1,20,16)
	self:setGroups({COLLIDE_PLAYER_GROUP})
	self:setCollidesWithGroups({COLLIDE_BLOCK_GROUP})
	
	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self.animationIndex = 1
	self.frame = 1
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.munching = false

	self.minXPosition = LEFT_WALL 
	self.maxXPosition = RIGHT_WALL
	self.position = Point.new(INIT_X, INIT_Y)
	self.velocity = vector2D.new(0,0)
end


function Player:reset()
	self.position = Point.new(INIT_X, INIT_Y)
	self.velocity = vector2D.new(0,0)
end



-- function Player:collisionResponse(other)
-- 	if other:isa(Coin) or (other:isa(Enemy) and other.crushed == true) then
-- 		return "overlap"
-- 	end
	
-- 	return "slide"
-- end

-- called every frame, handles new input and does simple physics simulation
function Player:update()

	if self.tongue and self.tongue.retracted then
		local score = self.tongue:getScore()
		self.tongue = nil
		self.animationIndex = 1
		if score > 0 then
			self.munching = true
		end
	end

	if playdate.buttonIsPressed("left") and not self.tongue then
		self:runLeft()
	elseif playdate.buttonIsPressed("right") and not self.tongue then
		self:runRight()
	end

	if playdate.buttonJustPressed(playdate.kButtonA) and not self.tongue then
		self.velocity.x = 0
		self.tongueOut = true
		self.tongue = Tongue(self.position.x, self.position.y - 3, self.facing)
	end

	if playdate.buttonJustReleased(playdate.kButtonA) and self.tongue then
		self.tongue:retract()
	end

	if (playdate.buttonIsPressed("left") == false and playdate.buttonIsPressed("right") == false) then
		self.velocity.x = self.velocity.x * GROUND_FRICTION
	end

	-- set the maximum velocity based on if the O button is down or not
	if playdate.buttonIsPressed("B") then
		MAX_RUN_VELOCITY = 120
	else
		MAX_RUN_VELOCITY = 80
	end

	-- don't accellerate past max velocity
	if self.velocity.x > MAX_RUN_VELOCITY then self.velocity.x = MAX_RUN_VELOCITY
	elseif self.velocity.x < -MAX_RUN_VELOCITY then self.velocity.x = -MAX_RUN_VELOCITY
	end
	
	-- update the index used to control which frame of the run animation Player is in. Switch frames faster when running quickly.
	if abs(self.velocity.x) < 10 then
		self.velocity.x = 0
		-- runImageIndex = 1
	elseif abs(self.velocity.x) < 140 then
		self.animationIndex = self.animationIndex + 0.5
	else
		self.animationIndex = self.animationIndex + 1
	end

	if not self.munching then
		self.frame = 1
		if self.animationIndex > 2.5 then self.animationIndex = 1 end
	else
		self.frame = self.frame + 1
		if self.frame > REFRESH_RATE * MUNCH_TIME_SEC then
			self.munching = false
		end
		self.animationIndex = (self.frame % MUNCH_SPEED) < MUNCH_SPEED/2 and 1 or 4
	end
		
	-- update Player position based on current velocity
	local velocityStep = self.velocity * dt
	self.position = self.position + velocityStep
	
	-- don't move outside the walls of the game
	if self.position.x < self.minXPosition then
		self.velocity.x = 0
		self.position.x = self.minXPosition
	elseif self.position.x > self.maxXPosition then
		self.velocity.x = 0
		self.position.x = self.maxXPosition
	end
	
	self:updateImage()

end

-- sets the appropriate sprite image for Player based on the current conditions
function Player:updateImage()
	if self.tongue then
		self:setImage(self.playerImages:getImage(CATCH), self.flip)
	else
		if self.velocity.x == 0 then
			self:setImage(self.playerImages:getImage(floor(self.animationIndex)), self.flip)
		else
			self:setImage(self.playerImages:getImage(floor(self.animationIndex)), self.flip)
		end
	end
end

function Player:setMaxX(x)
	maxXPosition = x
end

function Player:runLeft()
	self.facing = LEFT
	self.flip = gfx.kImageUnflipped
	self.velocity.x = max(self.velocity.x - RUN_VELOCITY, -MAX_VELOCITY)
	self.munching = false
end

function Player:runRight()
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
	self.munching = false
end
