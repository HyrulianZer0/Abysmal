class_name GuildHall
extends RefCounted
## Guild-hall unlock chain (Phase 2, James's design): an old run-down tavern
## bought with the sales of loot from the abyss -> guild -> expanded guild ->
## adventurer's guild headquarters. Each stage comes with visible upgrades —
## the stages and transitions are real now (see guild_hall_view.gd); the art
## is placeholder primitives until real models land.
##
## This is a SEPARATE meta track from the death shop (not another tab):
## the death shop is per-death decision-making (random offerings, re-rolls),
## while the guild hall is a linear 4-stage progression of big one-time
## purchases bought with gold between/after runs. Stages persist across
## runs AND deaths — guild progress is meta progression, never wiped.
##
## Data model: 1-based stage index. GameState.guild_stage holds the highest
## stage owned (0 = nothing bought yet). Costs and depth requirements are
## provisional tuning numbers — flagged for James (see can_purchase/format).

const STAGE_COUNT := 4

## Stage catalog. Fields:
##   id         stable key
##   name       display name
##   blurb      one-line description (UI / log)
##   price      gold cost (meta economy)
##   depth_req  lifetime max-depth required to buy (0 = none)
##   label      the Label3D the stub view shows — stages must read as distinct
##   walls/roof colors, footprint (X,Z meters), height — strictly increasing
##              footprint per stage so stages are visually distinguishable
##   props      stub-view vocabulary (see guild_hall_view.gd)
const STAGES: Array = [
	{
		"id": "tavern", "name": "Run-Down Tavern",
		"blurb": "An old, sagging tavern bought with loot sales from the abyss. A roof over the guild's head — barely.",
		"price": 1500.0, "depth_req": 0,
		"label": "RUN-DOWN TAVERN",
		"walls": Color(0.42, 0.32, 0.22), "roof": Color(0.30, 0.24, 0.18),
		"footprint": Vector2(6.0, 5.0), "height": 3.0,
		"props": ["tilted_chimney", "rubble", "dim_window", "repair_sign"],
	},
	{
		"id": "guild", "name": "Guild Hall",
		"blurb": "The tavern rebuilt as a proper guild hall: stone walls, warm windows, a sign over the door.",
		"price": 10000.0, "depth_req": 10,
		"label": "GUILD HALL",
		"walls": Color(0.55, 0.55, 0.60), "roof": Color(0.45, 0.20, 0.14),
		"footprint": Vector2(8.0, 6.0), "height": 4.5,
		"props": ["sign_post", "banner", "warm_windows", "lanterns"],
	},
	{
		"id": "expanded_guild", "name": "Expanded Guild",
		"blurb": "A second floor, side wings, and a fenced yard. The guild is outgrowing its own walls.",
		"price": 50000.0, "depth_req": 20,
		"label": "EXPANDED GUILD",
		"walls": Color(0.72, 0.64, 0.50), "roof": Color(0.35, 0.42, 0.55),
		"footprint": Vector2(11.0, 7.0), "height": 5.5,
		"props": ["sign_post", "banner", "warm_windows", "lanterns",
			"second_floor", "wings", "fence", "flag"],
	},
	{
		"id": "hq", "name": "Adventurers' Guild HQ",
		"blurb": "The headquarters: twin towers, golden trim, braziers that never go out. The abyss pays for legends now.",
		"price": 200000.0, "depth_req": 35,
		"label": "ADVENTURERS' GUILD HQ",
		"walls": Color(0.85, 0.83, 0.78), "roof": Color(0.55, 0.30, 0.60),
		"footprint": Vector2(14.0, 9.0), "height": 7.0,
		"props": ["sign_post", "banner", "warm_windows", "lanterns",
			"second_floor", "wings", "fence", "flag",
			"towers", "gold_trim", "grand_doors", "braziers"],
	},
]


## 1-based stage dict, or {} for an invalid index.
static func stage(index: int) -> Dictionary:
	if index < 1 or index > STAGE_COUNT:
		return {}
	return STAGES[index - 1]


static func stage_by_id(stage_id: String) -> Dictionary:
	for s in STAGES:
		if str(s["id"]) == stage_id:
			return s
	return {}


static func stage_index(stage_id: String) -> int:
	for i in STAGE_COUNT:
		if str(STAGES[i]["id"]) == stage_id:
			return i + 1
	return 0


static func stage_price(index: int) -> float:
	var s := stage(index)
	return float(s.get("price", 0.0))


static func stage_depth_req(index: int) -> int:
	var s := stage(index)
	return int(s.get("depth_req", 0))


## Human-readable buy requirement line for UI / logs.
static func format_cost(index: int) -> String:
	var s := stage(index)
	if s.is_empty():
		return ""
	var txt := "%s gold" % BigNumbers.format(stage_price(index))
	var req := stage_depth_req(index)
	if req > 0:
		txt += " + reach depth %d" % req
	return txt


## Can stage `index` be bought with `gold` at lifetime max-depth
## `max_depth`? Stages are strictly sequential: you may only ever buy
## stage (owned + 1). Returns {"ok": bool, "reason": String}.
static func can_purchase(index: int, gold: float, max_depth: int,
		owned: int) -> Dictionary:
	if index < 1 or index > STAGE_COUNT:
		return {"ok": false, "reason": "The guild hall is complete — there is no stage %d." % index}
	if index != owned + 1:
		if index <= owned:
			return {"ok": false, "reason": "Already owned."}
		return {"ok": false,
			"reason": "Buy stage %d first." % (owned + 1)}
	var price := stage_price(index)
	if gold < price:
		return {"ok": false,
			"reason": "Need %s more gold." % BigNumbers.format(price - gold)}
	var req := stage_depth_req(index)
	if max_depth < req:
		return {"ok": false,
			"reason": "Reach depth %d first (deepest so far: %d)." % [req, max_depth]}
	return {"ok": true, "reason": ""}
