class('StageController').extends()
local FADE1 = 0.8
local FADE2 = 1
BLD = {}
BLD.k1 = {{name = '2_lamp',x = 269,y = 174}, {name = '2b_lamp',x = 267,y = 177}} 
BLD.k2 = {{name = '2_lamp',x = 223,y = 185}, {name = '2b_lamp',x = 215,y = 166}}   
BLD.k3 = {{name = '3_house',x = 151,y = 161}, {name = '3b_monster',x = 154,y = 154}}   
BLD.k4 = {{name = '4_wheel',x = 112,y = 130}, {name = '4b_home',x = 122,y = 94, fade=FADE1}}   
BLD.k6 = {{name = '6_bridge',x = 193,y = 118, fade=FADE1}, {name = '6b_turbine',x = 273,y = 99, fade=FADE1}}   
BLD.k7 = {{name = '7_tower',x = 151,y = 60, fade=FADE1}, {name = '7b_castle',x = 146,y = 46, fade=FADE1}}   
BLD.k8 = {{name = '8_skyscraper',x = 97,y = 32}, {name = '8b_tower',x = 94,y = 16, fade=FADE1}}   
BLD.k9 = {{name = '9_ufo',x = 145,y = 26 }, {name = '9b_ufo',x = 139,y = 15, fade=FADE2}}  
BLD.k10 = {{name = '10_moon',x = 216,y = 71 }, {name = '10b_moon',x = 218,y = 67}}   
BLD.k11 = {{name = '11_planet',x = 52,y = 7 }, {name = '11b_planet',x = 47,y = 3, fade=FADE2}}   
BLD.k12 = {{name = '12_city',x = 262,y = 8}, {name = '12b_city',x = 274,y = -7, fade=FADE2}}   
BLD.kLights = {{name = 'lights',x = 0,y = 0}, {name = 'lights2',x = 0,y = 0}}   

-- stage where we start late game
LATE_GAME_STAGE = 50
-- number of stages to continually scale the spawn rates in late game
LATE_GAME_STAGE_COUNT = 50
-- amount to decrease food timer by each stage in the late game
FOOD_TIMER_LATE_GAME_MODIFIER = -0.001
--  how much to change fall speed each stage in the lage game
FALL_SPEED_LATE_GAME_MODIFIER = 1

-- hard-coded function that determines how the current stage (index) affects the food timer (value)
FOOD_TIMER_STAGE_DATA = {2, 1, 0.8, 0.7, 0.6, 0.5, 0.45, 0.4, 0.35, 0.32, 0.3, 0.28, {minStage=12, nextThreshold=20, val=0.25}, {minStage = 20, nextThreshold=30, val=0.23}, {minStage = 30, nextThreshold=1000, val = 0.2}}

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
-- starting tongue velocity
STARTING_TONGUE_VELOCITY = 200
tongueExtendVelocity = STARTING_TONGUE_VELOCITY
-- how much to increment tongue velocity for each food speed increase
TONGUE_VELOCITY_UNIT = STARTING_TONGUE_VELOCITY / STARTING_FOOD_PARAMS.slow.speed * 0.25

STARTING_MAX_RUN_VELOCITY = 80
RUN_VELOCITY_UNIT = STARTING_MAX_RUN_VELOCITY / STARTING_FOOD_PARAMS.slow.speed * 0.6
OVERALL_MAX_RUN_VELOCITY = 200

function StageController:init()
    StageController.super.init(self)
    self.fallSpeedPicker = 1
    self.stage = 0
    self.prevStage = 0
    self.stageLog =  {}
    self.stageTimeSeconds = 0
    self.timeStage = 0
    self.prevTimeStage = 0
    self.gi = game == BNB1 and 1 or 2

    self.foodTimer = STARTING_FOOD_TIMER
    self.foodParams = STARTING_FOOD_PARAMS
    self.fallSpeedModifier = 0
    self.foodTimerModifier = 0
    self.slowestFoodSpeed = STARTING_FOOD_PARAMS.slow.speed

    tongueExtendVelocity = STARTING_TONGUE_VELOCITY
    playerMaxRunVelocity = STARTING_MAX_RUN_VELOCITY
    self:setStageData(globalScore.stage)
end

function StageController:update(scene)
    local spawnFoodCount = 0 

    self:setStageData(globalScore.stage)

    if self:reachedStage(1) then
        scene.buildings:addBuilding(BLD.k1[self.gi])
    end

    if self:reachedStage(2) then
        scene.buildings:addBuilding(BLD.k2[self.gi])
    end

    if self:reachedStage(3) then
        scene.buildings:addBuilding(BLD.k3[self.gi])
    end

    if self:reachedStage(4) then
        scene.buildings:addBuilding(BLD.k4[self.gi])
    end

    if self:reachedStage(5) then
        spawnFoodCount+=1
        BGM:addLayer(1)
    end

    if self:reachedStage(6) then
        scene.buildings:addBuilding(BLD.k6[self.gi])
    end

    if self:reachedStage(7) then
        spawnFoodCount+=1
        scene.buildings:addBuilding(BLD.k7[self.gi])
    end

    if self:reachedStage(8) then
        scene.buildings:addBuilding(BLD.k8[self.gi])
    end

    if self:reachedStage(9) then
        spawnFoodCount+=1
        scene.buildings:addBuilding(BLD.k9[self.gi])
    end

    if self:reachedStage(10) then
        scene.buildings:addBuilding(BLD.k10[self.gi])
        BGM:addLayer(2)
    end

    if self:reachedStage(11) then
        scene.buildings:addBuilding(BLD.k11[self.gi])
    end

    if self:reachedStage(12) then
        scene.buildings:addBuilding(BLD.k12[self.gi])
    end

    if self:reachedStage(20) then
        BGM:play(BGM.kSepia)
        scene:invert()
    end

    local monochromeTicker = globalScore.monochromeTicker
    if monochromeTicker >= 1 and monochromeTicker < 30 then
        globalScore.monochromeTicker += 1
    end

    if self:reachedStage(30) then
        BGM:play(BGM.kMonochromeIntro)
        BGM:addLayer(1)
        scene:monochrome()
        globalScore.monochromeTicker = 1
    end


    if self:reachedStage(40) and not playdate.getReduceFlashing() then
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

    if self.timeStage ~= self.prevTimeStage then
        self:recalculateFoodParams(true)
    end
    self.stageTimeSeconds += FRAME_TIME_SEC
    return spawnFoodCount, self.foodTimer, self.foodParams, self.fallSpeedModifier
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
    for i, data in ipairs(FOOD_TIMER_STAGE_DATA) do
        local minStage = i - 1
        local ft = data
        if type(data) == 'table' then
            minStage = data.minStage
            ft = data.val
        end
        if self.stage < minStage then
            break
        else
            stageBasedFt = ft
        end
    end
    self.foodTimer = math.min(timeBasedFt, stageBasedFt) 

    self.fallSpeedPicker = self.timeStage
    -- if the score grows too fast, we may need to simulate a later time stage for faster fall speed
    if self.stage > self.fallSpeedPicker + 5 then
        self.fallSpeedPicker = self.stage - 5
        print('bumped up time stage', self.fallSpeedPicker)
    end
    if self.fallSpeedPicker > #FOOD_PARAM_FUNC then
        self.fallSpeedPicker = #FOOD_PARAM_FUNC
    end
    if self.fallSpeedPicker <= 0 then
        self.fallSpeedPicker = 1
    end
    self.foodParams = FOOD_PARAM_FUNC[self.fallSpeedPicker]

    -- player is getting too good, lets ramp up the challenge in the LATE GAME
    local lateGameProgress = self.stage - LATE_GAME_STAGE + 1
    if lateGameProgress > 0 and lateGameProgress <= LATE_GAME_STAGE_COUNT then
        self.fallSpeedModifier = lateGameProgress * FALL_SPEED_LATE_GAME_MODIFIER 
        self.foodTimerModifier = lateGameProgress * FOOD_TIMER_LATE_GAME_MODIFIER 
        
        self.foodTimer += self.foodTimerModifier
    end

    local currentLowSpeed = self.foodParams.slow.speed + self.fallSpeedModifier
    if currentLowSpeed > self.slowestFoodSpeed then
        local tongeVelocityIncr = (currentLowSpeed - self.slowestFoodSpeed) * TONGUE_VELOCITY_UNIT
        tongueExtendVelocity += tongeVelocityIncr
        local runVelocityIncr = (currentLowSpeed - self.slowestFoodSpeed) * RUN_VELOCITY_UNIT
        playerMaxRunVelocity = math.min(playerMaxRunVelocity + runVelocityIncr, OVERALL_MAX_RUN_VELOCITY)
        self.slowestFoodSpeed = currentLowSpeed 
    end
    
    if newTimeStage and debug then
        print('reached time stage', self.timeStage)
    else
        print('reached stage', self.stage)
    end

end