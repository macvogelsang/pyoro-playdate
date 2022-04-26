class('Block').extends(playdate.graphics.sprite)

local blockImg = playdate.graphics.image.new('img/block')

function Block:init(i)
    Block.super.init(self)
    self.blockIndex = i
    self.xPos = blockIndexToX(self.blockIndex) 
    self.xCenter = self.xPos + BLOCK_WIDTH/2
    self:setCenter(0,0)
    self:place()
    self:add()
end

-- places the block at the bottom of the screen and sets its image
function Block:place()
    self.placed = true
    self:setImage(blockImg)
    self:setVisible(true)
    self:moveTo(self.xPos, 229)
    doBoundCalculation = true
end

-- 'destroy' a block by making it invisible
function Block:destroy()
    SFX:play(SFX.kTileDestroy, true)
    self:setVisible(false)
    self.placed = false
end
