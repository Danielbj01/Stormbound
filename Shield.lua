-- Lightning Shield card (LibBound buff timer): missing or running out, click to cast.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local function Name(list) local id = ns.BestRank(list) return id and ns.SpellName(id) end

ns.MakeBuffTimer({
	key = "shield", point = "lsPoint", frameName = "StormboundShieldFrame",
	label = "Lightning Shield", icon = 136051,
	names = function() return { ns.SpellName(D.lightningShield[1]) or "Lightning Shield" } end,
	active = function() return ns.BestRank(D.lightningShield) ~= nil end,
	cast = function() return Name(D.lightningShield) end,
	explain = ns.Help.shield,
	goneText = "Missing: click to cast",
})
