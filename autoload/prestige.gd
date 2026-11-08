extends Node
## Prestige autoload — meta progression that NEVER resets: prestige tokens,
## prestige-cycle depth records, and ascension perks.
##
## Design (Phase 4, Oct 2026 — see design-notes/prestige-design-2026-10.md):
## - Clearing depth 10 (descending 10 -> 11) awards one Abyssal Token.
##   Repeatable: every full 1-10 clear earns another.
## - cycle_best_depth is the furthest depth reached this prestige cycle,
##   tracked across runs and deaths. A cycle ends only on ascension.
## - Ascending costs ASCENSION_TOKEN_COST tokens and grants +1 stack of
##   every unlocked ascension perk (+1 bonus stack when this cycle beat
##   last cycle's best depth). Ascension never resets anything else —
##   skills, charms, gold, heirlooms all carry on. Purely additive.
##
## Wiring: GameState.next_depth() calls notify_descend(); main.gd persists
## this autoload inside the save file ("prestige" key).

signal prestige_changed

## Clearing this depth (descending to TOKEN_CLEAR_DEPTH + 1) earns a token.
const TOKEN_CLEAR_DEPTH := 10
## Player-facing name of the token.
const TOKEN_NAME := "Abyssal Token"
## Tokens consumed by one ascension. TUNING — James's call.
const ASCENSION_TOKEN_COST := 3
## First implemented ascension perk.
const PERK_GILDED_SOUL := "gilded_soul"

## Perk registry. kind "gold_mult": each stack multiplies gold gain by
## (1 + per_stack). max_stacks 0 = unlimited. unlocked:false entries are
## future perks James hasn't approved yet — ascend() skips them.
const PERKS: Array = [
	{
		"id": PERK_GILDED_SOUL, "name": "Gilded Soul",
		"desc": "+10% gold from all sources, forever.",
		"kind": "gold_mult", "per_stack": 0.10,
		"max_stacks": 0, "unlocked": true,
	},
]

var tokens: int = 0
var lifetime_tokens: int = 0
var ascensions: int = 0
var cycle_best_depth: int = 1
var last_cycle_best_depth: int = 0
## perk id -> stacks granted by ascensions. Never decreases.
var perk_stacks: Dictionary = {}


func perk_def(perk_id: String) -> Dictionary:
	for p in PERKS:
		var pd := p as Dictionary
		if str(pd.get("id", "")) == perk_id:
			return pd
	return {}


func stacks_of(perk_id: String) -> int:
	return int(perk_stacks.get(perk_id, 0))


## Multiplicative gold bonus from all unlocked gold_mult perks.
## GameState.gold_mult() folds this in — one hook, no other economy edits.
func gold_mult_bonus() -> float:
	var m := 1.0
	for p in PERKS:
		var pd := p as Dictionary
		if not bool(pd.get("unlocked", false)):
			continue
		if str(pd.get("kind", "")) != "gold_mult":
			continue
		m *= pow(1.0 + float(pd.get("per_stack", 0.0)),
			float(stacks_of(str(pd["id"]))))
	return m


## Record that the crawler reached depth d this cycle (max wins).
func note_depth(d: int) -> void:
	if d > cycle_best_depth:
		cycle_best_depth = d
		prestige_changed.emit()


## Called by GameState.next_depth() on every descend. Awards the token
## when the cleared floor is TOKEN_CLEAR_DEPTH (10 -> 11).
func notify_descend(from_depth: int, to_depth: int) -> void:
	note_depth(to_depth)
	if from_depth == TOKEN_CLEAR_DEPTH:
		tokens += 1
		lifetime_tokens += 1
		prestige_changed.emit()
		GameState.add_log("Floor 10 cleared! Earned an %s (%d held)."
			% [TOKEN_NAME, tokens])


func can_ascend() -> bool:
	return tokens >= ASCENSION_TOKEN_COST


## Ascend: spend tokens, gain permanent perk stacks, roll a new cycle.
## Returns a result Dictionary; {"ok": false} when tokens are short.
## Nothing else is touched — no meta power is ever reset or taxed.
func ascend() -> Dictionary:
	var res := {
		"ok": false, "stacks_granted": 0, "record_bonus": false,
		"perks": [], "tokens_spent": 0,
	}
	if not can_ascend():
		return res
	tokens -= ASCENSION_TOKEN_COST
	var record := cycle_best_depth > last_cycle_best_depth
	var stacks := 1 + (1 if record else 0)
	var granted: Array = []
	for p in PERKS:
		var pd := p as Dictionary
		if not bool(pd.get("unlocked", false)):
			continue
		var pid := str(pd["id"])
		var cap := int(pd.get("max_stacks", 0))
		var now := stacks_of(pid) + stacks
		if cap > 0:
			now = mini(now, cap)
		perk_stacks[pid] = now
		granted.append(pid)
	ascensions += 1
	last_cycle_best_depth = cycle_best_depth
	cycle_best_depth = 1
	res["ok"] = true
	res["stacks_granted"] = stacks
	res["record_bonus"] = record
	res["perks"] = granted
	res["tokens_spent"] = ASCENSION_TOKEN_COST
	prestige_changed.emit()
	GameState.add_log("ASCENSION! The abyss remembers you. (%s)"
		% ("Record delve — bonus power!" if record else "Power grows."))
	return res


## --- Save/load -----------------------------------------------------------
## Persisted by main.gd under the "prestige" key. Additive key — old saves
## without it load with clean defaults (no save-version bump needed).

func to_dict() -> Dictionary:
	return {
		"tokens": tokens,
		"lifetime_tokens": lifetime_tokens,
		"ascensions": ascensions,
		"cycle_best_depth": cycle_best_depth,
		"last_cycle_best_depth": last_cycle_best_depth,
		"perk_stacks": perk_stacks.duplicate(),
	}


func from_dict(d: Dictionary) -> void:
	tokens = int(d.get("tokens", 0))
	lifetime_tokens = int(d.get("lifetime_tokens", 0))
	ascensions = int(d.get("ascensions", 0))
	cycle_best_depth = maxi(1, int(d.get("cycle_best_depth", 1)))
	last_cycle_best_depth = int(d.get("last_cycle_best_depth", 0))
	perk_stacks = (d.get("perk_stacks", {}) as Dictionary).duplicate()
	prestige_changed.emit()
