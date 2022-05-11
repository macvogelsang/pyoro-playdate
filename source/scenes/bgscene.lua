class('BGScene').extends(gfx.sprite)
class('Buildings').extends(gfx.sprite)
local fireworkImg = gfx.image.new('img/scene/firework')
local FIREWORK_HEIGHT = 112
local NUM_FIREWORKS = 12
local FADE_LAYERS = {0.4, 0.8, 1}
local FADE_TYPE = gfx.image.kDitherTypeBayer2x2
function BGScene:init()
    BGScene.super.init(self)

    self.layers = {}
    self:setImage(gfx.image.new('img/scene/background'))
    self:setCenter(0,0)
    self:add()

    local sky = gfx.sprite.new(gfx.image.new('img/scene/sky'))
    sky:setZIndex(LAYERS.sky)
    local hills = gfx.sprite.new(gfx.image.new('img/scene/hills'))
    hills:setZIndex(LAYERS.hills)
    local frame = gfx.sprite.new(gfx.image.new('img/scene/frame'))
    frame:setZIndex(LAYERS.frame)
    
    self.layers = {sky, hills, frame}
    for _, layer in ipairs(self.layers) do
        layer:setCenter(0,0)
        layer:moveTo(0,0)
        layer:add()
    end

    local comet = AnimatedSprite.new(gfx.imagetable.new('img/scene/comet'))
    comet:addState("streak", 1, nil, {
        tickStep = 2, 
        loop=false,
        onLoopFinishedEvent = function (self) self:setVisible(false) end
    })
    comet:setZIndex(LAYERS.comet)
    comet:setCenter(0.5,0.5)
    
    self.comet = comet

    self.buildings = Buildings()
    self.fireworks = {}

    self.yOffsets = {0, 5, 10, 13, 8, 12, 1, 17, 9, 11, 16, 6}
end

function BGScene:invert()
    self.layers[1]:setImage(self.layers[1]:getImage():invertedImage())
    self.layers[2]:setImage(self.layers[2]:getImage():invertedImage())
end

function BGScene:monochrome()
    self.layers[1]:setVisible(false)
    self.layers[2]:setImage(self.layers[2]:getImage():invertedImage())
    self.buildings:monochrome()
end

function BGScene:createFireworks(n)
    local startPos = X_LOWER_BOUND + 10
    local range = 290
    local fireworkIncrement = range // n

    for i=1,n do
        local firework = gfx.sprite.new(fireworkImg)
        firework:setCenter(0,0)
        local ystart = 240 + (32 * self.yOffsets[i])
        firework:moveTo(startPos + ((i-1) * fireworkIncrement), ystart)
        firework:setZIndex(LAYERS.fireworks)
        firework:add()
        table.insert(self.fireworks, firework)
    end
end

function BGScene:updateFireworks()
    if #self.fireworks == 0 then
        self:createFireworks(NUM_FIREWORKS)
    else
        for i, f in ipairs(self.fireworks) do
            f:moveBy(0, -16)
            if f.y <= - FIREWORK_HEIGHT then
                f: moveTo(f.x, FIREWORK_HEIGHT + 230)
            end
        end
    end
end

function BGScene:removeFireworks()
    for i, f in ipairs(self.fireworks) do
        f:remove()
    end
end

function BGScene:removeLayers()
    for _, layer in ipairs(self.layers) do
        layer:remove()
    end 
    self.comet:remove()
    self.buildings:remove()
end

local BUILDING_FADE_IN_FRAMES = 20
local BUILDING_FADE_STEP = 1/BUILDING_FADE_IN_FRAMES

function Buildings:init()
    Buildings.super.init(self)

    self.images = {}
    self.monochromeMode = false
    self.drawMode = gfx.kDrawModeCopy
    self:setSize(400,240)
    self:setCenter(0,0)
    self:moveTo(0,0)
    self:setZIndex(LAYERS.buildings)
    self:setIgnoresDrawOffset(true)
    self:setUpdatesEnabled(false)
    self:add()

    self.frame = 1
    self.drawBlank = false
end

function Buildings:addBuilding(bld)
    bld.file = gfx.image.new('img/scene/' .. bld.name)
    table.insert(self.images, bld)
    self:markDirty()
    self.fadeInVal = 0 + BUILDING_FADE_STEP
end

function Buildings:removeBuilding(bld)
    self.images[bld] = nil
end

function Buildings:monochrome()
    self.images = {}
    local gi = GAME == BNB1 and 1 or 2
    self.monochromeMode = true
    self:addBuilding(BLD.kLights[gi])
    self:addBuilding(BLD.k10[gi])
end

function Buildings:startFlashing()
    self:setUpdatesEnabled(true)
end

function Buildings:draw()
    gfx.setImageDrawMode(self.drawMode)
    for i = #self.images, 1, -1 do
        local bld = self.images[i]
        local fadeEnd = bld.fade or 1
        if i == #self.images  and not self.monochromeMode then
            bld.file:drawFaded(bld.x, bld.y, self.fadeInVal, FADE_TYPE)
            if self.fadeInVal < fadeEnd then
                self.fadeInVal += BUILDING_FADE_STEP
            end
        elseif bld.fade then
            bld.file:drawFaded(bld.x, bld.y, bld.fade, FADE_TYPE)
        else
            bld.file:draw(bld.x, bld.y)
        end
    end
end

function Buildings:update()

    if self.frame % 13 == 0 then
        self.drawMode = self.drawMode == gfx.kDrawModeInverted and gfx.kDrawModeBlackTransparent or gfx.kDrawModeInverted
        self:markDirty()
    end

    self.frame += 1
end