class('StageController').extends()
BLD = {}
BLD.kLamp = {name = '2_lamp',x = 269,y = 174}
BLD.kLamp2 = {name = '2_lamp',x = 223,y = 185 }
BLD.kHouse = {name = '3_house',x = 151,y = 161 }
BLD.kWheel = {name = '4_wheel',x = 112,y = 130 }
BLD.kBridge = {name = '6_bridge',x = 193,y = 118} 
BLD.kTower = {name = '7_tower',x = 151,y = 60}
BLD.kSkyscraper = {name = '8_skyscraper',x = 97,y = 32}
BLD.kUfo = {name = '9_ufo',x = 145,y = 26 }
BLD.kMoon = {name = '10_moon',x = 216,y = 71 }
BLD.kPlanet = {name = '11_planet',x = 52,y = 7 }
BLD.kCity = {name = '12_city',x = 262,y = 8}
BLD.kLights = {name = 'lights',x = 0,y = 0}

-- hard-coded function that determines how the current stage (index) affects the food timer (value)
STAGE_FOOD_TIMER_FUNC = {2, 1, 0.8, 0.7, 0.6, 0.5, 0.45, 0.4, 0.35, 0.32, 0.3, 0.28, 0.25}-- 12

-- fall speed distributions of food

FOOD_PARAM_FUNC = {
    -- time stage 0 and 1 
    STARTING_FOOD_PARAMS,
    -- time stage 2
    {
        slow = {chance=0.6, speed=33},
        med = {chance=0.4, speed=43},
        fast = {chance=0, speed=0},
    },
    -- time stage 3
    {
        slow = {chance=0.4, speed=33},
        med = {chance=0.3, speed=43},
        fast = {chance=0.3, speed=55},
    },
    -- time stage 4
    {
        slow = {chance=0.5, speed=43},
        med = {chance=0.5, speed=55},
        fast = {chance=0, speed=0},
    },
    -- time stage 5
    {
        slow = {chance=0.3, speed=43},
        med = {chance=0.35, speed=55},
        fast = {chance=0.35, speed=65},
    },
    -- time stage 6
    {
        slow = {chance=0.35, speed=55},
        med = {chance=0.35, speed=65},
        fast = {chance=0.30, speed=80},
    },
    -- time stage 7
    {
        slow = {chance=0.30, speed=55},
        med = {chance=0.30, speed=65},
        fast = {chance=0.40, speed=80},
    },
    -- time stage 8
    {
        slow = {chance=0.35, speed=65},
        med = {chance=0.35, speed=80},
        fast = {chance=0.30, speed=95},
    }
}
-- average time in seconds between food spawn
STARTING_FOOD_TIMER = 2
-- seconds between each time based stage increase
STAGE_TIME_INTERVAL = 20
-- time stage before stage_timer kicks in
STAGE_TIME = 2

function StageController:init()
    StageController.super.init(self)
    self.stage = 0
    self.prevStage = 0
    self.stageLog =  {}
    self.stageTimeSeconds = 0
    self.timeStage = 0
    self.prevTimeStage = 0

    self.foodTimer = STARTING_FOOD_TIMER
    self.foodParams = STARTING_FOOD_PARAMS

    self:setStageData(globalScore.stage)
end

function StageController:update(scene)
    local spawnFoodCount = 0 

    self:setStageData(globalScore.stage)

    if self:reachedStage(1) then
        scene.buildings:addBuilding(BLD.kLamp)
    end

    if self:reachedStage(2) then
        scene.buildings:addBuilding(BLD.kLamp2)
    end

    if self:reachedStage(3) then
        scene.buildings:addBuilding(BLD.kHouse)
    end

    if self:reachedStage(4) then
        scene.buildings:addBuilding(BLD.kWheel)
    end

    if self:reachedStage(5) then
        spawnFoodCount+=1
        BGM:addLayer(1)
    end

    if self:reachedStage(6) then
        scene.buildings:addBuilding(BLD.kBridge)
    end

    if self:reachedStage(7) then
        spawnFoodCount+=1
        scene.buildings:addBuilding(BLD.kTower)
    end

    if self:reachedStage(8) then
        scene.buildings:addBuilding(BLD.kSkyscraper)
    end

    if self:reachedStage(9) then
        spawnFoodCount+=1
        scene.buildings:addBuilding(BLD.kUfo)
    end

    if self:reachedStage(10) then
        scene.buildings:addBuilding(BLD.kMoon)
        BGM:addLayer(2)
    end

    if self:reachedStage(11) then
        scene.buildings:addBuilding(BLD.kPlanet)
    end

    if self:reachedStage(12) then
        scene.buildings:addBuilding(BLD.kCity)
    end

    if self:reachedStage(20) then
        BGM:play(BGM.kSepia)
        scene:invert()
    end

    if self:reachedStage(30) then
        BGM:play(BGM.kMonochromeIntro)
        BGM:addLayer(1)
        scene:monochrome()
        globalScore.monochromeMode = true
    end

    if self:reachedStage(40) then
        scene.buildings:startFlashing()
    end

    if self:reachedStage(50) then
        if BGM.nowPlaying == BGM.kMonochrome then
            BGM:addLayer(2)
        end
    end

    if self.stage ~= self.prevStage then
        self:recalculateFoodParams(false)
        if self.stage > 9 then
            spawnFoodCount += 1
        end
        if self.stage >= 13 and self.stage < 20 then
            SFX:play(SFX.kComet, true)
            scene.comet:moveTo(math.random(180,220), math.random(40,60))
            scene.comet:setVisible(true)
            scene.comet:playAnimation()
        end
    end

    if self.stage >= 50 then
        scene:updateFireworks()
    end

    if self.timeStage ~= self.prevTimeStage and self.timeStage >= 2 then
        self:recalculateFoodParams(true)
    end
    self.stageTimeSeconds += 1/REFRESH_RATE
    return spawnFoodCount, self.foodTimer, self.foodParams
end

function StageController:reachedStage(stage)
    -- return true if query stage <= current stage ANDj
    --   only only the first time this happens
    local firstTimeReached = stage <= self.stage and self.stageLog[stage] == nil
    if firstTimeReached then
        self.stageLog[stage] = true
    end
    return firstTimeReached

end

function StageController:setStageData(stage)
    self.prevStage = self.stage
    self.stage = stage

    local timeStage = self.stageTimeSeconds // STAGE_TIME_INTERVAL
    self.prevTimeStage = self.timeStage
    self.timeStage = timeStage
end

-- use stage and timeStage to determine food spawn rate and fall speed
function StageController:recalculateFoodParams(newTimeStage)
    -- food timers
    local timeBasedFt = 1.91 * math.exp(-0.02 * self.stageTimeSeconds + 0.0366) + 0.65
    local stageBasedFt = 2
    if self.stage + 1 > #STAGE_FOOD_TIMER_FUNC then
        stageBasedFt = STAGE_FOOD_TIMER_FUNC[#STAGE_FOOD_TIMER_FUNC]
    else
        stageBasedFt = STAGE_FOOD_TIMER_FUNC[self.stage + 1]
    end
    -- print(timeBasedFt, stageBasedFt)
    self.foodTimer = math.min(timeBasedFt, stageBasedFt) 

    if newTimeStage then
        -- fall speed is only based on time (for now)
        if self.timeStage <= #FOOD_PARAM_FUNC then
            self.foodParams = FOOD_PARAM_FUNC[self.timeStage]
        else
            self.foodParams = FOOD_PARAM_FUNC[#FOOD_PARAM_FUNC]
        end
        print('reached time stage', self.timeStage)
    else
        print('reached stage', self.stage)
    end


end