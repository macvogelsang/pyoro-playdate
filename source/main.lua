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

globalScore = nil
game = BNB1

local save = nil
local level = nil
local gameover = nil
local menu = Menu()

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)

    gfx.sprite.setAlwaysRedraw(true)
    -- printTable(background)
end

local function loadSave() 
    save = playdate.datastore.read()
    if not save then
        save = {
            bnb1 = 10000,
            bnb2 = -1
        }
        game = BNB1
    end
    globalScore.highScore = save[game]
end

local function writeSave() 
    local newSave = {}
    if game == BNB1 then
        newSave.bnb1 = globalScore.highScore 
        newSave.bnb2 = save.bnb2
        
        -- unlock bird and beans 2
        if newSave.bn1 >= 10000 and newSave.bnb2 < 0 then
            newSave.bnb2 = 0
        end
    else
        newSave.bnb1 = save.bnb1
        newSave.bnb2 = globalScore.highScore
    end

    playdate.datastore.write(newSave)
end

local function gameEnd()
    writeSave()
    gfx.sprite.removeAll()
    level:endLevel()
    BGM:stopAll()
    level = nil
    gameover = nil
    menu = Menu()
end

initialize()

function playdate.update() 
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if menu then
        if menu.nextScene then
            -- set high score
            globalScore = Score()
            game = BNB1
            loadSave()
            -- start level
            level = Level()
            -- remove menu
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
            gameEnd()
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

function playdate.gameWillTerminate()
    writeSave()
end

function playdate.deviceWillSleep()
    writeSave()
end

-- menu items
local sysMenu = playdate.getSystemMenu()

local gameEndItem, error = sysMenu:addMenuItem("quit game", function()
    gameEnd()
end)

local invincibleItem, error = sysMenu:addCheckmarkMenuItem("invincibility", false, function(value)
    debugPlayerInvincible = value
end)

local scoreItem, error = sysMenu:addOptionsMenuItem('set score', {'5k', '10k', '30k', '50k'}, '5k', function(value)
    if value == '5k' then
        globalScore.stage = 5
        globalScore.score = 5000
    end
    if value == '10k' then
        globalScore.stage = 10
        globalScore.score = 10000
    end
    if value == '30k' then
        globalScore.stage = 30
        globalScore.score = 30000
    end
    if value == '50k' then
        globalScore.stage = 50
        globalScore.score = 50000
    end
end)