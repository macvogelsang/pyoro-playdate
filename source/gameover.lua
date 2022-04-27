
class('GameOver').extends(gfx.sprite)

local font = gfx.font.new('img/space-harrier')
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D

function GameOver:init()
	
	GameOver.super.init(self)

    self.timer = 4 * REFRESH_RATE
    self.ready = false

	self:setZIndex(1100)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0.5, 0.5)
	self:setSize(82, 10)

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

function GameOver:draw()
    gfx.setFontTracking(0)
	gfx.setFont(font)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0,0,37,10)
    gfx.fillRect(45,0,37,10)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.drawText("GAME OVER", 1, 1)
end
