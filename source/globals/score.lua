class('Score').extends(gfx.sprite)

local font = gfx.font.new('img/fonts/space-harrier2')

function Score:init()
	
	Score.super.init(self)

	self.score = 0
    self.stage = 0

    self.highScore = 10000
	self:setZIndex(LAYERS.text)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0.5, 0)
	self:setSize(240, 20)
	self:moveTo(200, 1)

	self.newHighScore = false
	self.monochromeTicker = 0
end

function Score:addPoints(points)
	self.score += points
	self:markDirty()

    self.stage = math.floor(self.score / 1000) 
	if self.score > self.highScore then
		self.highScore = self.score
		self.newHighScore = true
	end
end

function Score:draw()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.setFontTracking(-1)
	gfx.setFont(font)
	gfx.drawText(string.format("SCORE %06d  HI SCORE %06d", self.score, self.highScore), 0, 0)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
