class('Block').extends(playdate.graphics.sprite)

local blockImg = playdate.graphics.image.new('img/block')

function Block:init(xPos)
    Block.super.init(self)
    self.collided = false -- has this block collided with a player yet?
    self.xPos = xPos 
    self:setGroups({COLLIDE_BLOCK_GROUP})
    self:setCenter(0,0)
    self:place()
    self:add()
end

-- places the block at the bottom of the screen and sets its image
function Block:place()
    self.placed = true
    self:setImage(blockImg)
    self:moveTo(self.xPos, 229)
    self:setCollideRect(0,0,BLOCK_WIDTH, BLOCK_WIDTH)
end

-- 'destroy' a block by making it invisible and shifting it up
function Block:destroy()
    if self.placed then
        self:setImage(nil)
        self:moveBy(0, -10)
        self.placed = false
    end
end
