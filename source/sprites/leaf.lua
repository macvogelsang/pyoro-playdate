class('Leaf').extends(AnimatedSprite)

local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D
local leavesTable = gfx.imagetable.new('img/leaves')
local SMALL_LEAF, BIG_LEAF = 1, 2
local AIR_RESISTANCE = 0.82
function Leaf:init(size)
    Leaf.super.init(self, leavesTable)

	self.isLeaf = true
	self.size = size

    local config = {tickStep = 9, loop = true, yoyo = true, animationStartingFrame = math.random(1,3)}
	if self.size == BIG_LEAF then
		self:addState(BIG_LEAF, 1, 3, config, true)
		-- self.leaves = {Leaf(SMALL_LEAF), Leaf(SMALL_LEAF)}
		self:setCollideRect(1, 1, 11, 8)
	else
		self:addState(SMALL_LEAF, 4, 6, config)
		self:setCollideRect(3, 3, 7, 6)
	end

	self.position = Point.new(0, 0)
	self.fallSpeed = 0
	self.velocity = vector2D.new(0, 0)
	self.smallLeafOffset = vector2D.new(10, 10)
	self.spawned = false

	self:setCollidesWithGroups(COLLIDE_NOTHING_GROUP)
	self:setVisible(false)
	self:setUpdatesEnabled(false)
	self:setCenter(0.5, 1)
	self:setZIndex(LAYERS.leaves)
	self:add()

end

function Leaf:spawn(pos, fallSpeed, velocity)
	self.position = pos
	self.fallSpeed = fallSpeed
	self.spawned = true
	self:moveTo(self.position)
	self:setVisible(true)
	self:setUpdatesEnabled(true)
	self:playAnimation()

	-- random chance to fall faster
	if math.random() < 0.4 then
		self.fallSpeed *= 1.15
	end

	self.velocity.y = fallSpeed
	if velocity then
		self.velocity = velocity
	end
end

function Leaf:destroy(atGround)
	self:setVisible(false)
	self:stopAnimation()
	self.spawned = false

	if self.size == BIG_LEAF and not atGround then
		-- local secondLeafOffset = self.smallLeafOffset:scaledBy(math.random(-1,1))
		local leaf1 = Leaf(SMALL_LEAF)
		leaf1:spawn(self.position, self.fallSpeed, self.velocity)
		-- local leaf2 = Leaf(SMALL_LEAF)
		-- leaf2:spawn(self.position + secondLeafOffset, self.fallSpeed, self.velocity)
	end

	self:remove()
end

function Leaf:update()
	self:updateAnimation()
	local velocityStep = self.velocity * DT 
	self.position = self.position + velocityStep

	if self.velocity.y >= -10 then
		self.velocity.x = 0
		self.velocity.y = self.fallSpeed
	end
	if self.velocity.y < 0 then
		self.velocity = self.velocity * AIR_RESISTANCE
	end
	
	-- made it to ground level
	if self.position.y >= 240 then
		self:destroy(true)
	end

	self:moveTo(self.position)
end