import "constants"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/frameTimer"
import "CoreLibs/timer"
import "player"
import "tongue"

local pd <const> = playdate
gfx = pd.graphics

local player = Player()

local function initialize()
    local img = gfx.image.new('img/background')
    local background = gfx.sprite.new(img)
    background:add()
    background:moveTo(200, 120)

    player:add()

    -- printTable(background)
end

initialize()


function pd.update() 
    gfx.sprite.update()
    playdate.timer.updateTimers()
    player:moveWithCollisions(player.position)
end