
local snd = playdate.sound
local WALK_VOL = 0.3

SFX = {}

SFX.kCatchFood = {'bean_catch'}
SFX.kWalk= {'walk', WALK_VOL}
SFX.kWalk2 = {'walk2', WALK_VOL}
SFX.kTongueOut = {'tongue_out'}
SFX.kTongueRetract = {'tongue_retract'}
SFX.kPlayerDie = {'pyoro_die'}

SFX.kTileDestroy = {'tile_destroy', 0.6}
SFX.kTenshi = {'tenshi', 0.8}
SFX.kRestore1 = {'restore1'}
SFX.kRestore2 = {'restore2'}
SFX.kRestore3 = {'restore3'}
SFX.kRestore4 = {'restore4'}
SFX.kRestore5 = {'restore5'}

SFX.kPoints50 = {'50_1', 0.8}

local sounds = {}

for _, v in pairs(SFX) do
	local name = v[1]
	local volume = v[2] or 1.0

	sounds[name] = snd.sampleplayer.new('sfx/' .. name)
	sounds[name]:setVolume(volume)
end

SFX.sounds = sounds

function SFX:play(sfx, allowOverlap)
	local name = sfx[1]
	if allowOverlap then
		self.sounds[name]:play(1)		
	elseif not self.sounds[name]:isPlaying() then
		self.sounds[name]:play(1)		
	end
end

function SFX:stop(sfx)
	local name = sfx[1]
	self.sounds[name]:stop()
end


-- function SFX:playBackgroundMusic()
-- 	local filePlayer = snd.fileplayer.new('sfx/main_theme')
-- 	filePlayer:play(0) -- repeat forever
-- end