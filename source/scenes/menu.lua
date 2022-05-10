class('Menu').extends(gfx.sprite)

local homeTable = gfx.imagetable.new('img/menu/home')
local about = gfx.image.new('img/menu/about')
local cursorTable = gfx.imagetable.new('img/player')

local CURSOR_Y = 183
local CURSOR_X_LOCS = {61, 181, 301}
local CURSOR_CYCLE_LEN = 5

function Menu:init(save)
    Menu.super.init(self)

    self.menuItems = 3
    self.cursorIndex = game == BNB1 and 1 or 2
    self.frame = 1
    self.ai = 1
    self.goNextScene = false

    BGM:play(BGM.kMainMenu, true)

    self.g1score = save.bnb1
    self.g2score = save.bnb2
    self.unlockedG2 = self.g2score >= 0

    if self.unlockedG2 then
        self.homeImg = homeTable:getImage(2)
    else
        self.homeImg = homeTable:getImage(1)
    end

    self:setImage(self.homeImg)
    self:drawScores()
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
end

function Menu:update()
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
            self:setImage(about)
            self.cursor:setVisible(false)
            SFX:play(SFX.kMenuSelect)
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SFX:play(SFX.kMenuBack)
        self.cursor:setVisible(true)
        self:setImage(self.homeImg)
    end
    
    if self.frame % CURSOR_CYCLE_LEN == 0 then
        self.ai = self.ai == 1 and 2 or 1
    end
    self.cursor:setImage(cursorTable:getImage(self.ai), gfx.kImageFlippedX)
    self.cursor:moveTo(CURSOR_X_LOCS[self.cursorIndex], CURSOR_Y)
    self.frame += 1
end

function Menu:nextScene()
    self.goNextScene = true
    SFX:play(SFX.kMenuSelect)
    self.cursor:setVisible(false)
    self:setUpdatesEnabled(false)
end

function Menu:drawScores()
    local y = 206
    local cursorOffset = 20

    gfx.pushContext(self.homeImg)
        gfx.setFont(SCORE_FONT)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.fillRect(0, 204, 400, 30)
        gfx.drawTextAligned(string.format("HS %06d", self.g1score), CURSOR_X_LOCS[1] + cursorOffset, y, kTextAlignment.center)
        if self.unlockedG2 then
            gfx.drawTextAligned(string.format("HS %06d", self.g2score), CURSOR_X_LOCS[2] + cursorOffset, y, kTextAlignment.center)
        end
    gfx.popContext()

end
