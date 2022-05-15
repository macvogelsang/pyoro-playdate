class('Menu').extends(gfx.sprite)

local homeTable = gfx.imagetable.new('img/menu/home')
local aboutTable = gfx.imagetable.new('img/menu/about')
local cursorTable = gfx.imagetable.new('img/player')
local loading = gfx.image.new('img/scene/background')
local eyesTable = gfx.imagetable.new('img/menu/eyes')
local EYES_SEQUENCE = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,4,4,4,4,4,4,4,4,4,4,4,4,5,6,6,4,4,4,4,4,4,4,4,4,4,5,6,4,4,4,4,5,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}

local CURSOR_Y = 185
local CURSOR_X_LOCS = {58, 178, 298}
local CURSOR_CYCLE_LEN = 5

local LOADING_DUR_FRAMES = 0.3 * REFRESH_RATE
local FADE_STEP_SIZE = 1 / LOADING_DUR_FRAMES

function Menu:init(save)
    Menu.super.init(self)

    self.menuItems = 3
    self.cursorIndex = game == BNB1 and 1 or 2
    self.frame = 1
    self.ai = 1
    self.ready = false
    self.loading = false

    BGM:play(BGM.kMainMenu, true)

    self.g1score = save.bnb1
    self.g2score = save.bnb2
    self.unlockedG2 = self.g2score >= 0

    if self.unlockedG2 then
        self.homeImg = homeTable:getImage(2)
        self.aboutImg = aboutTable:getImage(2)
    else
        self.homeImg = homeTable:getImage(1)
        self.aboutImg = aboutTable:getImage(1)
    end

    self:setImage(self.homeImg)
    self:drawScores()
    self:drawVersion()

    self:setCenter(0,0)
    self:setZIndex(LAYERS.menu)
    self:moveTo(0,0)
    self:add()

    self.cursor = gfx.sprite.new()
    self.cursor:setImage(cursorTable:getImage(1), gfx.kImageFlippedX)
    self.cursor:setCenter(0.5,1)
    self.cursor:moveTo(CURSOR_X_LOCS[1], CURSOR_Y)
    self.cursor:setZIndex(LAYERS.cursor)
    self.cursor:add()

    self.eyes = AnimatedSprite.new(eyesTable)
    self.eyes:addState(1, 1, nil, {tickStep = 3, frames = EYES_SEQUENCE}, true).asDefault(true)
    self.eyes:moveTo(36,37)
    self.eyes:setCenter(0,0)
    self.eyes:setZIndex(LAYERS.menu + 1)
    self.eyes:add()
end

function Menu:update()
    if not self.loading then
        if playdate.buttonJustPressed(playdate.kButtonRight) then
            self.cursorIndex = math.ring(self.cursorIndex + 1, 1, self.menuItems+1)
        end
        if playdate.buttonJustPressed(playdate.kButtonLeft) then
            self.cursorIndex = math.ring(self.cursorIndex - 1, 1, self.menuItems+1)
        end
        if playdate.buttonJustPressed(playdate.kButtonA) then
            if self.cursorIndex == 1 then
                game = BNB1
                self:nextScene()
            end
            if self.cursorIndex == 2 then
                if self.unlockedG2 then
                    game = BNB2
                    self:nextScene()
                else
                    SFX:play(SFX.kPause)
                end
            end
            if self.cursorIndex == 3 then
                self:setImage(self.aboutImg)
                self.cursor:setVisible(false)
                SFX:play(SFX.kMenuSelect)
                self.eyes:setVisible(false)
            end
        end
        if playdate.buttonJustPressed(playdate.kButtonB) then
            SFX:play(SFX.kMenuBack)
            self.cursor:setVisible(true)
            self.eyes:setVisible(true)
            self:setImage(self.homeImg)
        end
    else
        self:setImage(loading:fadedImage(1-(self.frame * FADE_STEP_SIZE), gfx.image.kDitherTypeScreen))
        if self.frame >= LOADING_DUR_FRAMES then
            self.ready = true
        end
    end
        
    if self.frame % CURSOR_CYCLE_LEN == 0 then
        self.ai = self.ai == 1 and 2 or 1
    end
    self.cursor:setImage(cursorTable:getImage(self.ai), gfx.kImageFlippedX)
    self.cursor:moveTo(CURSOR_X_LOCS[self.cursorIndex], CURSOR_Y)
    self.frame += 1
end

-- function Menu:draw()
--     self:drawScores()
-- end

function Menu:endScene() 
    self.cursor:remove()
    self.eyes:remove()
    self:remove()
end

function Menu:nextScene()
    SFX:play(SFX.kStart)
    self.loading = true
    self.frame = 0
    self:setImage(loading)
    self.cursor:remove()
    self.eyes:remove()
end

function Menu:drawScores()
    local y = 209
    local cursorOffset = 20

    gfx.pushContext(self.homeImg)
        gfx.setFont(SCORE_FONT)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.fillRect(0, 206, 400, 30)
        gfx.drawTextAligned(string.format("HS %06d", self.g1score), CURSOR_X_LOCS[1] + cursorOffset, y, kTextAlignment.center)
        if self.unlockedG2 then
            gfx.drawTextAligned(string.format("HS %06d", self.g2score), CURSOR_X_LOCS[2] + cursorOffset, y, kTextAlignment.center)
        end
    gfx.popContext()

end

function Menu:drawVersion()
    local version = playdate.metadata.version
    print(version)
    gfx.pushContext(self.aboutImg)
        gfx.setFont(SCORE_FONT)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.fillRect(270, 220, 130, 30)
        gfx.drawText("VERSION " .. version, 270, 220)
    gfx.popContext()
end
