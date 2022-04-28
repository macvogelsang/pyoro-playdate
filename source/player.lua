
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
local MUNCH_CYCLE_LEN = 6 * FRAME_LEN -- how many frames long each munch cycle is
local DEATH_CYCLE_LEN = 10 * FRAME_LEN 
local INIT_X = 192
local INIT_Y = 228

-- local variables - these are "class local" but since we only have one player this isn't a problem
local playerWidth = 19
local LEFT_WALL = X_LOWER_BOUND + playerWidth/2 
local RIGHT_WALL = X_UPPER_BOUND - playerWidth/2

local RUN_VELOCITY = 14 
local MAX_RUN_VELOCITY = 240


function Player:init()
	
	Player.super.init(self)

	self.playerImages = BAGEL_MODE and gfx.imagetable.new('img/beagle') or gfx.imagetable.new('img/player')
	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(LAYERS.player)
	self:setCenter(0.5, 1)	-- set center point to center bottom middle
	self:moveTo(INIT_X, INIT_Y)
	self:setGroups({COLLIDE_PLAYER_GROUP})
	
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

function Player:resetMinXPosition()
	self.minXPosition = LEFT_WALL 
end

function Player:resetMaxXPosition()
	self.maxXPosition = RIGHT_WALL
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
		if self.tongue:hasFood() then
			self.munching = true
		end
		self.tongue = nil
		self.animationIndex = 1
	end

	-- set control events
	if playdate.buttonIsPressed("left") and not self.tongue and not self.dead then
		self:runLeft()
	elseif playdate.buttonIsPressed("right") and not self.tongue and not self.dead then
		self:runRight()
	end

	if playdate.buttonJustPressed(playdate.kButtonA) and not self.tongue and not self.dead then
		self.velocity.x = 0
		self.tongueOut = true
		self.tongue = Tongue(self.position.x, self.position.y - 4, self.facing)
	end

	if playdate.buttonJustReleased(playdate.kButtonA) and self.tongue and not self.dead then
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

	-- collision check
	local collisions = self:overlappingSprites()
	if #collisions > 0 then
		local food = table.remove(collisions)
		food:hit(false)
		if not debugPlayerInvincible then
			self:die()
		end
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

	if not self.munching and not self.dead then
		self.frame = 1
		if self.animationIndex > 2.5 then self.animationIndex = 1 end
	else
		self.frame = self.frame + 1
		if self.frame > REFRESH_RATE * MUNCH_TIME_SEC then
			self.munching = false
		end

		if self.munching then
			local animateState = (self.frame % MUNCH_CYCLE_LEN) < MUNCH_CYCLE_LEN/2 
			self.animationIndex = animateState and 1 or 4
		end
		if self.dead then
			local animateState = (self.frame % DEATH_CYCLE_LEN) < DEATH_CYCLE_LEN/2 
			self.animationIndex = animateState and 5 or 6
		end
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
	local ai = floor(self.animationIndex)
	if math.abs(self.velocity.x) > 0 then
		if ai == 1 then
			SFX:play(SFX.kWalk)
		end
		if ai == 2 then
			SFX:play(SFX.kWalk2)
		end
	end
	if self.tongue then
		self:setImage(self.playerImages:getImage(CATCH), self.flip)
	elseif self.dead then 
		self:setImage(self.playerImages:getImage(ai), self.flip)
	else
		self:setImage(self.playerImages:getImage(ai), self.flip)
	end
end

function Player:hasTongue() 
	return self.tongue ~= nil
end

function Player:runLeft()
	self.facing = LEFT
	self.flip = gfx.kImageUnflipped
	self.velocity.x = max(self.velocity.x - RUN_VELOCITY, -MAX_VELOCITY)
	self.munching = false
	if BAGEL_MODE then
		self:setCollideRect(2,3,18,16)
	else
		self:setCollideRect(1,1,18,18)
	end
end

function Player:runRight()
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
	self.munching = false
	self:setCollideRect(3,3,18,16)
	if BAGEL_MODE then
		self:setCollideRect(3,3,18,16)
	else
		self:setCollideRect(1,1,18,18)
	end
end

function Player:die()
	BGM:play(BGM.kPlayerDie)
	self.dead = true
	if BAGEL_MODE then
		self.velocity = vector2D.new(0,0)
	else
		self.velocity =vector2D.new(0, 30)
	end
end
