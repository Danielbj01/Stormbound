-- The totem bar: one slot per element (Earth, Fire, Water, Air) with the totem that stands and its
-- time left, faded when none. Left-click drops the last totem of that element again, right-click
-- removes it (secure "destroytotem"). The buttons are secure: their spell is set out of combat
-- only (they keep the last one through a fight), and the bar shows or hides out of combat only.
-- When Forever hides totem data in combat, a slot shows its icon without a timer.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local ELEMENTS = {
	{ key = "earth", label = "Earth", slot = function() return EARTH_TOTEM_SLOT or 2 end, color = { 0.62, 0.46, 0.26 },
		icon = "Interface\\Icons\\Spell_Nature_StoneSkinTotem" },
	{ key = "fire", label = "Fire", slot = function() return FIRE_TOTEM_SLOT or 1 end, color = { 1, 0.45, 0.15 },
		icon = "Interface\\Icons\\Spell_Fire_SearingTotem" },
	{ key = "water", label = "Water", slot = function() return WATER_TOTEM_SLOT or 3 end, color = { 0.25, 0.60, 1 },
		icon = "Interface\\Icons\\INV_Spear_04" },
	{ key = "air", label = "Air", slot = function() return AIR_TOTEM_SLOT or 4 end, color = { 0.78, 0.86, 1 },
		icon = "Interface\\Icons\\Spell_Nature_InvisibilityTotem" },
}
ns.TOTEM_ELEMENTS = ELEMENTS
local SIZE, GAP = 36, 6

-- is any totem of this element learned
function ns.ElementKnown(key)
	for _, id in ipairs(D.elements[key].spells) do
		local ok, k = pcall(IsPlayerSpell, id)
		if ok and not ns.IsSecret(k) and k then return true end
	end
	return false
end

-- what stands in a slot: name, icon, time left; secret = the client hides it right now
function ns.TotemIn(slot)
	local ok, have, name, start, duration, icon = pcall(GetTotemInfo, slot)
	if not ok then return nil end
	if ns.IsSecret(have) or ns.IsSecret(name) or ns.IsSecret(start) or ns.IsSecret(duration) then
		return { secret = true, icon = not ns.IsSecret(icon) and icon or nil }
	end
	if not have or not name or name == "" then return nil end
	return { name = name, icon = icon, left = math.max(0, (start or 0) + (duration or 0) - GetTime()) }
end

local M = {}
ns.modules[#ns.modules + 1] = M
local bar, buttons = nil, {}

local function Tooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	local e = self.element
	local t = ns.TotemIn(e.slot())
	GameTooltip:SetText(t and t.name or (e.label .. " totem"))
	if ns.db.explain then
		GameTooltip:AddLine(ns.Help.totems, 1, 1, 1, true)
		GameTooltip:AddLine(ns.Help.totemButton, 0.6, 0.75, 1, true)
	end
	local last = ns.db.lastTotem[e.key]
	GameTooltip:AddLine(last and ("Left-click: " .. last) or "Drop a totem once: this button remembers it.", 0.8, 0.8, 0.8, true)
	GameTooltip:Show()
end

local function Button(i, e)
	local b = CreateFrame("Button", "StormboundTotem" .. i, bar, "SecureActionButtonTemplate")
	b:SetSize(SIZE, SIZE)
	b:SetPoint("LEFT", bar, "LEFT", 6 + (i - 1) * (SIZE + GAP), 0)
	b:RegisterForClicks("AnyDown", "AnyUp")
	b.element = e
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetAllPoints()
	b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	b.edge = b:CreateTexture(nil, "BACKGROUND")
	b.edge:SetPoint("TOPLEFT", -1, 1); b.edge:SetPoint("BOTTOMRIGHT", 1, -1)
	b.edge:SetColorTexture(e.color[1], e.color[2], e.color[3], 0.9)
	b.band = b:CreateTexture(nil, "OVERLAY")
	b.band:SetPoint("BOTTOMLEFT"); b.band:SetPoint("BOTTOMRIGHT"); b.band:SetHeight(3)
	b.band:SetColorTexture(e.color[1], e.color[2], e.color[3], 1)
	b.timer = b:CreateFontString(nil, "OVERLAY")
	ns.UI.SetFont(b.timer, "narrow", 13, "OUTLINE")
	b.timer:SetPoint("CENTER", 0, 0)
	b.timer:SetTextColor(1, 1, 1)
	ns.UI.Highlight(b)
	b:SetAttribute("type2", "destroytotem")
	b:SetAttribute("totem-slot", e.slot())
	b:SetScript("OnEnter", Tooltip)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return b
end

-- the secure parts: each button's spell, the bar's visibility
local function SyncSecure()
	if InCombatLockdown() then return end -- caught up on PLAYER_REGEN_ENABLED
	local any = false
	for _, b in ipairs(buttons) do
		local e = b.element
		if ns.ElementKnown(e.key) then any = true end
		local last = ns.db.lastTotem[e.key]
		b:SetAttribute("type1", last and "spell" or nil)
		b:SetAttribute("spell1", last)
	end
	bar:SetShown(ns.db.totems and (any or ns.unlocked))
end

-- the looks: icon, timer, faded (safe in combat)
local function Paint()
	for _, b in ipairs(buttons) do
		local e = b.element
		local t = ns.TotemIn(e.slot())
		if t and t.secret then
			b.icon:SetTexture(t.icon or e.icon); b.icon:SetDesaturated(false); b.icon:SetAlpha(1)
			b.timer:SetText("")
		elseif t then
			b.icon:SetTexture(t.icon or e.icon); b.icon:SetDesaturated(false); b.icon:SetAlpha(1)
			local left = t.left
			b.timer:SetText(ns.db.totemTimers and (left >= 60 and ("%dm"):format(math.ceil(left / 60)) or ("%d"):format(left)) or "")
			b.timer:SetTextColor(1, left <= 10 and 0.55 or 1, left <= 10 and 0.4 or 1)
		else
			b.icon:SetTexture(b.lastIcon or e.icon); b.icon:SetDesaturated(true); b.icon:SetAlpha(0.55)
			b.timer:SetText("")
		end
	end
end
ns.PaintTotems = Paint

-- a totem went down: remember it as that element's click spell
local function Learn(slot)
	for _, b in ipairs(buttons) do
		if b.element.slot() == slot then
			local t = ns.TotemIn(slot)
			if t and t.name then
				ns.db.lastTotem[b.element.key] = t.name
				b.lastIcon = t.icon
			end
		end
	end
end

function M:Update()
	if not bar then return end
	SyncSecure()
	Paint()
end

function M:Init()
	bar = CreateFrame("Frame", "StormboundTotems", UIParent, "BackdropTemplate")
	bar:SetSize(12 + #ELEMENTS * SIZE + (#ELEMENTS - 1) * GAP, SIZE + 12)
	bar:SetFrameStrata("LOW")
	ns.UI.Box(bar, 0.85)
	ns.MakeMovable(bar, "tbPoint")
	ns.ApplyPoint(bar, "tbPoint")
	for i, e in ipairs(ELEMENTS) do buttons[i] = Button(i, e) end
	local f = CreateFrame("Frame")
	for _, ev in ipairs({ "PLAYER_TOTEM_UPDATE", "PLAYER_REGEN_ENABLED", "SPELLS_CHANGED", "PLAYER_ENTERING_WORLD" }) do
		f:RegisterEvent(ev)
	end
	f:SetScript("OnEvent", function(_, event, slot)
		if event == "PLAYER_TOTEM_UPDATE" then
			Learn(slot)
			SyncSecure()
			Paint()
			return
		end
		if event == "PLAYER_REGEN_ENABLED" then
			-- totems dropped while their data was hidden: learn them now that they can be read
			for _, e in ipairs(ELEMENTS) do Learn(e.slot()) end
		end
		M:Update()
	end)
	C_Timer.NewTicker(0.5, Paint)
	M:Update()
end
