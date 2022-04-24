import 'food'
import 'block'
import 'angel'

class('Level').extends(playdate.graphics.sprite)

-- Time in seconds between seed spawns
local FOOD_TIMERS = {2, 1.8, 1.6, 1.4, 1.2}
local NORMAL, HEAL, CLEAR = 1, 2, 3
local PLAYER_OVERHANG_OFFSET = 2

local bgImg = playdate.graphics.image.new('img/background')
doBoundCalculation = false

function Level:init()
    Level.super.init(self)

    self:add()
    player:add()

    self.stage = 1

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) 
            bgImg:draw( 0, 0 )
            gfx.clearClipRect() 
        end
    )

    self.blocks = {}
    self.activeFood = {}

    self:setBlocks()
    self:resetFoodTimer()

end

function Level:resetFoodTimer()
    self.seedTimer = FOOD_TIMERS[self.stage] * REFRESH_RATE
end

function Level:setBlocks()
    self.blocks = {}

    for i = 1, NUM_BLOCKS do
        table.insert(self.blocks, Block(i))
    end
end

function Level:update()
    self.seedTimer = self.seedTimer - 1 
    if self.seedTimer == 0 then
        self:spawnFood()
        self:resetFoodTimer()
    end

    -- check active food for collisions and such
    for i = #self.activeFood, 1, -1 do
        local food = self.activeFood[i]
        if food.hitGround then
             self.blocks[food.blockIndex]:destroy()
             doBoundCalculation = true
        end
        if food.delete then
            table.remove(self.activeFood, i)
        end
    end    
    
    -- move player and adjust its bounds
    player:moveTo(player.position)
    if doBoundCalculation then
        local left, right = self:getDirectionalDistsToPlayer()
        if #left > 0 then
            local leftBlock = self.blocks[left[1].blockIndex]
            player.minXPosition = leftBlock.x + BLOCK_WIDTH + PLAYER_OVERHANG_OFFSET
        else
            player:resetMinXPosition()
        end
        if # right > 0 then
            local rightBlock = self.blocks[right[1].blockIndex]
            player.maxXPosition = rightBlock.x - PLAYER_OVERHANG_OFFSET
        else
            player:resetMaxXPosition()
        end
        doBoundCalculation = false
    end

    -- check for food
    if player:hasTongue() and player.tongue:hasFood() then
        local food = player.tongue.food

        if not food.scored then

            -- handle heal and clear foods
            if food.type == HEAL then
                local dists = self:getAbsoluteDistsToPlayer()
                if #dists > 0 then
                    local block = self.blocks[dists[1].blockIndex]
                    Angel(block)
                end
            end
            
            food.scored = true
        end
    end
end

function Level:spawnFood()
    local speed = 'SLOW' 
    if math.random() < 0.2 then
        speed = 'MED'
    end
    local type = NORMAL
    if math.random() < 0.5 then
        type = HEAL
    end

    table.insert(self.activeFood, Food(type, speed))
end

function Level:getDirectionalDistsToPlayer()
    local nearLeft = {} -- hold negative distances
    local nearRight = {} -- hold positive distances
    for i, b in ipairs(self.blocks) do
        if not b.placed then
            local dist = b.xCenter - player.position.x
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
            local dist = math.abs(b.xCenter - player.position.x)
            table.insert(dists, {dist = dist, blockIndex = i})
        end
    end
    table.sort(dists, function(a, b) return a.dist < b.dist end)
    return dists
end