local _, c = UnitClass("player")
if c ~= "WARLOCK" then return end

local selearn = AceLibrary("SpecialEvents-LearnSpell-2.0")
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local BS = AceLibrary("Babble-Spell-2.2")

local core = FuBar_CorkFu
local defaultspell = BS["Summon Imp"]
local icons, spells = {}, {
	[BS["Summon Imp"]]       = "Interface\\Icons\\Spell_Shadow_SummonImp",
	[BS["Summon Voidwalker"]]    = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker",
	[BS["Summon Succubus"]]    = "Interface\\Icons\\Spell_Shadow_SummonSuccubus",
	[BS["Summon Felhunter"]]     = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
	[BS["Summon Felguard"]]  = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
}
for i,v in pairs(spells) do icons[v] = i end


local lockpets = core:NewModule("Warlock Pets")
lockpets.target = "Custom"


function lockpets:OnEnable()
	for i in pairs(spells) do if selearn:SpellKnown(i) then defaultspell = i end end

	self:RegisterEvent("CorkFu_Rescan")
	self:RegisterEvent("PLAYER_PET_CHANGED")
	self:PLAYER_PET_CHANGED()
end


----------------------------
--      Cork Methods      --
----------------------------

function lockpets:ItemValid()
	for i in pairs(spells) do
		if selearn:SpellKnown(i) then return true end
	end
end


function lockpets:UnitValid(unit)
	return unit == "player"
end


function lockpets:GetIcon()
	local filter = self.db.char["Filter Everyone"]
	return filter and spells[filter] or defaultspell and spells[defaultspell]
end


function lockpets:GetTopItem()
	if not self:ItemValid() or UnitExists("pet") or self.db.char["Filter Everyone"] == -1 then return end

	local spell = self.db.char["Filter Everyone"] or defaultspell
	return spells[spell], spell
end


function lockpets:PutACorkInIt()
	local _, spell = self:GetTopItem()
	if not spell then return end
	core.secureframe:SetManyAttributes("type1", "spell", "spell", spell)
	return true
end


function lockpets:OnTooltipUpdate()
	if not self:ItemValid() or UnitExists("pet") or self.db.char["Filter Everyone"] == -1 then return end

	local spell = self.db.char["Filter Everyone"] or defaultspell
	local cat = tablet:AddCategory("hideBlankLine", true)
	cat:AddLine("text", spell, "hasCheck", true, "checked", true, "checkIcon", spells[spell],
		"func", self.PutACorkInIt, "arg1", self)
end


function lockpets:OnMenuRequest()
	local val = self.db.char["Filter Everyone"] or defaultspell

	dewdrop:AddLine("text", core.loc.disabled, "func", self.SetFilter, "isRadio", true, "checked", val == -1, "arg1", self,
		"arg2", "Everyone", "arg3", -1, "arg4", "char")
	for v in pairs(spells) do
		if selearn:SpellKnown(v) then
			dewdrop:AddLine("text", v, "func", self.SetFilter, "isRadio", true, "checked", val == v,
				"arg1", self, "arg2", "Everyone", "arg3", v, "arg4", "char")
		end
	end
end


------------------------------
--      Event Handlers      --
------------------------------


function lockpets:CorkFu_Rescan(spell)
	if spells[spell] or spell == "All" then self:PLAYER_PET_CHANGED() end
end


function lockpets:PLAYER_PET_CHANGED()
	if UnitExists("pet") then return end
	
	self:TriggerEvent("CorkFu_Update")
end

