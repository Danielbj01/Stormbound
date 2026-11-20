--@moods: fresh hasitems missing ankhlow noreincarnation
local T = dofile(wb.dir .. "/tests/_shaman.lua")
local m = wb.mood
T.shaman(m == "fresh" and {} or { 8071, 3599, 20608 })
if m == "noreincarnation" then wb.state.spells[20608] = nil end
local bags = wb.state.bags
if m ~= "missing" then bags[5175], bags[5176] = 1, 1 end
if m == "missing" then bags[5175] = 1 end -- the fire totem item is lost
if m == "ankhlow" or m == "noreincarnation" then bags[17030] = 1 else bags[17030] = 10 end
wb.login()
wb.advance(3)
local items, ankh = wb.shown("StormboundTotemItemsFrame"), wb.shown("StormboundAnkhFrame")
if m == "missing" then
	wb.expect("missing totem item card", items, true)
	wb.expect("names it", wb.frame("StormboundTotemItemsFrame").titleText:GetText(), "Fire Totem missing")
	bags[5176] = 1
	wb.fire("BAG_UPDATE_DELAYED")
	wb.expect("gone when it is back", wb.shown("StormboundTotemItemsFrame"), false)
else
	wb.expect("no item card", items, false)
end
wb.expect("ankh card", ankh, m == "ankhlow")
