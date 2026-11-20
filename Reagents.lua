-- Totem items and Ankhs: a card when an element's totem item is missing from the bags (without it
-- that element's totems can't be dropped; new shamans lose them), and one when Ankhs run low once
-- Reincarnation is known. Quiet in combat.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local ORDER = { "earth", "fire", "water", "air" }

local function Count(id)
	local ok, n = pcall(C_Item.GetItemCount, id)
	return (ok and not ns.IsSecret(n) and n) or 0
end

-- the elements whose totems are learned but whose item isn't in the bags
function ns.MissingTotemItems()
	local out = {}
	for _, k in ipairs(ORDER) do
		local e = D.elements[k]
		if ns.ElementKnown(k) and Count(e.item) == 0 then out[#out + 1] = e.itemName end
	end
	return out
end

local function Known(id)
	local ok, k = pcall(IsPlayerSpell, id)
	return ok and not ns.IsSecret(k) and k and true or false
end

local M = {}
ns.modules[#ns.modules + 1] = M
local items, ankh

function M:Update()
	if not items then return end
	if ns.unlocked then
		items:SetStatus("Air Totem"); items:Show(); items:Glow(false)
		ankh:SetStatus("1 left"); ankh:Show(); ankh:Glow(false)
		return
	end
	local quiet = ns.InCombat()
	local missing = ns.MissingTotemItems()
	if ns.db.totemItems and #missing > 0 and not quiet then
		items:SetTitle(#missing == 1 and (missing[1] .. " missing") or "Totem items missing")
		items:SetStatus(table.concat(missing, ", "), true)
		items:Show(); items:Glow(true)
	else
		items:Glow(false); items:Hide()
	end
	local n = Count(D.ankh)
	if ns.db.ankhs and Known(D.reincarnation) and n <= ns.db.ankhLow and not quiet then
		ankh:SetStatus(n == 0 and "None left: Reincarnation can't be used" or (n .. " left"), n == 0)
		ankh:Show(); ankh:Glow(true)
	else
		ankh:Glow(false); ankh:Hide()
	end
end

function M:Init()
	items = ns.MakeCard("StormboundTotemItemsFrame")
	items:SetIcon(136232)
	items:SetTitle("Totem items missing")
	items:SetExplain(ns.Help.totemItem)
	ns.MakeMovable(items, "tiPoint"); ns.ApplyPoint(items, "tiPoint")
	ankh = ns.MakeCard("StormboundAnkhFrame")
	ankh:SetIcon(136080)
	ankh:SetTitle("Ankhs")
	ankh:SetExplain(ns.Help.ankh)
	ns.MakeMovable(ankh, "akPoint"); ns.ApplyPoint(ankh, "akPoint")
	local f = CreateFrame("Frame")
	for _, e in ipairs({ "BAG_UPDATE_DELAYED", "SPELLS_CHANGED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
		"PLAYER_ENTERING_WORLD" }) do f:RegisterEvent(e) end
	f:SetScript("OnEvent", function() M:Update() end)
	M:Update()
end
