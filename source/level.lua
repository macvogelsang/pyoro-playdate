import 'food'
import 'block'
import 'angel'

class('Level').extends(playdate.graphics.sprite)

-- Time in seconds between seed spawns
local FOOD_TIMERS = {2, 1.8, 1.6, 1.4, 1.2}
local NORMAL, HEAL, CLEAR = 1, 2, 3
local PLAYER_OVERHANG_OFFSET = 2

local bgImg = playdate.graphics.image.new('img/background')

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
        end
        if food.delete then
            table.remove(self.activeFood, i)
        end
    end    
    
    -- move player and adjust its bounds
    local _x, _y, collisions, numCollisions = player:moveWithCollisions(player.position)
    if numCollisions > 0 then
        local block = collisions[1].other
        
        if block.x < player.position.x and not block.collided then
            player.minXPosition = block.x + BLOCK_WIDTH + PLAYER_OVERHANG_OFFSET
            block.collided = true
        end
        if block.x >= player.position.x and not block.collided then
            player.maxXPosition = block.x - PLAYER_OVERHANG_OFFSET
            block.collided = true
        end
    end

    -- check for food
    if player:hasTongue() and player.tongue:hasFood() then
        local food = player.tongue.food

        if not food.scored then
            local blockIndex = player.tongue.food.blockIndex
            
            -- handle heal and clear foods
            if food.type == HEAL then
                local dists = self:calcGapDistsToPlayer()
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

function Level:calcGapDistsToPlayer()
    local dists = {}
    for i, b in ipairs(self.blocks) do
        if not b.placed then
            table.insert(dists, {
                dist = math.abs(b.xCenter - player.position.x), 
                blockIndex = i}
            )
        end
    end

    table.sort(dists, function(a, b) return a.dist < b.dist end)
    return dists
end