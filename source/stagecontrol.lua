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
ALL_STAGE_DATA = {
    {
        minStage = 0,
        foodTimer = 2,
    },
    {
        minStage = 1,
        foodTimer = 1,
    },
    {
        minStage = 2,
        foodTimer = 0.8,
    },
    {
        minStage = 3,
        foodTimer = 0.6,
    },
    {
        minStage = 4,
        foodTimer = 0.5,
    },
    {
        minStage = 5,
        foodTimer = 0.4,
    },
    {
        minStage = 10,
        foodTimer = 0.35,
    },
    {
        minStage = 20,
        foodTimer = 0.3,
    },
    {
        minStage = 30,
        foodTimer = 0.2,
    }
}


function StageController:init()
    StageController.super.init(self)
    self.stage = 0
    self.prevStage = 0
    self.stageLog =  {}
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
    end

    if self:reachedStage(40) then
        scene.buildings:startFlashing()
    end

    if self:reachedStage(50) then
        BGM:addLayer(2)
    end

    if self.stage ~= self.prevStage and self.stage > 9 then
        spawnFoodCount += 1
    end
    return spawnFoodCount
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
    local dataIndex = 1
    for i, data in ipairs(ALL_STAGE_DATA) do 
        if self.stage >= data.minStage then
            dataIndex = i
        end
    end
    self.stageData = ALL_STAGE_DATA[dataIndex]
    return self.stageData
end