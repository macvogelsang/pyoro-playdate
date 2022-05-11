import 'imports'

-- globals
globalScore = nil
game = BNB1

-- debug globals
local debug = true
debugHarmlessFoodOn = false
debugPlayerInvincible = true 

-- scenes
local save = nil
local level = nil
local gameover = nil
local menu = nil


local function loadSave() 
    save = playdate.datastore.read()
    if not save then
        save = {
            bnb1 = 10000,
            bnb2 = -1
        }
        game = BNB1
    end
end

local function initialize()
    -- playdate settings
    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)
    -- force gc to run for at least 2ms each frame
    playdate.setMinimumGCTime(2)
    gfx.sprite.setAlwaysRedraw(true)

    -- start menu
    loadSave()
    menu = Menu(save)
end

local function writeSave() 
    local newSave = {}
    if game == BNB1 then
        newSave.bnb1 = globalScore.highScore 
        newSave.bnb2 = save.bnb2
        
        -- unlock bird and beans 2
        if newSave.bnb1 > 10000 and newSave.bnb2 < 0 then
            newSave.bnb2 = 0
        end
    else
        newSave.bnb1 = save.bnb1
        newSave.bnb2 = globalScore.highScore
    end

    save = newSave
    playdate.datastore.write(newSave)
end

local function gameEnd()
    writeSave()
    level:endScene()
    level = nil
    gameover = nil
    menu = Menu(save)
end

local function startLevel()
    level:setUpdatesEnabled(true)
    BGM:play(BGM.kNormal)
    if menu then
        menu:remove()
        menu = nil
    end
end

initialize()

function playdate.update() 
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if menu then
        if menu.goNextScene then
            -- set high score
            loadSave()
            -- start level
            globalScore = Score()
            globalScore.highScore = save[game]
            level = Level()
            -- remove menu
            menu.goNextScene = false
            playdate.timer.performAfterDelay(300, startLevel)
        end
    end
    if level then
        if  level.player.dead and not gameover then
            gameover = GameOver()
        end
    end
    if gameover then
        if gameover.done then
            gameover:endScene()
            gameEnd()
        end
    end

    if debug then  playdate.drawFPS(0,0) end
end

function playdate.debugDraw()
    playdate.drawFPS(0,0)
end

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
    elseif key == 'k' and level then
        level.player:die()
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

local gameEndItem, error = sysMenu:addMenuItem("main menu", function()
    BGM:stopAll()
    gameEnd()
end)

if debug then
    local invincibleItem, error = sysMenu:addCheckmarkMenuItem("invincibility", debugPlayerInvincible, function(value)
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
end