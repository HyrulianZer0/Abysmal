extends Node
## LifeTree autoload — the soul tree, now named the Life Tree (v0.11.0).
##
## Design (Oct 17 + Oct 24, 2026 — see design-notes/morning-briefing-2026-10-11.md):
## - Unlocks on completing depth 1 (entering depth 2).
## - The tree is the soul made material: a laurel crown bound by an
##   ouroboros vine (the vine IS the ascension tree). First playthrough,
##   the soul earns 6 rings (3 left, 3 right) and trades them for the
##   laurel; the traded rings live on in the laurel forever.
## - Meeting a founder roots their gift AUTOMATICALLY — no purchase.
##   Founder nodes are the tree's first leaves; a Deep leaf holds future
##   growth. Nodes are always available (currency-gated only in future).
## - BREAK-NULL: no stat caps ever on Life Tree bonuses. Crit overflow
##   rule (past 100% crit, overflow adds crit damage) is documented here
##   but NOT wired yet — crit lives in combat.gd and no founder node
##   needs it in this slice.
## - The tree NEVER resets: buffs survive death, and the soul (tree +
##   nodes) persists through rebirth — only the mortal life resets.
## - NO new currency in this slice: skill points arrive with platinum
##   town upgrades in a later push (Hope was dropped as a currency Nov 4).
##   Do not invent a currency here.
##
## Wiring: GameState folds these bonuses into reset_run/regen/gold/
## rarity (same pattern as Prestige); main.gd drives unlock + meetings
## from _new_depth and persists this autoload under the "life_tree" key
## (additive key — old saves load with clean defaults, no version bump).

signal life_tree_changed

const FoundersScript := preload("res://scripts/founders.gd")

## True once depth 1 has been completed (entering depth 2+).
var unlocked: bool = false
## Founder id -> true once met. Never decreases, never resets.
var met: Dictionary = {}
## Pello's depth-10 deed scene signed: the town is unlocked.
var town_deed_signed: bool = false


func is_met(founder_id: String) -> bool:
	return bool(met.get(founder_id, false))


func met_ids() -> Array:
	var out: Array = []
	for fid in FoundersScript.all_ids():
		if is_met(fid):
			out.append(fid)
	return out


## Unlock the tree (completing depth 1). Idempotent.
func unlock() -> void:
	if unlocked:
		return
	unlocked = true
	life_tree_changed.emit()
	GameState.add_log("The Life Tree wakes — your soul takes root.")


## Meet a founder: root their gift automatically. Idempotent; a second
## meeting is a no-op. Defensively unlocks first — a node needs a tree.
## Live stats are adjusted immediately when alive; reset_run() recomputes
## the same bonuses from base, so there is never a double-apply.
func meet_founder(founder_id: String) -> bool:
	var f := FoundersScript.founder_by_id(founder_id)
	if f.is_empty() or is_met(founder_id):
		return false
	if not unlocked:
		unlock()
	met[founder_id] = true
	var buff := FoundersScript.buff_def(str(f["buff_id"]))
	if GameState.alive:
		GameState.max_hp += float(buff.get("max_hp_flat", 0.0))
		GameState.hp = minf(GameState.max_hp,
			GameState.hp + float(buff.get("max_hp_flat", 0.0)))
		GameState.atk += float(buff.get("atk_flat", 0.0))
	life_tree_changed.emit()
	GameState.add_log("You meet %s, the %s — %s (%s)." % [
		str(f["name"]), str(f["role"]), str(f["buff_name"]),
		str(f["buff_text"])])
	return true


## Sign Pello's deed (depth-10 scene). Idempotent.
func sign_deed() -> bool:
	if town_deed_signed:
		return false
	town_deed_signed = true
	life_tree_changed.emit()
	GameState.add_log("You sign Pello's deed — the town is yours to rebuild.")
	return true


## --- Bonus accessors (GameState folds these in) ---------------------------

func max_hp_bonus() -> float:
	var total := 0.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		total += float(FoundersScript.buff_def(
			str(f["buff_id"])).get("max_hp_flat", 0.0))
	return total


func atk_bonus() -> float:
	var total := 0.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		total += float(FoundersScript.buff_def(
			str(f["buff_id"])).get("atk_flat", 0.0))
	return total


func regen_bonus() -> float:
	var total := 0.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		total += float(FoundersScript.buff_def(
			str(f["buff_id"])).get("regen_flat", 0.0))
	return total


func material_yield_mult() -> float:
	var m := 1.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		m *= float(FoundersScript.buff_def(
			str(f["buff_id"])).get("material_mult", 1.0))
	return m


func gold_mult_bonus() -> float:
	var m := 1.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		m *= float(FoundersScript.buff_def(
			str(f["buff_id"])).get("gold_mult", 1.0))
	return m


func rarity_bonus() -> float:
	var total := 0.0
	for fid in met_ids():
		var f := FoundersScript.founder_by_id(fid)
		total += float(FoundersScript.buff_def(
			str(f["buff_id"])).get("rarity_flat", 0.0))
	return total


## --- Leaves (crown view model) ---------------------------------------------
## Leaf ids in crown order: the 5 founders, then the Deep leaf. The vine
## (ouroboros center) is the ascension tree and is not a leaf.

func leaf_ids() -> Array:
	var out: Array = FoundersScript.all_ids()
	out.append("deep")
	return out


## Display name for a leaf id ("deep" is the future-growth leaf).
func leaf_name(leaf_id: String) -> String:
	if leaf_id == "deep":
		return "Deep Leaf"
	var f := FoundersScript.founder_by_id(leaf_id)
	if f.is_empty():
		return leaf_id
	return str(f["name"])


## Node lines for a leaf's drill-in view: [name, effect text, level].
## Founder leaves show their gift (level 1 once met, else "not yet
## rooted"); the Deep leaf holds future growth (later push).
func leaf_nodes(leaf_id: String) -> Array:
	if leaf_id == "deep":
		return [["Deep growth",
			"More leaves grow here in a later push.", 0]]
	var f := FoundersScript.founder_by_id(leaf_id)
	if f.is_empty():
		return []
	var lvl := 1 if is_met(leaf_id) else 0
	var txt := str(f["buff_text"]) if lvl == 1 \
		else "Not yet rooted — meet %s at depth %d." % [
			str(f["name"]), int(f["depth"])]
	return [[str(f["buff_name"]), txt, lvl]]


## --- Save/load -------------------------------------------------------------
## Persisted by main.gd under the "life_tree" key. Additive key — old
## saves without it load with clean defaults (no save-version bump).

func to_dict() -> Dictionary:
	return {
		"unlocked": unlocked,
		"met": met.duplicate(),
		"town_deed_signed": town_deed_signed,
	}


func from_dict(d: Dictionary) -> void:
	unlocked = bool(d.get("unlocked", false))
	met = (d.get("met", {}) as Dictionary).duplicate()
	# Drop unknown ids (defensive: a renamed founder must not linger).
	var clean := {}
	for fid in met:
		if not FoundersScript.founder_by_id(str(fid)).is_empty():
			clean[str(fid)] = true
	met = clean
	town_deed_signed = bool(d.get("town_deed_signed", false))
	life_tree_changed.emit()
