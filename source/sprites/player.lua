
class('Player').extends(playdate.graphics.sprite)

-- local references
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

-- constants
local dt = 0.033

local MAX_VELOCITY = 600
local GROUND_FRICTION = 0.8

local STAND, LOWER, CATCH, MUNCH, TURN, JUMP, CROUCH = 1, 2, 3, 4, 5, 6, 7
local MUNCH_TIME_SEC = 0.5

local WALK_CYCLE_LEN = 4 * FRAME_LEN
local MUNCH_CYCLE_LEN = 6 * FRAME_LEN -- how many frames long each munch cycle is
local DEATH_CYCLE_LEN = 10 * FRAME_LEN 
local PEAK_SPIT  = 5

local INIT_X = X_LOWER_BOUND + (PLAY_AREA_WIDTH / 2)
local INIT_Y = 228

-- local variables - these are "class local" but since we only have one player this isn't a problem
local playerWidth = 19
local LEFT_WALL = X_LOWER_BOUND + playerWidth/2 
local RIGHT_WALL = X_UPPER_BOUND - playerWidth/2

local RUN_VELOCITY = 14 
local MAX_RUN_VELOCITY = 240
local COLOR, MONO = 1, 2

local p1ImgTable = gfx.imagetable.new('img/player') 
local p2ImgTable = gfx.imagetable.new('img/player2')
local beagleImgTable = gfx.imagetable.new('img/beagle')

function Player:init()
	
	Player.super.init(self)

	self.tongueMode = game == BNB1
	self.imgTable = self.tongueMode and p1ImgTable or p2ImgTable
	self:setImage(self.imgTable:getImage(1,1))
	self:setZIndex(LAYERS.player)

	self:setCenter(0.5, 1)
	self:moveTo(INIT_X, INIT_Y)
	self:setGroups({COLLIDE_PLAYER_GROUP})

	if self.tongueMode then
		self:setCollideRect(1,1,18,18)
	else
		self:setCollideRect(9,11,19,18)
	end
	
	self.color = COLOR
	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self.animationIndex = 1
	self.frame = 1
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX

	self.action = nil
	self.spitTimer = 0
	self.munchTimer = 0

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

-- called every frame, handles new input and does simple physics simulation
function Player:update()

	if self.action then
		-- reset action if tongue retracted
		if type(self.action) == 'table' and self.action.retracted then
			if self:hasFoodOnTongue() then
				self.munchTimer = MUNCH_TIME_SEC * REFRESH_RATE
			end
			self.action = nil
		end
		-- reset action if done spitting
		if type(self.action) == 'boolean' and self.spitTimer == 0 then
			self.action = nil
		end
	end

	-- set control events
	if playdate.buttonIsPressed("left") and not self.action and not self.dead then
		self:runLeft()
	elseif playdate.buttonIsPressed("right") and not self.action and not self.dead then
		self:runRight()
	end

	if playdate.buttonJustPressed(playdate.kButtonA) and not self.action and not self.dead then
		self.velocity.x = 0

		if self.tongueMode then
			self.action = Tongue(self.position.x, self.position.y - 4, self.facing)
		else -- the spit action does not need a table
			self.action = true
			self.spitTimer = PEAK_SPIT
			SFX:play(SFX.kSpit)
		end
	end

	if playdate.buttonJustReleased(playdate.kButtonA) and self.action and not self.dead and self.tongueMode then
		self.action:retract()
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
	if #collisions > 0 and not self.dead then
		local food = table.remove(collisions)
		food:hit(NONGROUND)
		if not debugPlayerInvincible then
			self:die()
		end
	end

	-- don't accellerate past max velocity
	if self.velocity.x > MAX_RUN_VELOCITY then self.velocity.x = MAX_RUN_VELOCITY
	elseif self.velocity.x < -MAX_RUN_VELOCITY then self.velocity.x = -MAX_RUN_VELOCITY
	end
	

	-- update frame counter to control various animation timings
	self.frame += 1


	-- if not stopped, walking alternates between img 1 and 2
	if abs(self.velocity.x) < 10 then
		self.velocity.x = 0
	else
		local animateState = (self.frame % WALK_CYCLE_LEN) < WALK_CYCLE_LEN/2 
		self.animationIndex = animateState and 1 or 2
	end

	-- spit lasts four frames atm
	if self.spitTimer > 0 then
		self.animationIndex = self.spitTimer + 1
		if self.spitTimer <= 1 then
			self.animationIndex = 1
		end
		self.spitTimer -= 1
	end
	-- munching alternates between 1 and 4 
	if self.munchTimer > 0 then
		local animateState = (self.frame % MUNCH_CYCLE_LEN) < MUNCH_CYCLE_LEN/2 
		self.animationIndex = animateState and 4 or 1
		self.munchTimer -= 1
	end
	-- death alternates between 5 and 6
	if self.dead then
		local animateState = (self.frame % DEATH_CYCLE_LEN) < DEATH_CYCLE_LEN/2 
		self.animationIndex = animateState and 5 or 6
		self.imgTable = p1ImgTable
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
	
	if globalScore.monochromeTicker > 0 then
		self.color = MONO
	else
		self.color = COLOR
	end
	
	self:updateImage()

end

-- sets the appropriate sprite image for Player based on the current conditions
function Player:updateImage()
	local ai = self:hasTongue() and CATCH or floor(self.animationIndex)
	if math.abs(self.velocity.x) > 0 then
		if ai == 1 then
			SFX:play(SFX.kWalk)
		end
		if ai == 2 then
			SFX:play(SFX.kWalk2)
		end
	end
	self:setImage(self.imgTable:getImage(ai, self.color), self.flip)
end

function Player:hasTongue() 
	return type(self.action) == 'table' and self.spitTimer == 0
end

function Player:hasFoodOnTongue()
	if self:hasTongue() then
		return self.action:hasFood()
	else
		return false
	end
end

function Player:getFood()
	if self:hasFoodOnTongue() then
		return {self.action.food}, 'tongue'
	elseif self.spitTimer == PEAK_SPIT - 1 then
		local spitOrigin = Point.new(self.position.x, self.position.y - 8) 
		local xmax = self.facing == LEFT and X_LOWER_BOUND - spitOrigin.x or X_UPPER_BOUND - spitOrigin.x
		local ymax = spitOrigin.y - 0
		local dxdy = math.min(math.abs(ymax), math.abs(xmax))

		local hits = gfx.sprite.querySpritesAlongLine(spitOrigin.x, spitOrigin.y, spitOrigin.x + (self.facing * dxdy), spitOrigin.y - dxdy)
		local foods = {}
		for i, f in ipairs(hits) do
			if f.isFood then
				f:capture(self.position)
				table.insert(foods, f)
			end
		end
		return foods, 'spit'
	else
		return {}, nil
	end
end

function Player:runLeft()
	self.facing = LEFT
	self.flip = gfx.kImageUnflipped
	self.velocity.x = max(self.velocity.x - RUN_VELOCITY, -MAX_VELOCITY)
	self.munchTimer = 0 
end

function Player:runRight()
	self.facing = RIGHT
	self.flip = gfx.kImageFlippedX
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
	self.munchTimer = 0
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
