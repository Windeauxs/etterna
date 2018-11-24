local profile = PROFILEMAN:GetProfile(PLAYER_1)
local frameX = 10
local frameY = 250 + capWideScale(get43size(120), 90)
local frameWidth = capWideScale(get43size(455), 455)
local score
local song
local steps
local noteField = false
local heyiwasusingthat = false
local mcbootlarder
local prevX = capWideScale(get43size(98), 98)
local idkwhatimdoing = capWideScale(prevX-2, prevX/2+4)
local usingreverse = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingReverse()
local prevY = 55
local prevrevY = 208

local update = false
local t =
	Def.ActorFrame {
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(-500, 0):diffusealpha(0)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
	end,
	MintyFreshCommand = function(self)
		self:finishtweening()
		local bong = GAMESTATE:GetCurrentSong()
		if not bong then
			self:queuecommand("MilkyTarts")
		end
		if song ~= bong then
			song = bong
			self:queuecommand("MortyFarts")
		end
		if getTabIndex() == 0 then
			if heyiwasusingthat and GAMESTATE:GetCurrentSong() and noteField then	-- these can prolly be wrapped better too -mina
				mcbootlarder:visible(true)
				mcbootlarder:GetChild("NoteField"):visible(true)
				MESSAGEMAN:Broadcast("ChartPreviewOn")
				heyiwasusingthat = false
			end
			self:queuecommand("On")
			update = true
		else
			if GAMESTATE:GetCurrentSong() and noteField and mcbootlarder:GetVisible() then 
				mcbootlarder:visible(false)
				mcbootlarder:GetChild("NoteField"):visible(false)
				MESSAGEMAN:Broadcast("ChartPreviewOff")
				heyiwasusingthat = true
			end
			self:queuecommand("Off")
			update = false
		end
	end,
	MilkyTartsCommand=function(self)	-- when entering pack screenselectmusic explicitly turns visibilty on notefield off -mina
		if noteField and mcbootlarder:GetVisible() then 
			mcbootlarder:visible(false)
			MESSAGEMAN:Broadcast("ChartPreviewOff")
			heyiwasusingthat = true
		end
	end,
	TabChangedMessageCommand = function(self)
		self:queuecommand("MintyFresh")
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:queuecommand("MintyFresh")
	end,
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY - 76):zoomto(110, 94):halign(0):valign(0):diffuse(color("#333333A6"))
		end
	},
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY - 76):zoomto(8, 144):halign(0):valign(0):diffuse(getMainColor("highlight")):diffusealpha(0.5)
		end
	},Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY + 18):zoomto(frameWidth + 4, 50):halign(0):valign(0):diffuse(color("#333333A6"))
		end
	}
}

-- Music Rate Display
t[#t + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(18, SCREEN_BOTTOM - 225):visible(true):halign(0):zoom(0.8):maxwidth(
				capWideScale(get43size(360), 360) / capWideScale(get43size(0.45), 0.45))
		end,
		MintyFreshCommand = function(self)
			self:settext(getCurRateDisplayString())
		end,
		CodeMessageCommand = function(self, params)
			local rate = getCurRateValue()
			ChangeMusicRate(rate, params)
			self:settext(getCurRateDisplayString())
		end,
		GoalSelectedMessageCommand = function(self)
			self:queuecommand("MintyFresh")
		end
	}

local function toggleNoteField()
	if song and not noteField then	-- first time setup
		noteField = true
		MESSAGEMAN:Broadcast("ChartPreviewOn") -- for banner reaction... lazy -mina
		mcbootlarder:playcommand("SetupNoteField")
		mcbootlarder:xy(prevX,prevY)
		mcbootlarder:GetChild("NoteField"):xy(prevX+idkwhatimdoing, prevY*1.5)
		if usingreverse then
			mcbootlarder:GetChild("NoteField"):y(prevY*1.5 + prevrevY)
		end
	return end

	if song then 
		if mcbootlarder:GetVisible() then
			mcbootlarder:visible(false)
			MESSAGEMAN:Broadcast("ChartPreviewOff")
		else
			mcbootlarder:visible(true)
			MESSAGEMAN:Broadcast("ChartPreviewOn")
		end
	end
end

t[#t + 1] =
	Def.Actor {
	MintyFreshCommand = function(self)
		if song then
			ptags = tags:get_data().playerTags
			steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			chartKey = steps:GetChartKey()
			ctags = {}
			for k, v in pairs(ptags) do
				if ptags[k][chartKey] then
					ctags[#ctags + 1] = k
				end
			end
		end
	end
}

t[#t + 1] = Def.ActorFrame {
	Name = "RateDependentStuff",	-- msd/display score/bpm/songlength -mina
	MintyFreshCommand = function()
		score = GetDisplayScore()
	end,
	CurrentRateChangedMessageCommand = function(self)
		self:queuecommand("MintyFresh")	--steps stuff
		self:queuecommand("MortyFarts") --songs stuff
	end,
	LoadFont("Common Normal") .. {
		Name = "MSD",
		InitCommand = function(self)
			self:xy(frameX + 58, frameY - 62):halign(0.5):maxwidth(110 / 0.6)
		end,
		MintyFreshCommand = function(self)
			if song then
				if steps:GetStepsType() == "StepsType_Dance_Single" then
					local meter = steps:GetMSD(getCurRateValue(), 1)
					self:settextf("%05.2f", meter)
					self:diffuse(byMSD(meter))
				else
					self:settextf("%5.2f", steps:GetMeter())	-- fallthrough to pre-defined meters for non 4k charts -mina
					self:diffuse(byDifficulty(steps:GetDifficulty()))
				end
			else
				self:settext("")
			end
		end
	},
	-- skillset suff (these 3 can prolly be wrapped)
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY - 60):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song then
				self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1))
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY - 30):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song then
				self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 2))
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song then
				self:settext(steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 3))
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	-- **score related stuff** These need to be updated with rate changed commands
	-- Primary percent score
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 55, frameY + 50):zoom(0.8):halign(0.5):maxwidth(125):valign(1)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:settextf("%05.2f%%", notShit.floor(score:GetWifeScore() * 10000) / 100)
				self:diffuse(getGradeColor(score:GetWifeGrade()))
			else
				self:settext("")
			end
		end,
	},
	-- Rate for the displayed score
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 55, frameY + 58):zoom(0.5):halign(0.5)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				local rate = notShit.round(score:GetMusicRate(), 3)
				local notCurRate = notShit.round(getCurRateValue(), 3) ~= rate
					local rate = string.format("%.2f", rate)
				if rate:sub(#rate, #rate) == "0" then
					rate = rate:sub(0, #rate - 1)
				end
				rate = rate .. "x"
					if notCurRate then
					self:settext("(" .. rate .. ")")
				else
					self:settext(rate)
				end
			else
				self:settext("")
			end
		end
	},
	-- goal for current rate if there is one stuff
	LoadFont("Common Normal") .. {
		Name = "Goalll",
		InitCommand = function(self)
			self:xy(frameX + 135, frameY + 33):zoom(0.6):halign(0.5):valign(0)
		end,
		MintyFreshCommand = function(self)
			if song and steps then
				local goal = profile:GetEasiestGoalForChartAndRate(steps:GetChartKey(), getCurRateValue())
				if goal then
					self:settextf("Target\n%.2f%%", goal:GetPercent() * 100)
				else
					self:settext("")
				end
			else
				self:settext("")
			end
		end
	},
	-- Date score achieved on
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 185, frameY + 59):zoom(0.4):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:settext(score:GetDate())
			else
				self:settext("")
			end
		end
	},
	-- MaxCombo
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 185, frameY + 49):zoom(0.4):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:settextf("Max Combo: %d", score:GetMaxCombo())
			else
				self:settext("")
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ClearType",
		InitCommand = function(self)
			self:xy(frameX + 185, frameY + 35):zoom(0.6):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then 
				self:visible(true)
				self:settext(getClearTypeFromScore(PLAYER_1, score, 0))
				self:diffuse(getClearTypeFromScore(PLAYER_1, score, 2))
			else
				self:visible(false)
			end
		end
	},
	-- **song stuff that scales with rate**
	Def.BPMDisplay {
		File = THEME:GetPathF("BPMDisplay", "bpm"),
		Name = "BPMDisplay",
		InitCommand = function(self)
			self:xy(capWideScale(get43size(384), 384) + 62, SCREEN_BOTTOM - 100):halign(1):zoom(0.50)
		end,
		MortyFartsCommand = function(self)
			if song then
				self:visible(true)
				self:SetFromSong(song)
			else
				self:visible(false)
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "PlayableDuration",
		InitCommand = function(self)
			self:xy((capWideScale(get43size(384), 384)) + 62, SCREEN_BOTTOM - 85):visible(true):halign(1):zoom(
				capWideScale(get43size(0.8), 0.8)
			):maxwidth(capWideScale(get43size(360), 360) / capWideScale(get43size(0.45), 0.45))
		end,
		MortyFartsCommand = function(self)
			if song then
				local playabletime = GetPlayableTime()
				self:settext(SecondsToMMSS(playabletime))
				self:diffuse(byMusicLength(playabletime))
			else
				self:settext("")
			end
		end
	}
}

-- "Radar values", noteinfo that isn't rate dependent -mina
local function radarPairs(i)
	local o =
		Def.ActorFrame {
		LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(frameX + 13, frameY - 52 + 13 * i):zoom(0.5):halign(0):maxwidth(120)
				end,
				MintyFreshCommand = function(self)
					if song then
						self:settext(ms.RelevantRadarsShort[i])
					else
						self:settext("")
					end
				end
			},
		LoadFont("Common Normal") .. {
				InitCommand = function(self)
					self:xy(frameX + 105, frameY + -52 + 13 * i):zoom(0.5):halign(1):maxwidth(60)
				end,
				MintyFreshCommand = function(self)
					if song then
						self:settext(steps:GetRelevantRadars(PLAYER_1)[i])
					else
						self:settext("")
					end
				end
			}
	}
	return o
end

local r = Def.ActorFrame{
	Name = "RadarValues"
}

-- Create the radar values
for i = 1, 5 do
	r[#r + 1] = radarPairs(i)
end

-- putting neg bpm warning here i guess
r[#r + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX, frameY - 120):halign(0):zoom(0.6)
		end,
		MintyFreshCommand = function(self)
			if song and steps:GetTimingData():HasWarps() then
				self:settext("NegBpms!")
			else
				self:settext("")
			end
		end
	}

t[#t + 1] = r

-- song only stuff that doesnt change with rate
t[#t + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(get43size(384), 384) + 41, SCREEN_BOTTOM - 100):halign(1):zoom(0.50)
		end,
		MortyFartsCommand = function(self)
			if song then
				self:settext("BPM")
			else
				self:settext("")
			end
		end
	}

-- cdtitle
t[#t + 1] =
	Def.Sprite {
	InitCommand = function(self)
		self:xy(capWideScale(get43size(344), 364) + 50, capWideScale(get43size(345), 255)):halign(0.5):valign(1)
	end,
	MortyFartsCommand = function(self)
		self:finishtweening()
			if song then
				if song:HasCDTitle() then
					self:visible(true)
					self:Load(song:GetCDTitlePath())
				else
					self:visible(false)
				end
			else
				self:visible(false)
			end
			local height = self:GetHeight()
			local width = self:GetWidth()

			if height >= 60 and width >= 75 then
				if height * (75 / 60) >= width then
					self:zoom(60 / height)
				else
					self:zoom(75 / width)
				end
			elseif height >= 60 then
				self:zoom(60 / height)
			elseif width >= 75 then
				self:zoom(75 / width)
			else
				self:zoom(1)
			end
	end,
	ChartPreviewOnMessageCommand=function(self)
		self:addx(capWideScale(34,0))
	end,
	ChartPreviewOffMessageCommand=function(self)
		self:addx(capWideScale(-34,0))
	end
}

t[#t + 1] =	
	Def.Sprite {
		Name = "Banner",
		InitCommand = function(self)
			self:x(10):y(61):halign(0):valign(0)
		end,
		MintyFreshCommand=function(self)
			if INPUTFILTER:IsBeingPressed("tab") then
				self:finishtweening():smooth(0.25):diffusealpha(0):sleep(0.2):queuecommand("ModifyBanner")
			else
				self:finishtweening():queuecommand("ModifyBanner")
			end
		end,
		ModifyBannerCommand = function(self)
			self:finishtweening()
			if song then
				local bnpath = GAMESTATE:GetCurrentSong():GetBannerPath()
				if not bnpath then
					bnpath = THEME:GetPathG("Common", "fallback banner")
				end
				self:LoadBackground(bnpath)
			else
				local bnpath = SONGMAN:GetSongGroupBannerPath(SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection())
				if not bnpath or bnpath == "" then
					bnpath = THEME:GetPathG("Common", "fallback banner")
				end
				self:LoadBackground(bnpath)
			end
			self:scaletoclipped(capWideScale(get43size(384), 384), capWideScale(get43size(120), 120)):diffusealpha(1)
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
}

t[#t + 1] =
	Def.Quad {
	InitCommand = function(self)
		self:xy(frameX + 135, frameY + 45):zoomto(50, 40):diffusealpha(0)
	end,
	MouseLeftClickMessageCommand = function(self)
		if song and steps then
			local sg = profile:GetEasiestGoalForChartAndRate(steps:GetChartKey(), getCurRateValue())
			if sg and isOver(self) and update then
				sg:SetPercent(sg:GetPercent() + 0.01)
				self:GetParent():GetChild("RateDependentStuff"):GetChild("Goalll"):queuecommand("MintyFresh")
			end
		end
	end,
	MouseRightClickMessageCommand = function(self)
		if song and steps then
			local sg = profile:GetEasiestGoalForChartAndRate(steps:GetChartKey(), getCurRateValue())
			if sg and isOver(self) and update then
				sg:SetPercent(sg:GetPercent() - 0.01)
				self:GetParent():GetChild("RateDependentStuff"):GetChild("Goalll"):queuecommand("MintyFresh")
			end
		end
	end
}

-- t[#t+1] = LoadFont("Common Large") .. {
-- InitCommand=function(self)
-- 	self:xy((capWideScale(get43size(384),384))+68,SCREEN_BOTTOM-135):halign(1):zoom(0.4,maxwidth,125)
-- end,
-- BeginCommand=function(self)
-- 	self:queuecommand("Set")
-- end,
-- SetCommand=function(self)
-- if song then
-- self:settext(song:GetOrTryAtLeastToGetSimfileAuthor())
-- else
-- self:settext("")
-- end
-- end,
-- CurrentStepsP1ChangedMessageCommand=function(self)
-- 	self:queuecommand("Set")
-- end,
-- RefreshChartInfoMessageCommand=function(self)
-- 	self:queuecommand("Set")
-- end,
-- }

-- active filters display
-- t[#t+1] = Def.Quad{InitCommand=cmd(xy,16,capWideScale(SCREEN_TOP+172,SCREEN_TOP+194);zoomto,SCREEN_WIDTH*1.35*0.4 + 8,24;halign,0;valign,0.5;diffuse,color("#000000");diffusealpha,0),
-- EndingSearchMessageCommand=function(self)
-- self:diffusealpha(1)
-- end
-- }
-- t[#t+1] = LoadFont("Common Large") .. {
-- InitCommand=function(self)
-- 	self:xy(20,capWideScale(SCREEN_TOP+170,SCREEN_TOP+194)):halign(0):zoom(0.4):settext("Active Filters: "..GetPersistentSearch()):maxwidth(SCREEN_WIDTH*1.35)
-- end,
-- EndingSearchMessageCommand=function(self, msg)
-- self:settext("Active Filters: "..msg.ActiveFilter)
-- end
-- }


-- tags?
t[#t + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 300, frameY - 60):halign(0):zoom(0.6):maxwidth(450)
		end,
		MintyFreshCommand = function(self)
			if song and ctags[1] then
				self:settext(ctags[1])
			else
				self:settext("")
			end
		end
	}

t[#t + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 300, frameY - 30):halign(0):zoom(0.6):maxwidth(450)
		end,
		MintyFreshCommand = function(self)
			if song and ctags[2] then
				self:settext(ctags[2])
			else
				self:settext("")
			end
		end
	}

t[#t + 1] =
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 300, frameY):halign(0):zoom(0.6):maxwidth(450)
		end,
		MintyFreshCommand = function(self)
			if song and ctags[3] then
				self:settext(ctags[3])
			else
				self:settext("")
			end
		end
	}

--Chart Preview Button
local yesiwantnotefield = false

local function ihatestickinginputcallbackseverywhere(event)
	if event.type ~= "InputEventType_Release" and getTabIndex() == 0 then
				if event.DeviceInput.button == "DeviceButton_space" then
					toggleNoteField()
				end
			end
	return false
end

t[#t + 1] = LoadFont("Common Normal") .. {
	Name = "PreviewViewer",
	BeginCommand = function(self)
		mcbootlarder = self:GetParent():GetChild("ChartPreview")
		SCREENMAN:GetTopScreen():AddInputCallback(ihatestickinginputcallbackseverywhere)
		self:xy(20, 235)
		self:zoom(0.5)
		self:halign(0)
		self:settext("Toggle Preview")
	end,
	MouseLeftClickMessageCommand = function(self)
		if isOver(self) and (song or noteField) then
			 toggleNoteField()
		end
	end,
	CurrentStyleChangedMessageCommand=function(self)	-- need to regenerate the notefield when changing styles or crashman appears -mina
		if noteField then
			SCREENMAN:GetTopScreen():DeletePreviewNoteField(mcbootlarder)
			noteField = false
			toggleNoteField()
		end
	end
}

	t[#t + 1] = LoadActor("../_chartpreview.lua")
return t
