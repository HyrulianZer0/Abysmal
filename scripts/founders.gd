class_name Founders
extends RefCounted
## The five founders — breadcrumb NPCs met at depths 2/4/6/8/10 (v0.11.0).
##
## Meeting a founder roots their gift into the Life Tree AUTOMATICALLY
## (no purchase, no choice to skip): the soul remembers being fed, rested,
## stocked, armed, and inspired. Buffs survive death — they are flagged on
## the soul, not the body (see autoload/life_tree.gd).
##
## Depth mapping is the Oct 24, 2026 decision (morning-briefing): Marla 2,
## Harlan 4, Tovan 6, Sarella 8, Pello 10. This SUPERSEDES the Oct 8
## npc-story-beats paper, which had Tovan at depth 4 — the paper is flavor
## reference only; this file is the mapping the game uses.
##
## Buff magnitudes are PROVISIONAL TUNING (James's call, flagged): they
## mirror existing canon scales (a level-up is +10 max HP / +2 atk; a
## troll salve is +0.4 HP/s regen; a lucky coin is x1.05 gold) so no
## existing balance number moves — these are new bonus sources only.

## Founder catalog. Fields:
##   id         stable key (also the Life Tree leaf/node key prefix)
##   name       display name
##   role       what they do (farmer, miner, woodcutter, blacksmith, trader)
##   depth      the depth whose floor holds their meeting
##   buff_id    Life Tree node id rooted on meeting
##   buff_name  display name of the gift
##   buff_text  one-line effect description (UI / log)
##   color      silhouette placeholder color (primitives only, no art assets)
const FOUNDERS: Array = [
	{
		"id": "marla", "name": "Marla Bramble", "role": "farmer",
		"depth": 2, "buff_id": "well_fed", "buff_name": "Well Fed",
		"buff_text": "+max HP — a full belly outlasts a sharp blade.",
		"color": Color(0.55, 0.45, 0.25),
	},
	{
		"id": "harlan", "name": "Harlan Slate", "role": "miner",
		"depth": 4, "buff_id": "well_stocked", "buff_name": "Well Stocked",
		"buff_text": "+material yield — the deep provides for those who dig.",
		"color": Color(0.45, 0.45, 0.50),
	},
	{
		"id": "tovan", "name": "Tovan Ashe", "role": "woodcutter",
		"depth": 6, "buff_id": "well_rested", "buff_name": "Well Rested",
		"buff_text": "+HP regen — rest is a weapon, and the soul knows how.",
		"color": Color(0.30, 0.42, 0.28),
	},
	{
		"id": "sarella", "name": "Sarella Vex", "role": "blacksmith",
		"depth": 8, "buff_id": "well_armed", "buff_name": "Well Armed",
		"buff_text": "+attack — steel the soul remembers how to swing.",
		"color": Color(0.55, 0.30, 0.22),
	},
	{
		"id": "pello", "name": "Pello Quin", "role": "trader",
		"depth": 10, "buff_id": "inspired", "buff_name": "Inspired",
		"buff_text": "+luck — word of your delves spreads, and hope follows.",
		"color": Color(0.45, 0.35, 0.55),
	},
]

## Buff magnitudes (PROVISIONAL TUNING — see header). One entry per buff_id.
##   max_hp_flat    flat max HP added (Well Fed)
##   atk_flat       flat attack added (Well Armed)
##   regen_flat     HP/second added (Well Rested)
##   material_mult  material-yield multiplier (Well Stocked; no consumer
##                  yet — gathering zones arrive in a later push)
##   gold_mult      gold-gain multiplier (Inspired)
##   rarity_flat    flat rarity tier-up chance added (Inspired)
const BUFFS: Dictionary = {
	"well_fed": {"max_hp_flat": 10.0},
	"well_stocked": {"material_mult": 1.25},
	"well_rested": {"regen_flat": 0.5},
	"well_armed": {"atk_flat": 2.0},
	"inspired": {"gold_mult": 1.10, "rarity_flat": 0.01},
}


## Founder dict met at `depth`, or {} when no founder lives there.
static func founder_at_depth(depth: int) -> Dictionary:
	for f in FOUNDERS:
		if int(f["depth"]) == depth:
			return f
	return {}


## Founder dict by stable id, or {}.
static func founder_by_id(founder_id: String) -> Dictionary:
	for f in FOUNDERS:
		if str(f["id"]) == founder_id:
			return f
	return {}


## Buff def dict for a buff id, or {}.
static func buff_def(buff_id: String) -> Dictionary:
	return (BUFFS.get(buff_id, {}) as Dictionary).duplicate()


## All founder ids in depth order.
static func all_ids() -> Array:
	var out: Array = []
	for f in FOUNDERS:
		out.append(str(f["id"]))
	return out
