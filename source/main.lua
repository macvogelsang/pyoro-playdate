import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import 'constants'
import 'util'
import 'sfx'
import 'bgm'
import 'menu'
import 'bgscene'
import 'stagecontrol'
import 'level'
import 'score'
import "tongue"
import 'gameover'

LAYERS = enum({
    'sky',
    'buildings',
    'hills',
    'frame',
    'block',
    'dust',
    'angel',
    'food',
    'tongue',
    'points',
    'player',
    'text',
    'menu',
    'cursor'
})

globalScore = Score()
local level = nil
local gameover = nil
local menu = Menu()

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

    if menu then
        if menu.nextScene then
            level = Level()
            menu:remove()
            menu = nil
        end
    end
    if level then
        if  level.player.dead and not gameover then
            gameover = GameOver()
        end
    end
    if gameover then
        if gameover.ready and playdate.buttonJustPressed(playdate.kButtonA) then
            gfx.sprite.removeAll()
            globalScore = Score()
            level:endLevel()
            BGM:stopAll()
            level = nil
            gameover = nil
            menu = Menu()
        end
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