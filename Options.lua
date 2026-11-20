-- Stormbound's option pages; LibBound adds Extras (Well Rested, Well Fed, explanations, minimap)
-- and Skin, and builds the window.
local _, ns = ...
if ns.disabled then return end
local Bound = LibStub("LibBound-1.0")

local function TotemPage(UI)
	local p = UI.NewPage("Totems", "One button per element: the totem that stands and its time left.")
	local W = UI.CONTENT_W
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "totems", "Show the totem bar",
		"Left-click drops the last totem of that element again, right-click removes it.")) + 6)
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "totemTimers", "Time left on each button")) + 6)
	p:Add(UI.Note(p, p.y, "Unlock the frames (footer below) to move the bar or scale it with the mouse wheel."))
end

local function ShieldPage(UI)
	local p = UI.NewPage("Shield & imbue", "Lightning Shield and your weapon imbue. Click a card to cast (out of combat).")
	local W = UI.CONTENT_W
	p:Add(UI.Section(p, p.y - 4, "Lightning Shield") + 2)
	local third = math.floor(W / 3)
	UI.DBToggle(p, 0, p.y, third, "shield", "Show")
	UI.DBToggle(p, third, p.y, third, "shieldSound", "Sound")
	UI.DBToggle(p, third * 2, p.y, third, "shieldKeep", "When missing", nil, function() ns.UpdateBuffTimers() end)
	p:Add(32)
	p:Add(select(2, UI.Slider(p, p.y, "Warn with time left", "shieldMinutes", 1, 10, 1, " min")) + 8)
	p:Add(UI.Section(p, p.y - 4, "Weapon imbue") + 2)
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "imbue", "Show when your main hand has no imbue")) + 6)
	p:Add(select(2, UI.Cycle(p, p.y, "Imbue to cast", ns.IMBUE_CHOICES,
		function() return ns.db.imbueChoice end,
		function(v) ns.db.imbueChoice = v end,
		function()
			local s = ns.ImbueSpell()
			return s and ("Now: " .. s) or "No imbue learned yet (Rockbiter comes at level 1)."
		end)) + 8)
	p:Add(select(2, UI.Slider(p, p.y, "Warn with time left", "imbueMinutes", 1, 5, 1, " min")) + 8)
end

local function ReagentPage(UI)
	local p = UI.NewPage("Totems & Ankhs", "The items a shaman needs in the bags.")
	local W = UI.CONTENT_W
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "totemItems", "Warn when a totem item is missing",
		"Earth, Fire, Water and Air Totem: without one, that element's totems can't be dropped.")) + 8)
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "ankhs", "Warn when Ankhs run low",
		"Once you know Reincarnation (level 30).")) + 6)
	p:Add(select(2, UI.Slider(p, p.y, "Ankhs: warn at", "ankhLow", 0, 10, 1, " left")) + 8)
end

local function TravelPage(UI)
	local p = UI.NewPage("Travel", "Astral Recall and your Hearthstone beside the game menu (Escape).")
	p:Add(select(2, UI.DBToggle(p, 0, p.y, UI.CONTENT_W, "travel", "Show the travel panel when the game menu opens")) + 8)
end

ns.optionPages[#ns.optionPages + 1] = TotemPage
ns.optionPages[#ns.optionPages + 1] = ShieldPage
ns.optionPages[#ns.optionPages + 1] = ReagentPage
ns.optionPages[#ns.optionPages + 1] = TravelPage
Bound.InstallOptions(ns, { header = "Shaman helper", launcher = "Shaman helper: totems, shield, imbue, reagents." })
