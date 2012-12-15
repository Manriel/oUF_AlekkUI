if GetLocale() ~= "ruRU" then return nil end

local addon, ns = ...
local Locale = MyLocalizationTable;

Locale = {
	["Offline"] = "Не в сети",
	["Dead"] = "Мертв",
	["Ghost"] = "Призрак",
	
	["worldboss"] = "Босс",
	["rareelite"] = "Редкая Элита",
	["elite"] = "Элита",
	["rare"] = "Редкий",
	["normal"] = "Обычный",
	["trivial"] = "Слабый",
	["minus"] = "Минус",
}

ns.Locale = Locale