--@moods: fresh drop secret expire
local T = dofile(wb.dir .. "/tests/_shaman.lua")
local m = wb.mood
T.shaman(m == "fresh" and {} or { 8071, 3599 })
if m == "secret" then wb.state.secretTotems = true end
wb.login()
wb.advance(2)
if m == "fresh" then
	wb.expect("no bar before any totem is learned", wb.shown("StormboundTotems"), false)
	return
end
wb.expect("the bar shows once totems are learned", wb.shown("StormboundTotems"), true)
local earth = wb.frame("StormboundTotem1") -- Earth is the first button
wb.expect("right-click removes", earth:GetAttribute("type2"), "destroytotem")
wb.expect("for the earth slot", earth:GetAttribute("totem-slot"), 2)
wb.expect("nothing to recast yet", earth:GetAttribute("spell1"), nil)
wb.dropTotem(2, "Stoneskin Totem", 120)
wb.advance(1)
wb.expect("remembered for left-click", earth:GetAttribute("spell1"), "Stoneskin Totem")
wb.expect("as a spell", earth:GetAttribute("type1"), "spell")
wb.expect("time left on the button", earth.timer:GetText(), "2m")
if m == "secret" then
	wb.combat(true)
	wb.dropTotem(1, "Searing Totem", 55)
	wb.advance(1)
	local fire = wb.frame("StormboundTotem2")
	wb.expect("hidden data in combat: no timer", fire.timer:GetText(), "")
	wb.expect("and the click spell waits for the fight to end", fire:GetAttribute("spell1"), nil)
	wb.state.secretTotems = false -- readable again once the fight ends (no new drop)
	wb.combat(false)
	wb.advance(1)
	wb.expect("learned once it can be read", fire:GetAttribute("spell1"), "Searing Totem")
	-- a fight starting while the bar is being dragged: no move in combat
	wb.slash("/storm unlock")
	local bar = wb.frame("StormboundTotems")
	wb.ns.BeginDrag(bar, "tbPoint")
	wb.combat(true)
	wb.advance(1)
	wb.combat(false)
	wb.slash("/storm lock")
end
if m == "expire" then
	wb.advance(115)
	wb.expect("last seconds", tonumber(earth.timer:GetText()) <= 10, true)
	wb.advance(10)
	wb.expect("gone: no timer", earth.timer:GetText(), "")
	wb.expect("faded", earth.icon.__desaturated or earth.icon:GetAlpha() < 1, true)
	wb.expect("still recasts it", earth:GetAttribute("spell1"), "Stoneskin Totem")
end
