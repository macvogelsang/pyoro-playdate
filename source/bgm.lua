
local snd = playdate.sound

BGM = {}

BGM.kNormal395 = {
	name='normal_395', 
	layers={'normal_395_drums', 'normal_395_organs'}, 
	vol=1.0,
	layerVol=0.6
}
BGM.kNormal = {
	name='normal', 
	layers={'normal_drums', 'normal_organs'}, 
	vol=1.0,
	layerVol=0.6,
	nextSong='kNormal395'
}
BGM.kNormalShort = {
	name = 'normal_short'
}
BGM.kSepia = {
	name = 'sepia'
}
BGM.kMonochrome = {
	name = 'monochrome',
	layers = {'monochrome_bass', 'monochrome_drums'},
	vol = 1.0,
	layerVol = 1.0
}
BGM.kMonochromeIntro = {
	name='monochrome_intro',
	layers={'monochrome_bass_intro'},
	vol=1.0,
	layerVol=1.0,
	nextSong='kMonochrome'
}
BGM.kMainMenu = {
	name = 'main_menu'
}
BGM.kGameOver = {
	name = 'game_over',
	nextSong = 'none'

}
BGM.kGameOver2 = {
	name = 'game_over2'
}
BGM.kPlayerDie = {
	name = 'pyoro_die',
	nextSong = 'kGameOver'
}


local function playSongAfter(fp, nextSongKey) 
	-- Ignore this play if the song was stopped prematurely for any reason (aka by stopAll)
	if fp:getOffset() < fp:getLength() or nextSongKey == 'none' then
		return
	end

	local oldLayers = {table.unpack(BGM.activeLayers)}
	BGM:play(BGM[nextSongKey])
	-- SFX:play(SFX.kNormal395Transition)
	for k, v in pairs(oldLayers) do
		BGM:addLayer(k)
	end
end

local players = {}
-- set up BGM players table
for _, v in pairs(BGM) do
	local name = v.name
	local layers = v.layers or {}
	local volume = v.vol or 1.0

	players[name] = snd.fileplayer.new('bgm/' .. name)
	players[name]:setVolume(volume)
	players[name]:setStopOnUnderrun(false)
	for i, layer in ipairs(layers) do
		players[layer] = snd.fileplayer.new('bgm/' .. layer)
		players[layer]:setVolume(0.01)
		players[layer]:setStopOnUnderrun(false)
	end

	-- some songs only play once then continue to another track
	if v.nextSong then
		players[name]:setFinishCallback(playSongAfter, v.nextSong)
	end

end

printTable('init iplayers', players)
BGM.players = players
BGM.activeLayers = {}

function BGM:play(bgm)

	self:stopAll()
	local tracks = bgm.layers or {}
	-- infinite loop if there's no next song
	local loop = bgm.nextSong and 1 or 0 

	tracks = {bgm.name, table.unpack(tracks)}
	for i, name in ipairs(tracks) do
		self.players[name]:play(loop)		
	end

	self.nowPlaying = bgm
end

function BGM:addLayer(layer)
	if self.activeLayers[layer] == nil then
		if not self.nowPlaying.layers then
			print('!!! no layers on current track')
			return
		end
		local layerName = self.nowPlaying.layers[layer]
		self.players[layerName]:setVolume(self.nowPlaying.layerVol)
		self.activeLayers[layer] = layerName
	end
end

function BGM:stop()
	if not self.nowPlaying then
		return
	end

	local tracks = self.nowPlaying.layers or {}
	tracks = {table.unpack(tracks), self.nowPlaying.name}
	for i, name in ipairs(tracks) do
		self.players[name]:stop()
	end
end

function BGM:stopAll()
	-- stop all tracks
	for _, p in pairs(self.players) do
		p:stop()
	end

	-- reset layer volumes
	for l, layerName in pairs(self.activeLayers) do
		self.players[layerName]:setVolume(0.01)
	end

	self.activeLayers = {}
	self.nowPlaying = nil
end

function BGM:skipToLoopEnd()
	print('skip to loop end')
	for i, p in pairs(self.players) do
		if p:isPlaying() then
			p:setOffset(p:getLength() - 5)
    	end
	end
end