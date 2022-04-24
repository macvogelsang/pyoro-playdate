import "constants"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "player"
import "tongue"
import 'level'

local pd <const> = playdate
gfx = pd.graphics

local player = Player()

local function initialize()

    math.randomseed(playdate.getSecondsSinceEpoch())
    playdate.display.setRefreshRate(REFRESH_RATE)

    local level = Level()

    player:add()

    -- printTable(background)
end

initialize()


function pd.update() 
    playdate.drawFPS()
    gfx.sprite.update()
    playdate.timer.updateTimers()
    player:moveWithCollisions(player.position)
end