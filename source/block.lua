class('Block').extends(playdate.graphics.sprite)

local blockImg = gfx.image.new('img/block')
local blockOutlineImg = gfx.image.new('img/block-outline')

function Block:init(i)
    Block.super.init(self)
    self.blockIndex = i
    self.xPos = blockIndexToX(self.blockIndex) 
    self.xCenter = self.xPos + BLOCK_WIDTH/2
    self:setCenter(0,0)
    self:setZIndex(LAYERS.block)
    self:setImage(blockImg)
    self:place()

    self.angel = Angel(blockIndex, self.xCenter)

    self:add()
end

-- places the block at the bottom of the screen and sets its image
function Block:place()
    self.placed = true
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

function Block:monochrome()
    self:setImage(blockOutlineImg)
end

function Block:update()
    if self.angel.state == 2  and not self.placed then
        self:place()
    end
end