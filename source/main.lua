import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import 'constants'
import 'util'
import 'signal'
import 'sfx'
import 'bgm'
import 'bgscene'
import 'stagecontrol'
import 'level'
import 'score'
import "tongue"
import 'gameover'


globalScore = Score()
GameState = Signal()
local level = Level()
local gameover = nil

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)

    gfx.sprite.setAlwaysRedraw(true)
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
        level:endLevel()
        GameState:notify("monochrome", false)
        GameState = Signal()
        BGM:stopAll()
        level = Level()
        gameover = nil
    end
    playdate.drawFPS(0,0)
end

function playdate.debugDraw()
    -- playdate.drawFPS(0,0)
end

debugHarmlessFoodOn = false
debugPlayerInvincible = false

function playdate.keyReleased(key) 
    print(key)
    local numkey = tonumber(key)
    if numkey then
        local points = numkey * 1000
        globalScore:addPoints(points)
        level.stageController.stageTimeSeconds += 20 * numkey
    elseif key == 'h' then
        debugHarmlessFoodOn = not debugHarmlessFoodOn
        print('harmless food: ', debugHarmlessFoodOn)
    elseif key == 'i' then
        debugPlayerInvincible = not debugPlayerInvincible
        print('player invincible: ', debugPlayerInvincible)
    elseif key == 'n' then
        -- skip near the end of the current track(s)
        BGM:skipToLoopEnd()
    end
end