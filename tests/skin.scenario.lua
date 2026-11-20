--@moods: storm blizzard flat
local T = dofile(wb.dir .. "/tests/_shaman.lua")
T.shaman({ 324, 8071 })
wb.login({ saved = { StormboundDB = { skin = wb.mood } } })
wb.advance(7)
local want = ({ storm = "Storm", blizzard = "Blizzard", flat = "Flat" })[wb.mood]
wb.expect("active skin", wb.ns.UI.Active().name, want)
wb.check(wb.shown("StormboundShieldFrame"), "a card builds in this skin")
wb.check(wb.shown("StormboundTotems"), "the totem bar too")
wb.slash("/storm")
wb.check(wb.shown("StormboundOptions"), "the options build in this skin")
