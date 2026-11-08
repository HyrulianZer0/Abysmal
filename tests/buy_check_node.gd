extends Node
## Dev check: death-shop buy path through the live GameState autoload.
func _ready() -> void:
	var gs = GameState
	gs.gold = 1000.0
	assert(gs.buy_charm("blood_vial"), "buy charm")
	assert(gs.charm_count("blood_vial") == 1, "charm counted")
	assert(gs.buy_skill("attack"), "buy skill unlock")
	assert(gs.buy_skill("attack"), "buy skill lvl2")
	assert(gs.skill_level("attack") == 2, "skill at 2")
	assert(gs.buy_skill("lockpicking"), "lockpicking is live (not coming-soon)")
	assert(gs.skill_level("lockpicking") == 1, "lockpicking at 1")
	assert(not gs.buy_skill("smithing"), "smithing still coming-soon")
	gs.gold = 0.0
	assert(not gs.buy_charm("whetstone"), "broke = no buy")
	assert(gs.dmg_dealt_mult() > 1.0, "attack skill boosts damage")
	assert(gs.vitality_mult() == 1.0, "no vitality yet")
	assert(gs.regen_rate() == 0.0, "no regen yet")
	# Vitality + vial apply on next reset_run.
	gs.gold = 1000.0
	gs.buy_skill("vitality")
	gs.buy_charm("blood_vial")
	var hp_before: float = gs.max_hp
	gs.reset_run()
	assert(gs.max_hp > hp_before, "vitality+vial raise max_hp on reset")
	print("BUYCHECK: ALL PASS")
	get_tree().quit(0)
