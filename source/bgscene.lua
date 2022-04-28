class('BGScene').extends(playdate.graphics.sprite)
class('Buildings').extends(playdate.graphics.sprite)



function BGScene:init()
    BGScene.super.init(self)

    self.layers = {}

    self:setImage(gfx.image.new('img/frame'))
    self:moveTo(0,0)
    self:add()

    local sky = gfx.sprite.new(gfx.image.new('img/scene/sky'))
    sky:setZIndex(LAYERS.sky)
    local hills = gfx.sprite.new(gfx.image.new('img/scene/hills'))
    hills:setZIndex(LAYERS.hills)


end

Buildings.kLamp = {
    name = 'lamp',
    x = 200,
    y = 100
}

function Buildings:init()
    Buildings.super.init(self)

    self.images = {}

    self:setSize(400,240)
    self:moveTo(0,0)
    self:setZIndex(LAYERS.buildings)
    self:setIgnoresDrawOffset(true)
end

function Buildings:addImage(img)
    self.images[img] = gfx.image.new('img/scene/' .. img.name)
    self:markDirty()
end

function Buildings:removeImage(img)
    self.images[img] = nil
end

function Buildings:draw()
end