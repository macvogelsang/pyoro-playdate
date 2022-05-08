class('Level').extends(playdate.graphics.sprite)

-- Time in seconds between seed spawns
local NORMAL, HEAL, CLEAR = 1, 2, 3
local PLAYER_OVERHANG_OFFSET = 4

local bgImg = playdate.graphics.image.new('img/background')
doBoundCalculation = false

-- wait time before food spawns again after clearing all
local CLEAR_ALL_RESET_TIMER = 2
local foodPool = POOL.create((function() return Food() end), 32)
BLOCKS = {}

function Level:init()
    Level.super.init(self)

    self.player = Player()
    self.player:add()
    globalScore:add()
    BGM:play(BGM.kNormal)

    if #BLOCKS == 0 then
        for i = 1, NUM_BLOCKS do 
            table.insert(BLOCKS, Block(i))
        end
    else
        for i = 1, NUM_BLOCKS do 
            BLOCKS[i]:place()
        end
    end

    self.scene = BGScene()
    self.stageController = StageController()
    self.activeFood = {}
    self.firstClear = false
    self.foodTimerInitial = 4
    self.foodParams = STARTING_FOOD_PARAMS

    -- self.foodTimer = 0
    self:resetFoodTimer()
    self:add()
end

function Level:resetFoodTimer()
    self.foodTimer = self.foodTimerInitial * REFRESH_RATE
end

function Level:update()
    -- check active food for collisions and such
    for i = #self.activeFood, 1, -1 do
        local food = self.activeFood[i]
        if food.delete then
            if food.hitGround then doBoundCalculation = true end
            foodPool:free(food)
            table.remove(self.activeFood, i)
        end
    end

    -- move player and adjust its bounds
    self.player:moveTo(self.player.position)
    if doBoundCalculation then
        local left, right = self:getDirectionalDistsToPlayer()
        if #left > 0 then
            local leftBlock = BLOCKS[left[1].blockIndex]
            self.player.minXPosition = leftBlock.x + BLOCK_WIDTH + PLAYER_OVERHANG_OFFSET + 1
        else
            self.player:resetMinXPosition()
        end
        if # right > 0 then
            local rightBlock = BLOCKS[right[1].blockIndex]
            self.player.maxXPosition = rightBlock.x - PLAYER_OVERHANG_OFFSET
        else
            self.player:resetMaxXPosition()
        end
        doBoundCalculation = false
    end

    -- check for food
    if self.player:hasTongue() and self.player.tongue:hasFood() then
        local food = self.player.tongue.food

        if not food.scored then
            -- score the food
            local points = self:calcPoints(food.capturedPosition.y)
            globalScore:addPoints(points)
            food.points:spawn(points, food.capturedPosition, food.type==CLEAR)

            -- handle heal and clear foods
            if food.type == HEAL then
                -- repair one block
                local dists = self:getAbsoluteDistsToPlayer()
                if #dists > 0 then
                    BLOCKS[dists[1].blockIndex].angel:spawn()
                end
            end
            if food.type == CLEAR then
                -- spawn up to 10 angels
                local dists = self:getAbsoluteDistsToPlayer()
                for i = 1, 10 do
                    if dists[i] then
                        BLOCKS[dists[i].blockIndex].angel:spawn(i)
                    end
                end

                -- clear all food
                for i, f in ipairs(self.activeFood) do
                    f.scored = true
                    playdate.timer.performAfterDelay(50 * (i-1), function()
                        f:hit()
                        globalScore:addPoints(50)
                        f.points:spawn(50, f.position, true)
                    end)
                end

                self.foodTimer = CLEAR_ALL_RESET_TIMER * REFRESH_RATE
            end

            food.scored = true
        end
    end

    local spawnFood = 0
    spawnFood, self.foodTimerInitial, self.foodParams = self.stageController:update(self.scene)

    -- handle food spawning
    while spawnFood > 0 do
        self:spawnFood(CLEAR)
        spawnFood -= 1
    end
    self.foodTimer -= 1
    if self.foodTimer <= 0 then
        self:resetFoodTimer()
        self:spawnFood()
    end

    local monochromeTicker = globalScore.monochromeTicker
    if monochromeTicker > 0 and monochromeTicker <= 30 then
        BLOCKS[monochromeTicker]:monochrome()
    end

end

function Level:spawnFood(type)
    local speed = nil
    local randy = math.random()
    local checkSlow = self.foodParams.slow.chance
    local checkMed = self.foodParams.med.chance + checkSlow
    if randy < checkSlow then
        speed = self.foodParams.slow.speed
    elseif randy < checkMed then
        speed = self.foodParams.med.speed
    else
        speed = self.foodParams.fast.speed
    end

    if type == nil then
        local randy = math.random()
        if randy < 0.9 then
            type = NORMAL
        else
            type = HEAL
        end
    end

    -- spawn a new food over a random block
    local food  = foodPool:obtain()
    food:spawn(type, speed, math.random(1, NUM_BLOCKS))
    table.insert(self.activeFood, food)
end

function Level:getDirectionalDistsToPlayer()
    local nearLeft = {} -- hold negative distances
    local nearRight = {} -- hold positive distances
    for i, b in ipairs(BLOCKS) do
        if not b.placed then
            local dist = b.xCenter - self.player.position.x
            if dist < 0 then
                table.insert(nearLeft, {dist = dist, blockIndex = i})
            else
                table.insert(nearRight, {dist = dist, blockIndex = i})
            end
        end
    end
    table.sort(nearLeft, function(a, b) return a.dist > b.dist end)
    table.sort(nearRight, function(a, b) return a.dist < b.dist end)
    return nearLeft, nearRight
end

function Level:getAbsoluteDistsToPlayer()
    local dists = {}

    for i, b in ipairs(BLOCKS) do
        if not b.placed then
            local dist = math.abs(b.xCenter - self.player.position.x)
            table.insert(dists, {dist = dist, blockIndex = i})
        end
    end
    table.sort(dists, function(a, b) return a.dist < b.dist end)
    return dists
end

function Level:calcPoints(y)
    if y >= 163 then
        return 10
    elseif y >= 115 then
        return 50
    elseif y >= 77 then
        return 100
    elseif y >= 39 then
        return 300
    else
        return 1000
    end
end

function Level:endScene()
    for i = #self.activeFood, 1, -1 do
        local food = self.activeFood[i]
        food:cleanup()
        foodPool:free(food)
        table.remove(self.activeFood, i)
    end 
    self:setUpdatesEnabled(false)
    self.scene:removeLayers()
    self.scene:remove()
    self.player:remove()
    globalScore:remove()
    self.stageController = nil
end