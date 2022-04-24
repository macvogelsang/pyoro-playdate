class('Block').extends(playdate.graphics.sprite)

local blockImg = playdate.graphics.image.new('img/block')

function Block:init(i)
    Block.super.init(self)
    self.blockIndex = i
    self.xPos = blockIndexToX(self.blockIndex) 
    self.xCenter = self.xPos + BLOCK_WIDTH/2
    self:setGroups({COLLIDE_BLOCK_GROUP})
    self:setCenter(0,0)
    self:place()
    self:add()
end

-- places the block at the bottom of the screen and sets its image
function Block:place()
    self.placed = true
    self.collided = false -- 'clean' this is a new block which hasn't touched the player
    self:setImage(blockImg)
    self:moveTo(self.xPos, 229)
    self:setCollideRect(0,0,BLOCK_WIDTH, BLOCK_WIDTH)
    player:resetBounds()
end

-- 'destroy' a block by making it invisible and shifting it up
function Block:destroy()
    if self.placed then
        self:setImage(nil)
        self:moveBy(0, -10)
        self.placed = false
    end
end
