local addon, ns = ...
local cfg = CreateFrame("Frame")

-- layout
cfg.widescreen = true;

-- position
cfg.position = {
	x = 305,		-- original position is 305
	y = -75,		-- original position is -125
}

-- fonts
local fontFolder = "Interface\\AddOns\\oUF_AlekkUI\\fonts\\"
cfg.fontName = fontFolder.."CalibriBold.ttf"
cfg.fontNamePixel = fontFolder.."Calibri.ttf"
cfg.baseFontSize = 13

--textures
local textureFolder = "Interface\\AddOns\\oUF_AlekkUI\\textures\\"
cfg.textureHealthBar = textureFolder.."Ruben"
cfg.textureRuneBar = textureFolder.."rothTex"
cfg.textureBorder = textureFolder.."Caith"
cfg.textureBubble = textureFolder.."bubbleTex"
cfg.textureCastBarBorder = textureFolder.."border"
cfg.textureGlow = textureFolder.."glowTex"
cfg.backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = textureFolder.."border", edgeSize = 12,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}
cfg.backdrophp = {
	bgFile = textureFolder.."Ruben",
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

-- mobs level text
cfg.classification = {
	worldboss = '%s |cffffd700Boss|r',
	rareelite = '%s |cffffd700R+|r',
	elite = '%s |cffffd700++|r',
	rare = '%s Rare',
	normal = '%s',
	trivial = '%s',
}

-- colors
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

ns.cfg = cfg
