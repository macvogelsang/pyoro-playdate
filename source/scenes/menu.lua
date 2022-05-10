class('Menu').extends(playdate.graphics.sprite)

local home = gfx.image.new('img/menu/home')
local about = gfx.image.new('img/menu/about')
local CURSOR_JUMP_DIST = 25
local CURSOR_Y_LOCS = {140, 165}

function Menu:init()
    Menu.super.init(self)

    self.menuItems = 2
    self.cursorIndex = 1
    self.nextScene = false

    BGM:play(BGM.kMainMenu, true)

    self:setImage(home)
    self:setCenter(0,0)
    self:setZIndex(LAYERS.menu)
    self:moveTo(0,0)
    self:add()

    self.cursor = gfx.sprite.new(gfx.image.new('img/menu/cursor'))
    self.cursor:setCenter(0,0)
    self.cursor:moveTo(140,140)
    self.cursor:setZIndex(LAYERS.cursor)
    self.cursor:add()
end

function Menu:update()
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        self.cursorIndex = math.ring(self.cursorIndex + 1, 1, self.menuItems+1)
    end
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        self.cursorIndex = math.ring(self.cursorIndex - 1, 1, self.menuItems+1)
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if self.cursorIndex == 1 then
            self.nextScene = true
            SFX:play(SFX.kMenuSelect)
            self.cursor:setVisible(false)
            self:setUpdatesEnabled(false)
        end
        if self.cursorIndex == 2 then
            self:setImage(about)
            self.cursor:setVisible(false)
            SFX:play(SFX.kMenuSelect)
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SFX:play(SFX.kMenuBack)
        self.cursor:setVisible(true)
        self:setImage(home)
    end
    
    self.cursor:moveTo(140, CURSOR_Y_LOCS[self.cursorIndex])
end

