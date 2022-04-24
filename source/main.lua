import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "constants"
import "player"
import "tongue"
import 'level'

player = Player()
level = Level()

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)


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