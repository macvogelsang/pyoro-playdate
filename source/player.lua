
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

local INIT_X = 192
local INIT_Y = 228

-- timer used for player jumps
local jumpTimer = playdate.frameTimer.new(5, 45, 45, playdate.easingFunctions.outQuad)
jumpTimer:pause()
jumpTimer.discardOnCompletion = false

-- local variables - these are "class local" but since we only have one player this isn't a problem

playerStates = {}
local playerWidth = 19
local minXPosition = X_LOWER_BOUND + playerWidth/2
local maxXPosition = X_UPPER_BOUND - playerWidth/2

local RUN_VELOCITY = 14 
local MAX_RUN_VELOCITY = 240
local runImageIndex = 1


function Player:init()
	
	Player.super.init(self)

	self.playerImages = playdate.graphics.imagetable.new('img/player')
	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(1000)
	self:setCenter(0.5, 1)	-- set center point to center bottom middle
	self:moveTo(INIT_X, INIT_Y)
	self:setCollideRect(0,0,18,18)
	
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.tongueOut = false

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
		self.tongueOut = false
		self.tongue = nil
		runImageIndex = 1
	end

	if playdate.buttonIsPressed("left") and not self.tongueOut then
		self:runLeft()
	elseif playdate.buttonIsPressed("right") and not self.tongueOut then
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
		runImageIndex = runImageIndex + 0.5
	else
		runImageIndex = runImageIndex + 1
	end
	
	if runImageIndex > 2.5 then runImageIndex = 1 end
		
	-- update Player position based on current velocity
	local velocityStep = self.velocity * dt
	self.position = self.position + velocityStep
	
	-- don't move outside the walls of the game
	if self.position.x < minXPosition then
		self.velocity.x = 0
		self.position.x = minXPosition
	elseif self.position.x > maxXPosition then
		self.velocity.x = 0
		self.position.x = maxXPosition
	end
	
	self:updateImage()

end


-- sets the appropriate sprite image for Player based on the current conditions
function Player:updateImage()
	if self.tongueOut then
		self:setImage(self.playerImages:getImage(CATCH), self.flip)
	else
		if self.velocity.x == 0 then
			self:setImage(self.playerImages:getImage(floor(runImageIndex)), self.flip)
		else
			self:setImage(self.playerImages:getImage(floor(runImageIndex)), self.flip)
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
end

function Player:runRight()
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
end
