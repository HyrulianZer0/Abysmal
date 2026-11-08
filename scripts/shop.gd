class_name Shop
extends RefCounted
## Death-shop catalog (Brotato-style): 4 random offerings per death, two tabs
## (Items / Skills), re-roll for gold. Everything bought here is permanent —
## it takes effect on the next delve, so death always leaves you stronger.
##
## Items are stackable charms with flat bonuses and escalating prices.
## Skills are the 14 canon skills: buy the unlock, then upgrade per level.

const OFFER_COUNT := 4

const ITEMS := [
	{"id": "blood_vial", "name": "Blood Vial", "desc": "+15 max HP (permanent)",
		"base_price": 40.0, "price_growth": 1.2},
	{"id": "whetstone", "name": "Whetstone", "desc": "+3 attack (permanent)",
		"base_price": 40.0, "price_growth": 1.2},
	{"id": "iron_plate", "name": "Iron Plate", "desc": "+2 defense (permanent)",
		"base_price": 40.0, "price_growth": 1.2},
	{"id": "lucky_coin", "name": "Lucky Coin", "desc": "+5% gold from kills (permanent)",
		"base_price": 60.0, "price_growth": 1.2},
	{"id": "quill", "name": "Scholar's Quill", "desc": "+4% XP gain (permanent)",
		"base_price": 60.0, "price_growth": 1.2},
	{"id": "flask", "name": "Alchemist Flask", "desc": "+5% potion healing (permanent)",
		"base_price": 50.0, "price_growth": 1.2},
	{"id": "troll_salve", "name": "Troll Salve", "desc": "+0.4 HP/s regen (permanent)",
		"base_price": 70.0, "price_growth": 1.2},
	{"id": "hunter_mark", "name": "Hunter's Mark", "desc": "+2.5% damage dealt (permanent)",
		"base_price": 70.0, "price_growth": 1.2},
]

## Canon skill roster (designed with James, 2026-09-26). `effect` is the
## per-level description; `available=false` means the system it hooks into
## doesn't exist yet — shown in the shop as "coming soon", not purchasable.
const SKILLS := [
	{"id": "attack", "name": "Attack", "cat": "Combat",
		"effect": "+0.5% damage per level", "base_price": 50.0, "available": true},
	{"id": "strength", "name": "Strength", "cat": "Combat",
		"effect": "+0.5% melee damage per level", "base_price": 50.0, "available": true},
	{"id": "defense", "name": "Defense", "cat": "Combat",
		"effect": "+0.5% damage reduction per level", "base_price": 50.0, "available": true},
	{"id": "vitality", "name": "Vitality", "cat": "Combat",
		"effect": "+0.5% max HP per level", "base_price": 60.0, "available": true},
	{"id": "agility", "name": "Agility", "cat": "Combat",
		"effect": "+0.5% dodge chance per level (cap 60%)", "base_price": 60.0, "available": true},
	{"id": "dungeoneering", "name": "Dungeoneering", "cat": "Delving",
		"effect": "+0.5% idle delve speed per level", "base_price": 60.0, "available": true},
	{"id": "lockpicking", "name": "Lockpicking", "cat": "Delving",
		"effect": "Pick locks: +1 tumbler click per bump per level; level ≥ lock tier opens instantly",
		"base_price": 60.0, "available": true},
	{"id": "stealth", "name": "Stealth", "cat": "Delving",
		"effect": "-0.5% monster detection radius per level", "base_price": 60.0, "available": true},
	{"id": "perception", "name": "Perception", "cat": "Delving",
		"effect": "+0.5% sight/minimap radius per level", "base_price": 60.0, "available": true},
	{"id": "luck", "name": "Luck", "cat": "Delving",
		"effect": "+2% gold, +1% rarity luck per level; extra shop offerings",
		"base_price": 80.0, "available": true},
	{"id": "smithing", "name": "Smithing", "cat": "Crafting",
		"effect": "Reforge gear base power", "base_price": 80.0, "available": false},
	{"id": "alchemy", "name": "Alchemy", "cat": "Crafting",
		"effect": "Brew/upgrade potions", "base_price": 80.0, "available": false},
	{"id": "enchanting", "name": "Enchanting", "cat": "Crafting",
		"effect": "+0.5% rarity up-shift per level", "base_price": 80.0, "available": true},
	{"id": "regeneration", "name": "Regeneration", "cat": "Survival",
		"effect": "+0.1 HP/s regen per level", "base_price": 60.0, "available": true},
]

const REROLL_BASE := 25.0


static func item_by_id(item_id: String) -> Dictionary:
	for it in ITEMS:
		if str(it["id"]) == item_id:
			return it
	return {}


static func skill_by_id(skill_id: String) -> Dictionary:
	for s in SKILLS:
		if str(s["id"]) == skill_id:
			return s
	return {}


## Price of the next copy of a charm: base × growth^owned.
static func item_price(item_id: String, owned: int) -> float:
	var it := item_by_id(item_id)
	if it.is_empty():
		return 0.0
	return float(it["base_price"]) * pow(float(it["price_growth"]), float(owned))


## Price of the next skill level: base × 1.10^level (level 0 = unlock price).
static func skill_price(skill_id: String, level: int) -> float:
	var s := skill_by_id(skill_id)
	if s.is_empty():
		return 0.0
	return float(s["base_price"]) * pow(1.10, float(level))


## Roll the item offerings for one shop visit: 4 distinct charms, +1 per
## 20 Luck levels (cap 6). Luck is the loot engine — it feeds this shop too.
static func roll_offerings(rng: RandomNumberGenerator, luck_level: int) -> Array:
	var count := mini(OFFER_COUNT + luck_level / 20, 6)
	var pool := ITEMS.duplicate()
	var out: Array = []
	while out.size() < count and not pool.is_empty():
		var i := rng.randi_range(0, pool.size() - 1)
		out.append(pool[i])
		pool.remove_at(i)
	return out


static func reroll_price(rerolls: int) -> float:
	return REROLL_BASE * pow(1.5, float(rerolls))


## Field dressing (depth-shop triage): restores FIELD_HEAL_FRAC of max HP —
## a patch-up, deliberately not a full heal. Price scales with depth so it
## stays a real decision all run long (a depth-1 patch-up is pocket change;
## a depth-20 one stings).
const FIELD_HEAL_FRAC := 0.50


static func field_heal_price(depth: int) -> float:
	return 25.0 * pow(float(maxi(depth, 1)), 1.2)
