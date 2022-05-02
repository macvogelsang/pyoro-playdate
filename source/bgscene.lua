class('BGScene').extends(playdate.graphics.sprite)
class('Buildings').extends(playdate.graphics.sprite)

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

    self.buildings = Buildings()
end

function BGScene:invert()
    self.layers[1]:setImage(self.layers[1]:getImage():invertedImage())
    self.layers[2]:setImage(self.layers[2]:getImage():invertedImage())
end

function BGScene:monochrome()
    self.layers[1]:remove()
    self.layers[2]:setImage(self.layers[2]:getImage():invertedImage())
    self.buildings:monochrome()
end

local BUILDING_FADE_IN_FRAMES = 20
local BUILDING_FADE_STEP = 1/BUILDING_FADE_IN_FRAMES

function Buildings:init()
    Buildings.super.init(self)

    self.images = {}
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
    print(bld)
    bld.file = gfx.image.new('img/scene/' .. bld.name)
    table.insert(self.images, bld)
    self:markDirty()
    self.fadeInVal = 0 + BUILDING_FADE_STEP

end

function Buildings:removeBuilding(bld)
    self.images[bld] = nil
end

function Buildings:monochrome()
    self.drawMode = gfx.kDrawModeInverted
    self.images = {}
    self:addBuilding(BLD.kLights)
    self:markDirty()
end

function Buildings:startFlashing()
    self:setUpdatesEnabled(true)
end

function Buildings:draw()
    gfx.setImageDrawMode(self.drawMode)
    for i = #self.images, 1, -1 do
        local bld = self.images[i]
        if i == #self.images then
            bld.file:drawFaded(bld.x, bld.y, self.fadeInVal, gfx.image.kDitherTypeBayer2x2)
            if self.fadeInVal < 1 then
                -- self:markDirty()
                self.fadeInVal += BUILDING_FADE_STEP
            end
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