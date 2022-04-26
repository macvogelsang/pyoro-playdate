import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "constants"
import "util"
import 'score'
import "player"
import "tongue"
import 'level'

globalScore = Score()
player = Player()
level = Level()

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)

    globalScore:add()

    -- printTable(background)
end

initialize()

function playdate.update() 
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

function playdate.debugDraw()
    playdate.drawFPS(0,0)
end

debugHarmlessFoodOn = false

function playdate.keyReleased(key) 
    print(key)
    local numkey = tonumber(key)
    if numkey then
        local points = numkey * 1000
        globalScore:addPoints(points)
    elseif key == 'h' then
        debugHarmlessFoodOn = not debugHarmlessFoodOn
        print('harmless food: ', debugHarmlessFoodOn)
    end
end