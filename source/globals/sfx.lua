
local snd = playdate.sound
local WALK_VOL = 0.8

SFX = {}

SFX.kCatchFood = {'bean_catch'}
SFX.kWalk= {'walk', WALK_VOL}
SFX.kWalk2 = {'walk2', WALK_VOL}
SFX.kTongueOut = {'tongue_out'}
SFX.kTongueRetract = {'tongue_retract'}
SFX.kSpit = {'spit'}

SFX.kTileDestroy = {'tile_destroy', 0.6}
SFX.kTenshi = {'tenshi', 0.8}
SFX.kRestore1 = {'restore1'}
SFX.kRestore2 = {'restore2'}
SFX.kRestore3 = {'restore3'}
SFX.kRestore4 = {'restore4'}
SFX.kRestore5 = {'restore5'}

SFX.kPoints50 = {'50_1', 0.8}
SFX.kPoints100 = {'100_1', 0.8}
SFX.kPoints300 = {'300_1', 0.8}
SFX.kPoints1000 = {'1000_1', 0.8}
SFX.kComet = {'comet'}

SFX.kNormal395Transition = {'normal_395_transition'}

SFX.kMenuBack = {'menuback'}
SFX.kMenuSelect = {'select'}
SFX.kPause = {'pause'}
SFX.kUnpause = {'unpause'}
SFX.kCrankReturn = {'selection_reverse'}
SFX.kStart = {'start'}

local players = {}

for _, v in pairs(SFX) do
	local name = v[1]
	local volume = v[2] or 1.0

	players[name] = snd.sampleplayer.new('sfx/' .. name)
	players[name]:setVolume(volume)
end

SFX.players = players

function SFX:play(sfx, allowOverlap)
	if audioSetting == 'music' then
		return
	end
	local name = sfx[1]
	if allowOverlap then
		self.players[name]:play(1)		
	elseif not self.players[name]:isPlaying() then
		self.players[name]:play(1)		
	end
end

function SFX:stop(sfx)
	local name = sfx[1]
	self.players[name]:stop()
end