-- Every plain-word explanation in one place (tooltips show them while "Explain things" is on).
local _, ns = ...
if ns.disabled then return end

ns.Help = {
	shield = "Lightning Shield surrounds you with charged orbs: whatever hits you gets zapped. Keep it on while you fight.",
	imbue = "A weapon imbue charges your weapon with an element for a while: Rockbiter for threat, Flametongue for fire damage, Frostbrand to slow, Windfury for extra swings.",
	totems = "Totems are the shaman's tools: each one helps you and your group while it stands. One of each element (earth, fire, water, air) can be down at a time.",
	totemButton = "Left-click: drop the last totem of this element again. Right-click: remove it.",
	totemItem = "You need the element's totem item in your bags to drop its totems. Lost it? Ask a shaman trainer how to get a new one.",
	ankh = "Reincarnation brings you back to life where you died. It uses one Ankh, sold by reagent vendors.",
	recall = "Astral Recall takes you to your Hearthstone's inn, like the Hearthstone itself, with its own cooldown.",
	hearthstone = "Your Hearthstone takes you back to the inn you set it to. Talk to an innkeeper to change it.",
}
