
class('GameOver').extends(gfx.sprite)

local img = gfx.image.new('img/gameover')
local Point = playdate.geometry.point
local vector2D = playdate.geometry.vector2D
local font = gfx.font.new('img/connection_bold')
local FADE_DURATION_FRAMES = 0.5 * REFRESH_RATE
local FADE_INCREMENT =1 / FADE_DURATION_FRAMES 
local DEATH_MSG_FRAMES = 2 * REFRESH_RATE

local GOOD_SCORE_MSGS = {
    'Fantastic!', 'That was amazing!', 'Rest easy now!', "You're full already!?", 'Great job!'
}
local BAD_SCORE_MSGS = {
    'Hang in there!', 'Better luck next time.', 'See you later!', 'Ouch!', 'Take a break!', 'Practice makes perfect!'
}


function GameOver:init()
	
	GameOver.super.init(self)

    self.timer = 4 * REFRESH_RATE
    self.done = false

	self:setZIndex(LAYERS.text)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0.5, 0.5)
    self:setImage(img)
    self:setImageDrawMode(gfx.kDrawModeInverted)

	self.position = Point.new(200, 0)
	self.velocity = vector2D.new(0, 60)

    self.fadeInVal = 0
    self.deathImg = gfx.image.new('img/menu/death_msg')
    self.deathSprite = gfx.sprite.new(self.deathImg) 
    self.deathSprite:setZIndex(LAYERS.text + 1)
    self.deathSprite:setCenter(0,0)
    self.deathSprite:moveTo(0,0)

    self:add()
end

function GameOver:update()

    if self.position.y >= 100 then
        if playdate.buttonJustPressed(playdate.kButtonA) and self.fadeInVal == 0 then
            local msg = globalScore.newHighScore and table.random(GOOD_SCORE_MSGS) or table.random(BAD_SCORE_MSGS)
            -- pick message
            gfx.pushContext(self.deathImg)
                gfx.setFont(font)
                gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                gfx.drawTextAligned(msg, 200, 100, kTextAlignment.center)
            gfx.popContext()
            self:fadeInDeathMsg()
            self.deathSprite:add()
        elseif self.fadeInVal > 0 and self.fadeInVal < 1 then
            self:fadeInDeathMsg()
        elseif self.fadeInVal >= 1 then
            self.deathSprite:setImage(self.deathImg)
            self.fadeInVal += 1
            if self.fadeInVal >= DEATH_MSG_FRAMES then
                self.done = true
            end
        end
    else
	    local velocityStep = self.velocity * DT 
	    self.position = self.position + velocityStep
	    self:moveTo(self.position)
    end
end

function GameOver:fadeInDeathMsg()
    self.deathSprite:setImage(self.deathImg:fadedImage(self.fadeInVal, gfx.image.kDitherTypeBayer4x4))
    self.fadeInVal += FADE_INCREMENT
end

function GameOver:endScene()
    self.deathSprite:remove()
    self:remove()
end
