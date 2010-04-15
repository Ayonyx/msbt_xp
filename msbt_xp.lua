-------------------------------------------------------------------------------
-- Title: MSBT - XP
-- Author: Adalyn - Korgath US
-------------------------------------------------------------------------------
local print = function(...)
	return print('|cff33ff99MSBT - XP:|r', ...)
end

local printf = function(f, ...)
	return print(f:format(...))
end

msbt_xp = CreateFrame("Frame", nil, UIParent)
local DF = LibStub("LibDeformat-3.0")

function msbt_xp:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_LOGOUT");
	self:RegisterEvent("ADDON_LOADED");
end

function msbt_xp:ADDON_LOADED(event, addon)
	if(addon ~= 'msbt_xp') then return end
	
	if(msbtxpDB) then
		print("DB loading...")
		self.xp = msbtxpDB
	else
		self.xp = {}
		self.xp.max 	= UnitXPMax("player")
		self.xp.cur 	= UnitXP("player")
		self.xp.level 	= UnitLevel("player")
		self.xp.gain 	= 0
	end
	
	self.classcolor = RAID_CLASS_COLORS[string.upper(select(2, UnitClass("player")))];
	self.classcolor.r = self.classcolor.r * 255
	self.classcolor.g = self.classcolor.g * 255
	self.classcolor.b = self.classcolor.b * 255
end

function msbt_xp:PLAYER_LEVEL_UP(event, level, hp, mp, ...)
	self.xp.max 	= UnitXPMax("player")
	self.xp.cur 	= UnitXP("player")
	self.xp.level 	= level
	
	local text;
	text = string.format("Ding %d : %d/%d (%0.1f%%)", self.xp.level, self.xp.cur, self.xp.max, (self.xp.cur/self.xp.max)*100)
	self:PrintCombatMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, self.classcolor, 25, true);
	
	msbtxpDB = self.xp
end

function msbt_xp:CHAT_MSG_COMBAT_XP_GAIN(event, line)
	self.xp.max 	= UnitXPMax("player")
	self.xp.cur 	= UnitXP("player")
	local name, gain = DF.Deformat(line, "%s dies, you gain %d experience.")
	
	if(not gain) then return end
	
	self.xp.gain = gain
	
	local needed = self.xp.max - UnitXP("player")
	
	local text, xp;
	text = string.format("%d/%d (%0.1f%%) :: %d KTL", self.xp.cur, self.xp.max, (self.xp.cur/self.xp.max)*100, (needed/self.xp.gain))
	
	xp = string.format("+%d XP", self.xp.gain)
	
	self:PrintCombatMessage(text, MikSBT.DISPLAYTYPE_STATIC, self.classcolor, 25, true)
	self:PrintCombatMessage(xp, MikSBT.DISPLAYTYPE_NOTIFICATION, {r = 186, g = 85, b = 211}, 25, false)
	
	msbtxpDB = self.xp
end

function msbt_xp:PrintCombatMessage(text, filter, colors, size, sticky)
	MikSBT.DisplayMessage(text, filter, sticky, colors.r, colors.g, colors.b, size, 2)
end

function msbt_xp:PLAYER_LOGOUT(event)
	msbtxpDB = self.xp
end

SlashCmdList['MSBT_XP'] = function()
	local needed = msbt_xp.xp.max - msbt_xp.xp.cur
	
	local text;
	text = string.format("%d/%d (%0.1f%%) :: %d KTL", msbt_xp.xp.cur, msbt_xp.xp.max, (msbt_xp.xp.cur/msbt_xp.xp.max)*100, (needed/msbt_xp.xp.gain))
	
	msbt_xp:PrintCombatMessage(text, MikSBT.DISPLAYTYPE_STATIC, msbt_xp.classcolor, 25, true)
end

SLASH_MSBT_XP1 = '/xp'

-------------------------------------------------------------------------------
msbt_xp:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
-------------------------------------------------------------------------------
msbt_xp:OnEnable() --force ourselves to load