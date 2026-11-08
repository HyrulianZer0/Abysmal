class_name Items
extends RefCounted
## Loot item generation + comparison (pure functions — easy to unit test).
##
## Item shape: {"name": String, "slot": "weapon"|"armor", "rarity": String,
##              "atk": float, "def": float, "max_hp": float, "level": int}

const WEAPON_TIERS: Array = [
	{"name": "Rusty Dagger", "atk": 2.0, "def": 0.0, "max_hp": 0.0, "rarity": "Common"},
	{"name": "Iron Sword", "atk": 4.0, "def": 0.0, "max_hp": 0.0, "rarity": "Fine"},
	{"name": "Steel Sword", "atk": 7.0, "def": 1.0, "max_hp": 0.0, "rarity": "Rare"},
	{"name": "Starforged Blade", "atk": 12.0, "def": 2.0, "max_hp": 10.0, "rarity": "Epic"},
]

const ARMOR_TIERS: Array = [
	{"name": "Cloth Rags", "atk": 0.0, "def": 1.0, "max_hp": 0.0, "rarity": "Common"},
	{"name": "Leather Armor", "atk": 0.0, "def": 3.0, "max_hp": 5.0, "rarity": "Fine"},
	{"name": "Iron Plate", "atk": 0.0, "def": 6.0, "max_hp": 12.0, "rarity": "Rare"},
	{"name": "Starforged Mail", "atk": 0.0, "def": 10.0, "max_hp": 25.0, "rarity": "Epic"},
]


## Depth-scaled tier: deeper floors drop better gear, with a little jitter.
## Test-build generosity: a small "lucky find" bump means every floor can
## drop any of the 4 material tiers. Luck + Enchanting skills raise the bump.
static func _tier_for_depth(depth: int, rng: RandomNumberGenerator, bonus_luck: float = 0.0) -> int:
	var base := clampi(depth / 3, 0, 3)
	var t := clampi(base + rng.randi_range(-1, 1), 0, 3)
	if t < 3 and rng.randf() < 0.12 + bonus_luck:
		t += 1  # lucky find — one tier better
	return t


static func make_weapon(depth: int, rng: RandomNumberGenerator, bonus_luck: float = 0.0) -> Dictionary:
	var t: Dictionary = WEAPON_TIERS[_tier_for_depth(depth, rng, bonus_luck)]
	return {
		"name": str(t["name"]),
		"slot": "weapon",
		"rarity": str(t["rarity"]),
		"atk": float(t["atk"]) * (1.0 + 0.12 * float(depth - 1)),
		"def": float(t["def"]),
		"max_hp": float(t["max_hp"]),
		"level": depth,
	}


static func make_armor(depth: int, rng: RandomNumberGenerator, bonus_luck: float = 0.0) -> Dictionary:
	var t: Dictionary = ARMOR_TIERS[_tier_for_depth(depth, rng, bonus_luck)]
	return {
		"name": str(t["name"]),
		"slot": "armor",
		"rarity": str(t["rarity"]),
		"atk": float(t["atk"]),
		"def": float(t["def"]) * (1.0 + 0.12 * float(depth - 1)),
		"max_hp": float(t["max_hp"]),
		"level": depth,
	}


## Single-number quality score for "is this better?" comparisons.
static func gear_score(item: Dictionary) -> float:
	if item.is_empty():
		return 0.0
	return float(item.get("atk", 0.0)) + float(item.get("def", 0.0)) \
		+ float(item.get("max_hp", 0.0)) * 0.2


## True if new_item beats whatever is currently equipped (empty = always).
static func better(new_item: Dictionary, current: Dictionary) -> bool:
	return gear_score(new_item) > gear_score(current)


## Idle-game convenience: unwanted gear auto-sells for gold.
static func sell_value(item: Dictionary) -> float:
	if item.is_empty():
		return 0.0
	return maxf(1.0, gear_score(item) * 2.0 * float(item.get("level", 1)))


# ---------------------------------------------------------------------------
# CANON RARITY LADDER (design-notes/gemini-design-session-2026-08.md)
# Data only — the drop system still uses the 4 material tiers above.
# Do NOT rewire drops to this ladder until a later build.
# Shape: Array of {"name": String, "color": Color}, weakest -> strongest.
# NOTE: the notes call this "40 rungs" but list 39 names; this table
# implements exactly the 39 listed names in order.
# ---------------------------------------------------------------------------
const RARITY_LADDER: Array = [
	# Mundane tiers
	{"name": "Common", "color": Color("9aa0a6")},
	{"name": "Uncommon", "color": Color("4caf50")},
	{"name": "Rare", "color": Color("4488ff")},
	{"name": "Epic", "color": Color("b044ff")},
	{"name": "Legendary", "color": Color("ff9915")},
	{"name": "Mythic", "color": Color("ff4433")},
	{"name": "Exotic", "color": Color("ffd84d")},
	# Letter tiers (plus chains; story-ordered Omega -> EX)
	{"name": "F", "color": Color("8c7b5c")},
	{"name": "F+", "color": Color("a08d6a")},
	{"name": "E", "color": Color("9c8f6b")},
	{"name": "E+", "color": Color("b0a179")},
	{"name": "D", "color": Color("aba184")},
	{"name": "D+", "color": Color("bcb294")},
	{"name": "C", "color": Color("b5b5a8")},
	{"name": "C+", "color": Color("c6c6ba")},
	{"name": "B", "color": Color("b9c6cc")},
	{"name": "B+", "color": Color("cbd8de")},
	{"name": "A", "color": Color("aed6e8")},
	{"name": "A+", "color": Color("c2e2f2")},
	{"name": "S", "color": Color("9fe8f5")},
	{"name": "S+", "color": Color("b5f0fa")},
	{"name": "SS", "color": Color("a5f5e8")},
	{"name": "SS+", "color": Color("bcf7ee")},
	{"name": "SSS", "color": Color("b8ffd8")},
	{"name": "SSS+", "color": Color("d0ffe4")},
	{"name": "Ω", "color": Color("e8fff0")},   # the end of measurement
	{"name": "Ω+", "color": Color("f5fffa")},
	{"name": "X", "color": Color("d8b8ff")},   # unclassifiable
	{"name": "X+", "color": Color("e6ccff")},
	{"name": "Z", "color": Color("b890ff")},   # past the end
	{"name": "Z+", "color": Color("c9a8ff")},
	{"name": "ZZ", "color": Color("a878ff")},  # way past the end
	{"name": "EX", "color": Color("ffffff")},  # outside the system entirely
	# Cosmic / abstract tiers
	{"name": "Cosmic", "color": Color("5a3fae")},
	{"name": "Astral", "color": Color("7a9fff")},
	{"name": "Void", "color": Color("3a245e")},
	{"name": "Eldritch", "color": Color("4fff8a")},
	{"name": "Transcendent", "color": Color("ffe89e")},
	{"name": "Infinite", "color": Color("ff9eff")},
]


## Index of a rarity on the ladder (0 = weakest). -1 if unknown.
static func rarity_index(rarity_name: String) -> int:
	for i in RARITY_LADDER.size():
		if str(RARITY_LADDER[i]["name"]) == rarity_name:
			return i
	return -1


## Display color for a rarity; neutral gray for anything unlisted
## (e.g. the current material-tier drops predate this ladder).
static func rarity_color(rarity_name: String) -> Color:
	var i := rarity_index(rarity_name)
	if i < 0:
		return Color(0.75, 0.75, 0.78)
	return RARITY_LADDER[i]["color"]
