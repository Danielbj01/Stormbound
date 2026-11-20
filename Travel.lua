-- The travel panel (LibBound) beside the game menu: Astral Recall and the Hearthstone.
local _, ns = ...
if ns.disabled then return end
local Bound = LibStub("LibBound-1.0")

local function Known(id)
	local ok, k = pcall(IsPlayerSpell, id)
	return ok and not ns.IsSecret(k) and k and true or false
end

function ns.TravelRows()
	local id = ns.DATA.astralRecall
	return { { spell = id, label = "Astral Recall", column = 1, known = Known(id), level = 30,
		tip = "Astral Recall", help = ns.Help.recall, learn = "from a shaman trainer" } }
end

Bound.InstallTravel(ns, {
	columns = { "SHAMAN" },
	rows = ns.TravelRows,
	hearthHelp = ns.Help.hearthstone,
})
