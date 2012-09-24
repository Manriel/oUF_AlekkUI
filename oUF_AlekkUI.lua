local xPosition = -75; -- -125

local fontName = "Interface\\AddOns\\oUF_AlekkUI\\fonts\\CalibriBold.ttf"
local fontNamePixel = "Interface\\AddOns\\oUF_AlekkUI\\fonts\\Calibri.ttf"
local baseFontSize = 13

local textureHealthBar = "Interface\\AddOns\\oUF_AlekkUI\\textures\\Ruben"
local textureRuneBar = "Interface\\AddOns\\oUF_AlekkUI\\textures\\rothTex"
local textureBorder = "Interface\\AddOns\\oUF_AlekkUI\\textures\\Caith"
local textureBubble = 'Interface\\Addons\\oUF_AlekkUI\\textures\\bubbleTex'
local textureCastBarBorder = 'Interface\\AddOns\\oUF_AlekkUI\\textures\\border'
local textureGlow = 'Interface\\Addons\\oUF_AlekkUI\\media\\glowTex'

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\AddOns\\oUF_AlekkUI\\textures\\border", edgeSize = 12,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local backdrophp = {
	bgFile = "Interface\\AddOns\\oUF_AlekkUI\\textures\\Ruben",
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local classification = {
	worldboss = '%s |cffffd700Boss|r',
	rareelite = '%s |cffffd700R+|r',
	elite = '%s |cffffd700++|r',
	rare = '%s Rare',
	normal = '%s',
	trivial = '%s',
}

oUF.colors.power['MANA'] = {.30,.45,.65}
oUF.colors.power['RAGE'] = {.70,.30,.30}
oUF.colors.power['FOCUS'] = {.70,.45,.25}
oUF.colors.power['ENERGY'] = {.65,.65,.35}
oUF.colors.power['RUNIC_POWER'] = {.45,.45,.75}

oUF.colors.runes = {
		[1] = {.69, .31, .31},
		[2] = {.33, .59, .33},
		[3] = {.31, .45, .63},
		[4] = {.84, .75, .05},
}

oUF.colors.tapped = {.55,.57,.61}
oUF.colors.disconnected = {.5,.5,.5}

local siValue = function(val)
	if val >= 1e6 then
		return string.format("%.1fm", val/1e6)
	elseif val >= 1e3 then
		return string.format("%.1fk", val/1e3)
	else
		return val
	end	
end

local setFontString = function(parent, fontStyle, fontHeight)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontStyle, fontHeight)
	fs:SetShadowColor(0,0,0)
	fs:SetShadowOffset(1, -1)
	fs:SetTextColor(1,1,1)
	fs:SetJustifyH("LEFT")
	return fs
end

local getDifficultyColor = function(level)
	if level == '??' or level == '-1' then
		return  1,0.84,1 -- .69,.31,.31
	else
	local levelDiff = UnitLevel('target') - UnitLevel('player')
		if levelDiff >= 5 then
			return .69,.31,.31
		elseif levelDiff >= 3 then
			return .71,.43,.27
		elseif levelDiff >= -2 then
			return .84,.75,.65
		elseif -levelDiff <= GetQuestGreenRange() then
			return .33,.59,.33
		else
			return  .55,.57,.61
		end
	end
end

local function OverrideUpdateName(self, event, unit)
	if(self.unit ~= unit or not self.Name) then return end
	if(unit == 'player') then
		self.Name:Hide()
	else
		self.Name:SetText(UnitName(unit))
	end

	if (UnitClassification(unit)== "worldboss" or UnitClassification(unit)== "rareelite" or UnitClassification(unit)== "elite") then
		self:SetBackdropBorderColor(1,0.84,0,1)
	else
		self:SetBackdropBorderColor(1,1,1,1)
	end	
	
	if(unit == 'player' or unit == 'target') then
		local level = not UnitIsConnected(unit) and '??' or UnitLevel(unit) < 1 and '??' or UnitLevel(unit)
		self.Lvl:SetFormattedText(classification[UnitClassification(unit)], level)


		if UnitCanAttack("player", unit) then
			self.Lvl:SetTextColor(getDifficultyColor(level))
		else
			self.Lvl:SetTextColor(1, 1, 1)
		end

		local color
		if UnitIsPlayer(unit) then	
			color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
			local class, classFileName = UnitClass(unit)
			if ( class == 'Чернокнижница' ) or ( class == 'Чернокнижник' ) then
				class = 'Варлок'
			elseif (class == 'Рыцарь смерти') then
				class='Р. смерти'
			end
			self.Class:SetText(class);
		else
			self.Class:SetText(UnitCreatureFamily(unit) or UnitCreatureType(unit))
		end
		if not color then color = { r = 1, g = 1, b = 1} end
		self.Class:SetVertexColor(color.r, color.g, color.b)
		self.Race:SetText(UnitRace(unit))
	end
end


local function updateColor(self, unit, Health)
	local color, colorRGB
	local _, class = UnitClass(unit)

	if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		color = {.5,.5,.5}
	elseif(UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit)) then
		color = {.5,.5,.5}
	elseif(UnitIsPlayer(unit)) then
		color = oUF.colors.class[class]
	else
		colorRGB = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]	
	end
	if(color) then
		Health:SetStatusBarColor(color[1], color[2], color[3])	
		Health:SetBackdropColor(color[1]/2.5, color[2]/2.5, color[3]/2.5,0.8)
	elseif(colorRGB) then
		Health:SetStatusBarColor(colorRGB.r, colorRGB.g, colorRGB.b)	
		Health:SetBackdropColor(colorRGB.r/2.5, colorRGB.g/2.5, colorRGB.b/2.5, 0.8)
	end
end

local function PostUpdateHealth(Health, unit, min, max)
	local self = Health:GetParent()
	if(not UnitIsConnected(unit)) then
		Health:SetValue(0)
		Health.value:SetText('|cffD7BEA5'..'Offline')
	elseif(UnitIsDead(unit)) then
		Health:SetValue(0)
		Health.value:SetText('|cffD7BEA5'..'Dead')
	elseif(UnitIsGhost(unit)) then
		Health:SetValue(0)
		Health.value:SetText('|cffD7BEA5'..'Ghost')
	else
		if(unit=="player") then
			Health.value:SetFormattedText("%d | %d | %d|cffffffff%%",min, max ,floor(min/max*100))
		elseif (unit=="target") then
			Health.value:SetFormattedText("%.1f|cffffffff%% | %s", (min/max*100),siValue(max))
		else
			Health.value:SetFormattedText("%d|cffffffff%%", floor(min/max*100))
		end
	end
	
	updateColor(self, unit, Health)
	self:UNIT_NAME_UPDATE(event, unit)
end

local function PostUpdatePower(Power, unit, min, max)-- (self, event, unit, bar, min, max)
	local self = Power:GetParent()
    if max == 0 or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then  
        Power:SetValue(0) 
        if Power.value then
            Power.value:SetText()
        end
    elseif Power.value then
		if(unit=='player') then  
			Power.value:SetText(min .. ' | ' .. max)
		elseif(unit=="target") then
			Power.value:SetText(siValue(min) .. ' | ' .. siValue(max))
		else
			Power.value:SetText()  
		end
	end
	
	local _, pType = UnitPowerType(unit)
	local color = self.colors.power[pType] or {0.7,0.7,0.7}
	
	Power:SetStatusBarColor(color[1], color[2], color[3]) 
	Power:SetBackdropColor(color[1]/3, color[2]/3, color[3]/3,1)
	
	--self:UNIT_NAME_UPDATE(event, unit)
end

local function OverrideCastbarTime(self, duration)
		if(self.channeling) then
			self.Time:SetFormattedText('%.1f / %.2f', self.max - duration, self.max)
		elseif(self.casting) then
			self.Time:SetFormattedText('%.1f / %.2f', duration, self.max)
		end	
end

local function OverrideCastbarDelay(self, duration)
		if(self.channeling) then
			self.Time:SetFormattedText('%.1f / %.2f |cffff0000+ %.1f', self.max - duration, self.max, self.delay)
		elseif(self.casting) then
			self.Time:SetFormattedText('%.1f / %.2f |cffff0000+ %.1f', duration, self.max, self.delay)
		end	
end

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub('(.)', string.upper, 1)

	if(unit == 'party') then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor', 0, 0)
	elseif(_G[cunit..'FrameDropDown']) then
		ToggleDropDownMenu(1, nil, _G[cunit..'FrameDropDown'], 'cursor', 0, 0)
	end
end

local function Style(self, unit)
	
	self.menu = menu
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0,0,0,1)
	if unit == "targettarget" or unit == "focus" or unit == "focustarget" then
		self:SetWidth(135)
		self:SetHeight(25)
	elseif unit == "player" or unit == "target" then
		self:SetWidth(275)
		self:SetHeight(47)
	else
		self:SetWidth(125)
		self:SetHeight(38)
	end
	
-- health
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture(textureHealthBar)
	Health:SetPoint("LEFT", 4.5,0)
	Health:SetPoint("RIGHT", -4.5,0)
	Health:SetPoint("TOP", 0,-4.5)
	Health:SetBackdrop(backdrophp)
	Health:SetBackdropColor(.25,.25,.25,1);
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true
	--set helathBar Height
	if unit == "targettarget" or unit == "focus" or unit == "focustarget" then
		Health:SetHeight(16.5)
	elseif unit == "player" or unit == "target" then
		Health:SetHeight(27)
	else
		Health:SetHeight(23)
	end
	self.Health = Health
	
-- health value label
	self.Health.value = setFontString(self.Health, fontName, baseFontSize)
	if unit == "player" or unit == "focus"  or unit == "focustarget" or not unit then
		self.Health.value:SetPoint("RIGHT", -3,0)
	elseif unit == "pet" then
		self.Health.value:SetPoint("TOPRIGHT",self.Health, "TOPRIGHT", -3,-2)
	else 
		self.Health.value:SetPoint("LEFT", 2, 0)
	end
	
-- power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(9.5)
	Power:SetStatusBarTexture(textureHealthBar)
	Power:SetPoint("LEFT", self.Health)
	Power:SetPoint("RIGHT", self.Health)
	Power:SetPoint("TOP", self.Health, "BOTTOM", 0, 0)
	Power:SetBackdrop(backdrophp)
	Power:SetBackdropColor(.25,.25,.25,1);
	Power.ColotSmooth = true
	Power.frequentUpdates = true
	
	self.Power = Power
	
	--set powerBar Height
	if unit == "targettarget" or unit == "focus" or unit == "focustarget" then
		Power:SetHeight(1)
	elseif unit == "player" or unit == "target" then
		Power:SetHeight(10.5)
	else
		Power:SetHeight(6)
	end
-- power value label
	if(unit=="player" or unit=="target") then
		Power.value = setFontString(self.Power, fontName, baseFontSize-1)
		if(unit=="player") then
			Power.value:SetPoint("RIGHT", self.Power, "RIGHT", -3, 0)
		elseif(unit=="target") then
			Power.value:SetPoint("LEFT", self.Power, "LEFT", 2,0)
		end
	end
	
	self.Power = Power

-- name
	local Name = setFontString(self.Health, fontName, baseFontSize)
	if unit == "focus" or unit == "focustarget"  then
		Name:SetPoint("LEFT", self.Health, "LEFT",2,0)
		Name:SetWidth(80)
	elseif unit == "pet" then
		Name:SetPoint("TOPLEFT", self.Health, "TOPLEFT",2,-2)
		Name:SetWidth(80)
	elseif unit == "player" then
		Name:Hide()
	elseif unit == "target" then
		Name:SetPoint("RIGHT", self.Health, "RIGHT",-3,0)
		Name:SetWidth(170)
		Name:SetFont(fontName, 13)
		Name:SetJustifyH('RIGHT')
	elseif unit == "targettarget" then
		Name:SetPoint("RIGHT", self.Health, "RIGHT",-3,0)
		Name:SetWidth(80)
		Name:SetJustifyH('RIGHT')
	elseif not unit then
		Name:SetPoint("LEFT", self.Health, "LEFT",2,0)
		Name:SetWidth(80)
	end
	Name:SetHeight(20)
	
	self.Name = Name
	
-- level, class, race labels
	if unit == "player" then
		local lvl, class, race
		
		lvl = setFontString(self.Power, fontName, baseFontSize-1)
		lvl:SetPoint("LEFT", self.Power, "LEFT", 2, 0.5)
		self.Lvl = lvl

		class = setFontString(self.Power, fontName, baseFontSize-1)
		class:SetPoint("LEFT", lvl, "RIGHT",  1, 0)
		self.Class = class
	
		race = setFontString(self.Power, fontName, baseFontSize-1)
		race:SetPoint("LEFT", class, "RIGHT",  1, 0)
		self.Race = race

	elseif unit == "target" then
		local lvl, class, race

		race = setFontString(self.Power, fontName, baseFontSize-1)
		race:SetPoint("RIGHT", self.Power, "RIGHT",  -2, 0.5)
		self.Race = race
		
		class = setFontString(self.Power, fontName, baseFontSize-1)
		class:SetPoint("RIGHT", race, "LEFT",  -1, 0)
		self.Class = class
		
		lvl = setFontString(self.Power, fontName, baseFontSize-1)
		lvl:SetPoint("RIGHT", class, "LEFT", -2, 0)
		self.Lvl = lvl
	end
	
-- raid icon
--	if(unit=="player" or unit=="target" or unit == "focustarget") then
		local icon = self.Health:CreateTexture(nil, "OVERLAY")
		icon:SetHeight(18)
		icon:SetWidth(18)
		icon:SetPoint("TOP", self, 0, 5)
		self.RaidIcon = icon
--	end
	
	if(unit=="player" or unit=="target") then
	
		local Leader = self.Health:CreateTexture(nil, "OVERLAY")
		Leader:SetHeight(16)
		Leader:SetWidth(16)
		if(unit=="player") then
			Leader:SetPoint("LEFT", Health, "TOPLEFT", 0, 0)
		else
			Leader:SetPoint("RIGHT", Health, "TOPRIGHT", 0, 0)
		end
		self.Leader = Leader
		
		local MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
		MasterLooter:SetHeight(16)
		MasterLooter:SetWidth(16)
		if(unit=="player") then
			MasterLooter:SetPoint("LEFT", Leader, "RIGHT", 0, 0)
		else
			MasterLooter:SetPoint("RIGHT", Leader, "LEFT", 0, 0)
		end
		self.MasterLooter = MasterLooter
		
	end
	
-- buffs and debuffs
	if(unit=='player') then
	--	hide Blizzard Buff frames
	--	BuffFrame:Hide()
	--	hide Blizzard Enchant frames
	--	TemporaryEnchantFrame:Hide()
		
		local Debuffs =  CreateFrame("Frame", nil, self)
		Debuffs:SetHeight(41*4)
		Debuffs:SetWidth(41*4)
		Debuffs.size = 30
		Debuffs.spacing = 1
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
		
		self.Debuffs = Debuffs
	--[[	
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetHeight(320)
		Buffs:SetWidth(42 * 12)
		Buffs.size = 42
		Buffs.spacing = 5
		Buffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -35)
		Buffs.initialAnchor = "TOPRIGHT"
		Buffs["growth-x"] = "LEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs.filter = true
		
		self.Buffs = Buffs
	]]
			
	elseif(unit=='target') then 
		local Auras = CreateFrame('StatusBar', nil, self)
		Auras:SetHeight(120)
		Auras:SetWidth(280)
		Auras:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 1, 2)
		Auras['growth-x'] = 'RIGHT'
		Auras['growth-y'] = 'UP' 
		Auras.initialAnchor = 'BOTTOMLEFT'
		Auras.spacing = 2.5
		Auras.size = 28
		Auras.gap = true
		Auras.numBuffs = 18 
		Auras.numDebuffs = 18 
		
		self.Auras = Auras
		
		self.sortAuras = {}
		self.sortAuras.selfFirst = true
		
		
	elseif(unit=='pet') then 
		local Auras =  CreateFrame('StatusBar', nil, self)
		Auras:SetHeight(100)
		Auras:SetWidth(130)
		Auras:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)
		Auras['growth-x'] = 'RIGHT'
		Auras['growth-y'] = 'DOWN'
		Auras.initialAnchor = 'TOPLEFT' 
		Auras.spacing = 1.0
		Auras.size = 24
		Auras.gap = true
		Auras.numBuffs = 15
		Auras.numDebuffs = 40
		
		self.Auras = Auras
	end
	
--	combat indicator
	if(unit == 'player') then
		local Combat = self.Health:CreateTexture(nil, 'OVERLAY')
		Combat:SetHeight(17)
		Combat:SetWidth(17)
		Combat:SetPoint('TOPRIGHT', 2, 12)
		Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)
		
		self.Combat = Combat
	end

--CastBars
	if(unit == 'player') then
		local colorcb
		local _,classcb = UnitClass(unit)
		colorcb = oUF.colors.class[classcb]

		self.Castbar = CreateFrame('StatusBar', nil, self)
		self.Castbar:SetPoint('TOP', UIParentr, 'CENTER', 0, xPosition)
		self.Castbar:SetStatusBarTexture(textureHealthBar)
		self.Castbar:SetStatusBarColor(colorcb[1], colorcb[2], colorcb[3])
		self.Castbar:SetBackdrop(backdrophp)
		self.Castbar:SetBackdropColor(colorcb[1]/3, colorcb[2]/3, colorcb[3]/3)
		self.Castbar:SetHeight(19)
		self.Castbar:SetWidth(325)
		
		self.Castbar.Spark = self.Castbar:CreateTexture(nil,'OVERLAY')
		self.Castbar.Spark:SetBlendMode("ADD")
		self.Castbar.Spark:SetHeight(55)
		self.Castbar.Spark:SetWidth(27)
		self.Castbar.Spark:SetVertexColor(colorcb[1], colorcb[2], colorcb[3])
		
		self.Castbar.Text = setFontString(self.Castbar, fontName, baseFontSize)
		self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)

		self.Castbar.Time = setFontString(self.Castbar, fontName, baseFontSize)
		self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -2, 0)
		self.Castbar.CustomTimeText = OverrideCastbarTime
		self.Castbar.CustomDelayText = OverrideCastbarDelay
		
		self.Castbar2 = CreateFrame('StatusBar', nil, self.Castbar)
		self.Castbar2:SetPoint('BOTTOMRIGHT', self.Castbar, 'BOTTOMRIGHT', 4, -4)
		self.Castbar2:SetPoint('TOPLEFT', self.Castbar, 'TOPLEFT', -4, 4)
		self.Castbar2:SetBackdrop(backdrop)
		self.Castbar2:SetBackdropColor(0,0,0,1)
		self.Castbar2:SetHeight(27)
		self.Castbar2:SetFrameLevel(0)
		
		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,'BACKGROUND')
		self.Castbar.SafeZone:SetPoint('TOPRIGHT')
		self.Castbar.SafeZone:SetPoint('BOTTOMRIGHT')
		self.Castbar.SafeZone:SetHeight(20)
		self.Castbar.SafeZone:SetTexture(textureHealthBar)
		self.Castbar.SafeZone:SetVertexColor(1,1,.01,0.5)
		
	end
	if(unit == 'target') then
		self.Castbar = CreateFrame('StatusBar', nil, self)
		self.Castbar:SetPoint('TOP', UIParentr, 'CENTER', 0, xPosition+19)
		self.Castbar:SetStatusBarTexture(textureHealthBar)
		self.Castbar:SetStatusBarColor(.81,.81,.25)
		self.Castbar:SetBackdrop(backdrophp)
		self.Castbar:SetBackdropColor(.81/3,.81/3,.25/3)
		self.Castbar:SetHeight(11)
		self.Castbar:SetWidth(325)
		
		self.Castbar.Text = setFontString(self.Castbar, fontName, 12)
		self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)

		self.Castbar.Time = setFontString(self.Castbar, fontName, 12)
		self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -2, 0)
		self.Castbar.CustomTimeText = OverrideCastbarTime
		
		self.Castbar2 = CreateFrame('StatusBar', nil, self.Castbar)
		self.Castbar2:SetPoint('BOTTOMRIGHT', self.Castbar, 'BOTTOMRIGHT', 4, -4)
		self.Castbar2:SetPoint('TOPLEFT', self.Castbar, 'TOPLEFT', -4, 4)
		self.Castbar2:SetBackdrop(backdrop)
		self.Castbar2:SetBackdropColor(0,0,0,1)
		self.Castbar2:SetHeight(21)
		self.Castbar2:SetFrameLevel(0)
		
		self.Castbar.Spark = self.Castbar:CreateTexture(nil,'OVERLAY')
		self.Castbar.Spark:SetBlendMode("Add")
		self.Castbar.Spark:SetHeight(35)
		self.Castbar.Spark:SetWidth(25)
		self.Castbar.Spark:SetVertexColor(.69,.31,.31)
	end
	if(unit == 'focus') then
		self.Castbar = CreateFrame('StatusBar', nil, self)
		self.Castbar:SetPoint('TOP', UIParentr, 'CENTER', 0, xPosition-28)
		self.Castbar:SetStatusBarTexture(textureHealthBar)
		self.Castbar:SetStatusBarColor(.79,.41,.31)
		self.Castbar:SetBackdrop(backdrophp)
		self.Castbar:SetBackdropColor(.79/3,.41/3,.31/3)
		self.Castbar:SetHeight(11)
		self.Castbar:SetWidth(325)
		
		self.Castbar.Text = setFontString(self.Castbar, fontName, 12)
		self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)

		self.Castbar.Time = setFontString(self.Castbar, fontName, 12)
		self.Castbar.Time:SetPoint('RIGHT', self.Castbar, -2, 0)
		self.Castbar.CustomTimeText = OverrideCastbarTime
		
		self.Castbar2 = CreateFrame('StatusBar', nil, self.Castbar)
		self.Castbar2:SetPoint('BOTTOMRIGHT', self.Castbar, 'BOTTOMRIGHT', 4, -4)
		self.Castbar2:SetPoint('TOPLEFT', self.Castbar, 'TOPLEFT', -4, 4)
		self.Castbar2:SetBackdrop(backdrop)
		self.Castbar2:SetBackdropColor(0,0,0,1)
		self.Castbar2:SetHeight(21)
		self.Castbar2:SetFrameLevel(0)
		
		self.Castbar.Spark = self.Castbar:CreateTexture(nil,'OVERLAY')
		self.Castbar.Spark:SetBlendMode("Add")
		self.Castbar.Spark:SetHeight(35)
		self.Castbar.Spark:SetWidth(25)
		self.Castbar.Spark:SetVertexColor(.69,.31,.31)
	end

-- WORKS!!!
--	ComboPoints	
	if(unit == 'target') then
		local _, class = UnitClass(unit)
			local cpf = CreateFrame("Frame", nil, self)
			cpf:SetPoint("BOTTOMLEFT", 5, -16)
			cpf:SetSize(100, 20)
			for i = 1, 5 do
				cpf[i] = CreateFrame("StatusBar", self:GetName().."_ComboPoints"..i, self)
				cpf[i]:SetSize(16, 16)
				cpf[i]:SetStatusBarTexture(textureBubble)
				if ((i >= 3) and (i <= 4)) then
					cpf[i]:SetStatusBarColor(.67,.67,.33)
				elseif (i < 4) then
					cpf[i]:SetStatusBarColor(.69,.31,.31)
				else
					cpf[i]:SetStatusBarColor(.33,.63,.33)	
				end
				cpf[i]:SetFrameLevel(10)
				local h = CreateFrame("Frame", nil, cpf[i])
				h:SetFrameLevel(10)
				h:SetPoint("TOPLEFT",-4,3)
				h:SetPoint("BOTTOMRIGHT",4,-3)
				if (i == 1) then
					cpf[i]:SetPoint('LEFT', cpf, 'LEFT', 1, 0)
				else
					cpf[i]:SetPoint('TOPLEFT', cpf[i-1], "TOPRIGHT", 2, 0)
				end

			end
			self.CPoints = cpf
	end

-- WORKS!!!
--	Holy Power
	if(unit == 'player') then
	local _, class = UnitClass(unit)
		if (class == 'PALADIN') then
			local hpf = CreateFrame("Frame", nil, self)
			hpf:SetPoint("TOPLEFT", 5, -8)
			hpf:SetSize(100, 20)
			for i = 1, 5 do
				hpf[i] = CreateFrame("StatusBar", self:GetName().."_Holypower"..i, self)
				hpf[i]:SetSize(16, 16)
				hpf[i]:SetStatusBarTexture(textureBubble)
				hpf[i]:SetStatusBarColor(.96,.91,.29)  --(.95,.88,.48)
				hpf[i]:SetFrameLevel(10)
				local h = CreateFrame("Frame", nil, hpf[i])
				h:SetFrameLevel(10)
				h:SetPoint("TOPLEFT",-4,3)
				h:SetPoint("BOTTOMRIGHT",4,-3)
				if (i == 1) then
					hpf[i]:SetPoint('LEFT', hpf, 'LEFT', 1, 0)
				else
					hpf[i]:SetPoint('TOPLEFT', hpf[i-1], "TOPRIGHT", 2, 0)
				end

			end
			self.HolyPower = hpf			
			
		end			
	end

-- WORKS!!!
-- shadow orbs
	if(unit == 'player') then
	local _, class = UnitClass(unit)
		if (class == 'PRIEST') then
			local so = CreateFrame("Frame", nil, self)
			so:SetPoint("TOPLEFT", 5, -8)
			so:SetSize(100, 20)
			local maxOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)
			for i = 1,maxOrbs do
				so[i] = CreateFrame("StatusBar", self:GetName().."_so"..i, self)
				so[i]:SetSize(16, 16)
				so[i]:SetStatusBarTexture(textureBubble)
				so[i]:SetStatusBarColor(1,1,1)
				so[i]:SetFrameLevel(11)
				--helper backdrop
				local h = CreateFrame("Frame", nil, so[i])
				h:SetFrameLevel(10)
				h:SetPoint("TOPLEFT",-4,3)
				h:SetPoint("BOTTOMRIGHT",4,-3)
				if (i == 1) then
					so[i]:SetPoint('LEFT', so, 'LEFT', 1, 0)
				else
					so[i]:SetPoint('TOPLEFT', so[i-1], 'TOPRIGHT', 2, 0)
				end
			end
			self.ShadowOrbs = so
		end
	end

-- WORKS!!!
--Runes
    if (unit == 'player') then 
	local _, class = UnitClass(unit)
		if (class == 'DEATHKNIGHT') then
			self.Runes = CreateFrame("StatusBar", nil, self)
			self.Runes:SetPoint("TOP", -172, 0)
			self.Runes:SetSize(70, 47)
			
				self.Runes:SetBackdrop(backdrop)
				self.Runes:SetBackdropColor(0,0,0,.5)
			
				
			for i = 1, 6 do
				r = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
				r:SetSize(16 , 16)
				r:SetFrameLevel(11)
				if (i%2 == 0) then
					r:SetPoint("TOP", self.Runes[i-1], "BOTTOM", 0, -5)
				elseif (i == 1) then
					r:SetPoint("TOPRIGHT", self.Runes, "TOPRIGHT", -6, -5)
				else
					r:SetPoint("RIGHT", self.Runes[i-2], "LEFT", -5, 0)
				end
				r:SetStatusBarTexture(textureRuneBar)
				r:GetStatusBarTexture():SetHorizTile(false)
				r.bd = r:CreateTexture(nil, "BORDER")
				r.bd:SetAllPoints()
				r.bd:SetTexture(textureRuneBar)
				r.bd:SetVertexColor(0.15, 0.15, 0.15)
				
				local h = CreateFrame("Frame", nil, r)
				h:SetFrameLevel(10)
				h:SetPoint("TOPLEFT",-4,3)
				h:SetPoint("BOTTOMRIGHT",4,-3)
				h:SetBackdrop(backdrop)
				h:SetBackdropColor(0,0,0,1)
				self.Runes[i] = r
			end
      end
	end
	
-- TODO:
--	eclipse bar for druids
--	TotemBar for shamans
--	harmony bar for monks
--	bar for warlocks' spec-specific powers
	
	
--[[
	self.PostCreateAuraIcon = PostCreateAuraIcon
	self.PostUpdateAuraIcon = PostUpdateAuraIcon]]

	self.UNIT_NAME_UPDATE = OverrideUpdateName
	Health.PostUpdate = PostUpdateHealth
	Power.PostUpdate = PostUpdatePower
	
--[[	self.PostCreateEnchantIcon = PostCreateAuraIcon
	self.PostUpdateEnchantIcons = CreateEnchantTimer
]]
	return self
end

oUF:RegisterStyle('AlekkUI', Style)
oUF:SetActiveStyle('AlekkUI')

local player = oUF:Spawn("player")
player:SetPoint("CENTER", -305, xPosition) -- -305, -125
local target = oUF:Spawn("target")
target:SetPoint("CENTER", 305, xPosition) -- 305, -125)
local pet = oUF:Spawn("pet")
pet:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -75)
local tt = oUF:Spawn("targettarget")
tt:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -1)
local focus = oUF:Spawn("focus")
focus:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -1)
local focustarget = oUF:Spawn("focustarget")
focustarget:SetPoint("TOPLEFT", focus, "TOPRIGHT", 5, 0)

--[[
local function CreateMainTankStyle(self, unit)
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0,0,0,1)
	local maintank = CreateFrame("StatusBar", nil, self)
	maintank:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 8, 225)
end

oUF:RegisterStyle('AlekkUI-MainTank', CreateMainTankStyle)
oUF:SetActiveStyle('AlekkUI-MainTank')

local maintank = oUF:Spawn('header', 'oUF_MainTank')
maintank:SetAttribute("showRaid", true)
maintank:SetAttribute("groupFilter", "MAINTANK")
maintank:SetAttribute("yOffset", -3)
maintank:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 8, 225)
maintank:SetAttribute("template", "oUF_MTT")
maintank:Show()
]]