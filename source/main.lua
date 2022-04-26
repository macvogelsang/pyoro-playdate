import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "constants"
import 'sfx'
import "util"
import 'score'
import "tongue"
import 'level'
import 'gameover'

globalScore = Score()
local level = Level()
local gameover = nil

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)


    -- printTable(background)
end

initialize()

function playdate.update() 
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if level.player.dead and not gameover then
        gameover = GameOver()
    end
    if gameover and gameover.ready and playdate.buttonJustPressed(playdate.kButtonA) then
        gfx.sprite.removeAll()
        globalScore = Score()
        level = Level()
        gameover = nil
    end
end

function playdate.debugDraw()
    playdate.drawFPS(0,0)
end

debugHarmlessFoodOn = false
debugPlayerInvincible = false

function playdate.keyReleased(key) 
    print(key)
    local numkey = tonumber(key)
    if numkey then
        local points = numkey * 1000
        globalScore:addPoints(points)
    elseif key == 'h' then
        debugHarmlessFoodOn = not debugHarmlessFoodOn
        print('harmless food: ', debugHarmlessFoodOn)
    elseif key == 'i' then
        debugPlayerInvincible = not debugPlayerInvincible
        print('player invincible: ', debugPlayerInvincible)
    end
end