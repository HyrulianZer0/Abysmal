class_name GameMode
extends RefCounted
## Phase 3 state-machine seam: the three game states and their legal moves.
##
##   DUNGEON --(run ends: death screen restart)--> TOWN --(delve)--> DUNGEON
##                                                  TOWN <-(travel)-> OVERWORLD (stub)
##
## Everything routes through town — there is no direct DUNGEON <-> OVERWORLD
## travel. Mid-run town visits are NOT in Phase 3: town is the between-runs
## hub (entered on run end, left via delve or travel). A mid-run "retreat to
## town" would need abandon-run semantics James hasn't decided — flag it as
## a follow-up, don't improvise it here.
##
## Overworld map size: UNDECIDED — see OverworldView.OVERWORLD_MAP_SIZE
## (marked TODO_JAMES). Nothing in this file assumes a size.

enum State { DUNGEON, TOWN, OVERWORLD }


## Legal transitions. Same-state is always fine (no-op).
static func can_transition(from_state: int, to_state: int) -> bool:
	if from_state == to_state:
		return true
	match from_state:
		State.DUNGEON:
			return to_state == State.TOWN
		State.TOWN:
			return to_state == State.DUNGEON or to_state == State.OVERWORLD
		State.OVERWORLD:
			return to_state == State.TOWN
	return false


static func state_name(s: int) -> String:
	match s:
		State.DUNGEON:
			return "DUNGEON"
		State.TOWN:
			return "TOWN"
		State.OVERWORLD:
			return "OVERWORLD"
	return "UNKNOWN(%d)" % s


static func is_valid(s: int) -> bool:
	return s == State.DUNGEON or s == State.TOWN or s == State.OVERWORLD
