
local myname, Cork = ...
Cork.IHASCAT = select(4, GetBuildInfo()) >= 40000
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local IconLine = Cork.IconLine("Interface\\Icons\\Ability_Marksmanship", "Unspent talent points")
local defaults = Cork.defaultspc
defaults["Talents-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Talents", {type = "cork", tiptext = "Warn when you have unspent talent points."})

local function talentlesshack()
	if Cork.IHASCAT then return GetUnspentTalentPoints() > 0
	else return UnitCharacterPoints("player") > 0 end
end
local function Test() return Cork.dbpc["Talents-enabled"] and talentlesshack() and IconLine end

function dataobj:Scan() dataobj.player = Test() end

ae.RegisterEvent("Cork Talents", "CHARACTER_POINTS_CHANGED", dataobj.Scan)
