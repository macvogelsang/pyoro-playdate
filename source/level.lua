import 'food'

class('Level').extends(playdate.graphics.sprite)

-- Time in seconds between seed spawns
local FOOD_TIMERS = {2, 1.8, 1.6, 1.4, 1.2}
local FALL_DIST = {}
local NORMAL, HEAL, CLEAR = 1, 2, 3

function Level:init()
    Level.super.init(self)

    self.stage = 1

    local bgImg = gfx.image.new('img/background')
    self:setImage(bgImg)
    self:setZIndex(0)
    self:setCenter(0,0)
    self:moveTo(0,0)
    self:add()

    self:resetFoodTimer()
end

function Level:resetFoodTimer()
    self.seedTimer = FOOD_TIMERS[self.stage] * REFRESH_RATE
end

function Level:update()
    self.seedTimer = self.seedTimer - 1 
    if self.seedTimer == 0 then
        self:spawnFood()
        self:resetFoodTimer()
    end
end

function Level:spawnFood()
    local speed = 'SLOW' 
    if math.random() < 0.2 then
        speed = 'MED'
    end
    local type = NORMAL
    if math.random() < 0.1 then
        type = HEAL
    end

    Food(type, speed)

end

