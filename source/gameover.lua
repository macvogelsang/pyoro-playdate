
class('GameOver').extends(gfx.sprite)

local img = gfx.image.new('img/gameover')
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

function GameOver:init()
	
	GameOver.super.init(self)

    self.timer = 4 * REFRESH_RATE
    self.ready = false

	self:setZIndex(LAYERS.text)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0.5, 0.5)
    self:setImage(img)
    self:setImageDrawMode(gfx.kDrawModeInverted)

	self.position = Point.new(200, 0)
	self.velocity = vector2D.new(0, 60)

    self:add()
end

function GameOver:update()
    if self.position.y >= 120 then
        self.ready = true
    else
	    local velocityStep = self.velocity * DT 
	    self.position = self.position + velocityStep
	    self:moveTo(self.position)
    end
end

