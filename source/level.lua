import 'player'
import 'food'
import 'block'
import 'angel'
import 'points'

class('Level').extends(playdate.graphics.sprite)

-- Time in seconds between seed spawns
local NORMAL, HEAL, CLEAR = 1, 2, 3
local PLAYER_OVERHANG_OFFSET = 4
local ALL_STAGE_DATA = {
    {
        minStage = 0,
        foodTimer = 2,
        spawnDist = {0.9, 0.1, 0}
    },
    {
        minStage = 1,
        foodTimer = 1,
        spawnDist = {0.9, 0.1, 0}
    },
    {
        minStage = 2,
        foodTimer = 0.8,
        spawnDist = {0.9, 0.1, 0}
    },
    {
        minStage = 3,
        foodTimer = 0.6,
        spawnDist = {0.9, 0.1, 0}
    },
    {
        minStage = 4,
        foodTimer = 0.5,
        spawnDist = {0.9, 0.1, 0}
    },
    {
        minStage = 5,
        foodTimer = 0.4,
        spawnDist = {0.8, 0.15, 0.05}
    },
    {
        minStage = 10,
        foodTimer = 0.35,
        spawnDist = {0.7, 0.20, 0.10}
    },
    {
        minStage = 20,
        foodTimer = 0.3,
        spawnDist = {0.7, 0.15, 0.15}
    },
    {
        minStage = 30,
        foodTimer = 0.2,
        spawnDist = {0.6, 0.10, 0.30}
    }
}

local bgImg = playdate.graphics.image.new('img/background')
doBoundCalculation = false

function Level:init()
    Level.super.init(self)

    self:add()
    self.player = Player()
    self.player:add()
    globalScore:add()

    self:setStageData(globalScore.stage)

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) 
            bgImg:draw( 0, 0 )
            gfx.clearClipRect() 
        end
    )

    self.blocks = {}
    self.activeFood = {}
    self.firstClear = false

    self:setBlocks()
    self:resetFoodTimer()
end

function Level:resetFoodTimer()
    self.foodTimer = self.stageData.foodTimer * REFRESH_RATE
end

function Level:setStageData(stage)
    self.stage = stage
    local dataIndex = 1
    for i, data in ipairs(ALL_STAGE_DATA) do 
        if self.stage >= data.minStage then
            dataIndex = i
        end
    end
    self.stageData = ALL_STAGE_DATA[dataIndex]
end

function Level:setBlocks()
    self.blocks = {}

    for i = 1, NUM_BLOCKS do
        table.insert(self.blocks, Block(i))
    end
end

function Level:update()
    self.foodTimer = self.foodTimer - 1 
    if self.foodTimer <= 0 then
        self:spawnFood()
        self:resetFoodTimer()
    end

    -- check active food for collisions and such
    for i = #self.activeFood, 1, -1 do
        local food = self.activeFood[i]
        if food.hitGround then
            food.blockRef:destroy()
            doBoundCalculation = true
        end
        if food.delete then
            table.remove(self.activeFood, i)
        end
    end    
    
    -- move player and adjust its bounds
    self.player:moveTo(self.player.position)
    if doBoundCalculation then
        local left, right = self:getDirectionalDistsToPlayer()
        if #left > 0 then
            local leftBlock = self.blocks[left[1].blockIndex]
            self.player.minXPosition = leftBlock.x + BLOCK_WIDTH + PLAYER_OVERHANG_OFFSET + 1
        else
            self.player:resetMinXPosition()
        end
        if # right > 0 then
            local rightBlock = self.blocks[right[1].blockIndex]
            self.player.maxXPosition = rightBlock.x - PLAYER_OVERHANG_OFFSET
        else
            self.player:resetMaxXPosition()
        end
        doBoundCalculation = false
    end

    -- check for food
    if self.player:hasTongue() and self.player.tongue:hasFood() then
        local food = self.player.tongue.food
        local points = self:calcPoints(food.capturedPosition.y)
        globalScore:addPoints(points)
        Points(points, food.capturedPosition, food.type==CLEAR)

        if not food.scored then
            -- handle heal and clear foods
            if food.type == HEAL then
                -- repair one block
                local dists = self:getAbsoluteDistsToPlayer()
                if #dists > 0 then
                    local block = self.blocks[dists[1].blockIndex]
                    Angel(block)
                end
            end
            if food.type == CLEAR then
                -- spawn up to 10 angels
                local dists = self:getAbsoluteDistsToPlayer()
                for i = 1, 10 do
                    if dists[i] then
                        local block = self.blocks[dists[i].blockIndex]
                        Angel(block, i)
                    end
                end

                -- clear all food
                for i, f in ipairs(self.activeFood) do 
                    f.scored = true
                    f:hit()
                    globalScore:addPoints(50)
                    Points(50, f.position, true)
                end
            end

            food.scored = true
        end
    end

    self:setStageData(globalScore.stage)

    if self.stage == 6 and not self.firstClear then
        self.firstClear = true
        self:spawnFood(CLEAR)
    end
end

function Level:spawnFood(type)
    local speed = 'SLOW' 
    if math.random() < 0.2 then
        speed = 'MED'
    end

    if type == nil then
        local randy = math.random()
        local checkNorm = self.stageData.spawnDist[NORMAL] -- cumulative change that a seed will spawn
        local checkHeal = self.stageData.spawnDist[HEAL] + checkNorm
        if randy < checkNorm then 
            type = NORMAL
        elseif randy < checkHeal  then
            type = HEAL
        else
            type = CLEAR
        end
    end

    -- spawn a new food over a random block
    table.insert(self.activeFood, Food(type, speed, self.blocks[math.random(NUM_BLOCKS)]))
end

function Level:getDirectionalDistsToPlayer()
    local nearLeft = {} -- hold negative distances
    local nearRight = {} -- hold positive distances
    for i, b in ipairs(self.blocks) do
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

    for i, b in ipairs(self.blocks) do
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