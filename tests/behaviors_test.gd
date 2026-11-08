extends SceneTree
## Behavior mechanics tests (Wave 2, Worker 2C).
## Drives scripts/behaviors.gd through its documented interface only:
## no enemy.gd edits, no spawning, no drops, no apex boss code.
##
## Run: godot --headless --path . --script tests/behaviors_test.gd
## Exits 0 on pass, 1 on any failure.

const BV = preload("res://scripts/behaviors.gd")

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _initialize() -> void:
	await process_frame
	_run()


func _run() -> void:
	print("BEHAVIORS: venom")
	var v := BV.new_state("venom", 16.0, 5.0, 1.0)
	_check(BV.apply_venom(v) == 1, "venom first apply = 1 stack")
	_check(BV.apply_venom(v) == 2, "venom second apply = 2 stacks")
	var dmg := BV.apply_venom_tick(v, 1.0)
	_check(absf(dmg - 2.0 * 0.30 * 5.0 * 1.0) < 0.001, "venom tick damage = stacks x 0.30 x atk", "got %.3f" % dmg)
	_check(BV.apply_venom(v) == 3, "venom caps at 3 stacks")
	_check(BV.apply_venom(v) == 3, "venom reapply at cap stays 3 (refresh)")
	for _i in 7:
		BV.apply_venom_tick(v, 1.0)
	_check(v.venom_stacks.is_empty(), "venom stacks expire after duration")
	_check(absf(BV.apply_venom_tick(v, 1.0)) < 0.001, "venom tick with no stacks = 0")

	print("BEHAVIORS: regen")
	var t := BV.new_state("tank/regen", 48.0, 7.0, 2.0)
	t.hp = 24.0
	var healed := BV.apply_regen(t, 1.0, false)
	_check(absf(healed - 0.02 * 48.0) < 0.001, "regen out-of-combat = 2% max HP/s", "got %.3f" % healed)
	t.hp = 24.0
	healed = BV.apply_regen(t, 1.0, true)
	_check(absf(healed - 0.005 * 48.0) < 0.001, "regen in-combat = 0.5% max HP/s (slower)", "got %.3f" % healed)
	var plain := BV.new_state("tank", 45.0, 8.0, 3.0)
	plain.hp = 20.0
	_check(absf(BV.apply_regen(plain, 1.0, false)) < 0.001, "plain tank does NOT regen")
	t.hp = 24.0
	BV.notify_damaged(t, 1.0)
	_check(absf(BV.apply_regen(t, 1.0, false)) < 0.001, "damage pauses regen")
	for _i in 3:
		BV.apply_regen(t, 1.0, false)
	t.hp = 24.0
	_check(BV.apply_regen(t, 1.0, false) > 0.0, "regen resumes after pause expires")
	var full := BV.new_state("tank/regen", 48.0, 7.0, 2.0)
	_check(absf(BV.apply_regen(full, 1.0, false)) < 0.001, "regen at full HP = 0")

	print("BEHAVIORS: charge telegraph")
	var c := BV.new_state("charger", 24.0, 8.0, 0.0)
	_check(BV.start_charge(c), "charge starts from idle")
	_check(c.charge_phase == "telegraph", "charge telegraph phase first")
	_check(BV.charge_telegraph(c) == "pawing", "charge telegraph is pawing")
	BV.update_charge(c, 0.8)
	_check(c.charge_phase == "charging", "telegraph completes into charging")
	BV.update_charge(c, 0.5, true)
	_check(c.charge_phase == "stunned", "wall impact stuns the charger")
	BV.update_charge(c, 1.5)
	_check(c.charge_phase == "idle", "stun expires back to idle")
	var c2 := BV.new_state("charger", 24.0, 8.0, 0.0)
	BV.start_charge(c2)
	BV.update_charge(c2, 0.8)
	for _i in 10:
		BV.update_charge(c2, 0.5)
	_check(c2.charge_phase == "recover" or c2.charge_phase == "idle", "charge ends in recover/idle after range", c2.charge_phase)
	var c3 := BV.new_state("charger", 24.0, 8.0, 0.0)
	var intent_c := BV.update(c3, 0.1, {"player_pos": Vector2(5, 0), "want_charge": true})
	_check(intent_c["telegraph"] == "pawing" or intent_c["action"] == "telegraph", "update() exposes charge telegraph")

	print("BEHAVIORS: AoE + breath cone")
	_check(absf(BV.aoe_damage_at(0.0, 3.0, 10.0) - 10.0) < 0.001, "AoE center = full damage")
	_check(absf(BV.aoe_damage_at(3.0, 3.0, 10.0) - 2.5) < 0.001, "AoE edge = 25% damage")
	_check(absf(BV.aoe_damage_at(3.5, 3.0, 10.0)) < 0.001, "AoE outside radius = 0")
	_check(BV.aoe_damage_at(1.5, 3.0, 10.0) > BV.aoe_damage_at(2.5, 3.0, 10.0), "AoE falloff decreases with distance")
	_check(BV.aoe_staggers(1.0, 3.0), "AoE staggers in inner half")
	_check(not BV.aoe_staggers(2.5, 3.0), "AoE does not stagger at rim")
	_check(BV.breath_cone_hit(Vector2.ZERO, Vector2(1, 0), Vector2(3, 0)), "breath hits target straight ahead in range")
	_check(not BV.breath_cone_hit(Vector2.ZERO, Vector2(1, 0), Vector2(0, 3)), "breath misses target 90 deg off-axis")
	_check(not BV.breath_cone_hit(Vector2.ZERO, Vector2(1, 0), Vector2(5, 0)), "breath misses target beyond range")
	_check(not BV.breath_cone_hit(Vector2.ZERO, Vector2.ZERO, Vector2(1, 0)), "breath with zero facing never hits")
	_check(BV.breath_cone_hit(Vector2.ZERO, Vector2(1, 0), Vector2(3, 1)), "breath hits target inside 30 deg half-angle")

	print("BEHAVIORS: grapple")
	var g := BV.new_state("grappler/tank", 30.0, 6.0, 2.0)
	_check(not BV.try_grab(g, 3.0), "grab fails beyond range")
	_check(BV.try_grab(g, 1.0), "grab starts within range")
	_check(g.grapple_phase == "telegraph", "grab telegraph first")
	var gdmg := BV.update_grapple(g, 0.5)
	_check(g.grapple_phase == "held", "grab telegraph completes into hold")
	_check(absf(gdmg) < 0.001, "no hold damage during telegraph tick")
	gdmg = BV.update_grapple(g, 1.0)
	_check(absf(gdmg - 0.5 * 6.0 * 1.0) < 0.001, "damage-while-held = 0.5 x atk / s", "got %.3f" % gdmg)
	var restr := BV.grapple_player_restrictions(g)
	_check(restr["can_move"] == false and restr["can_flee"] == false, "held player cannot move or flee")
	_check(absf(float(restr["attack_mult"]) - 0.5) < 0.001, "held player attacks at 0.5x")
	_check(not BV.grapple_struggle(g), "struggle 1 of 5 does not break")
	for _i in 3:
		BV.grapple_struggle(g)
	_check(BV.grapple_struggle(g), "struggle 5 of 5 breaks the hold")
	_check(g.grapple_phase == "recover", "broken grapple enters recover")
	BV.update_grapple(g, 1.0)
	_check(g.grapple_phase == "none", "grapple recover expires")
	var g2 := BV.new_state("grappler/tank", 30.0, 6.0, 2.0)
	BV.try_grab(g2, 1.0)
	BV.update_grapple(g2, 0.5)
	BV.notify_damaged(g2, 8.0)  # >= 25% of 30 max HP
	_check(g2.grapple_phase == "recover", "damage threshold auto-breaks grapple")

	print("BEHAVIORS: traps")
	var k := BV.new_state("trapper/swarm", 12.0, 4.0, 0.0)
	var trap := BV.place_trap(k, Vector2(2, 2))
	_check(trap != null, "trap placed")
	var res := BV.update_trap(k, trap, 0.1, Vector2(2, 2))
	_check(not bool(res["triggered"]), "arming trap does not trigger")
	BV.update_trap(k, trap, 2.0, Vector2(9, 9))
	res = BV.update_trap(k, trap, 0.1, Vector2(2, 2))
	_check(bool(res["triggered"]), "armed trap triggers in radius")
	_check(absf(float(res["damage"]) - 4.0) < 0.001, "trap damage = 1.0 x atk")
	_check(absf(float(res["root_time"]) - 2.0) < 0.001, "trap roots 2s")
	_check(BV.place_trap(k, Vector2(5, 5)) == null, "trap placement respects cooldown")
	k.trap_cooldown_timer = 0.0
	var trap2 := BV.place_trap(k, Vector2(5, 5))
	BV.update_trap(k, trap2, 2.5, Vector2(9, 9))
	_check(not BV.disarm_trap(trap2, 0.5, true, 1.0), "partial disarm channel does not disarm")
	_check(not BV.disarm_trap(trap2, 0.1, false, 1.0), "interrupted channel resets")
	_check(not trap2.disarmed, "interrupted trap is not disarmed")
	_check(BV.disarm_trap(trap2, 1.5, true, 1.0), "full uninterrupted channel disarms")
	var kd := BV.new_state("trapper/swarm", 12.0, 4.0, 0.0)
	kd.dead = true
	_check(BV.place_trap(kd, Vector2(1, 1)) == null, "dead trapper places no traps")

	print("BEHAVIORS: dazzle, ranged, flying")
	var p := BV.new_state("flyer/caster", 7.0, 4.0, 0.0)
	BV.apply_dazzle(p)
	_check(absf(BV.dazzle_miss_chance(p) - 0.5) < 0.001, "dazzled target has 50% miss chance")
	BV.update_dazzle(p, 4.0)
	_check(absf(BV.dazzle_miss_chance(p)) < 0.001, "dazzle expires after duration")
	_check(BV.ranged_intent(2.0) == "step_back", "ranged steps back when closed on")
	_check(BV.ranged_intent(2.0, false) == "cornered", "ranged cornered with no step-back room")
	_check(BV.ranged_intent(5.0) == "hold", "ranged holds in band")
	_check(BV.ranged_intent(9.0) == "advance", "ranged advances when target too far")
	var f := BV.new_state("flyer/skirmisher", 12.0, 6.0, 0.0)
	_check(absf(f.altitude - 1.5) < 0.001, "flyer starts at hover altitude")
	_check(not BV.melee_reachable(f), "hovering flyer not melee-reachable")
	BV.update_flight(f, 0.1, true)
	BV.update_flight(f, 0.5)  # one dive tick: 1.5 -> 0.25, still diving
	_check(f.altitude < 0.5, "diving flyer drops to melee-reachable altitude")
	_check(BV.melee_reachable(f), "diving flyer is melee-reachable at low altitude")
	BV.update_flight(f, 0.5)  # reaches dive floor, flips to climb
	BV.update_flight(f, 0.5)  # climbing away
	_check(f.flight_phase == "climb" or f.flight_phase == "hover", "flyer climbs away after the dive")

	print("BEHAVIORS: archetype distinctions")
	var seen := {}
	for arch in BV.CANONICAL_ARCHETYPES:
		var prof := BV.profile_for(arch)
		var sig := "%s|%s|%s|%s|%s|%s" % [str(prof["speed_mult"]), str(prof["windup"]), str(prof["recovery"]), str(prof["attack_cooldown"]), str(prof["damage_mult"]), str(prof["special"])]
		_check(not seen.has(sig), arch + " profile differs from all others", sig)
		seen[sig] = arch
	var brute_i := BV.update(BV.new_state("brute", 32.0, 8.0, 1.0), 0.1, {"player_pos": Vector2(1, 0)})
	var swarm_i := BV.update(BV.new_state("swarm", 10.0, 3.0, 0.0), 0.1, {"player_pos": Vector2(1, 0)})
	_check(brute_i["damage_mult"] != swarm_i["damage_mult"] or brute_i["move_speed_mult"] != swarm_i["move_speed_mult"], "brute vs swarm intents differ observably")
	var amb := BV.new_state("ambusher", 14.0, 5.0, 0.0)
	_check(amb.hidden and amb.hint_visible, "ambusher starts hidden WITH a faint hint (never zero-signal)")
	_check(absf(BV.ambush_first_strike_mult(amb) - 1.5) < 0.001, "hidden first strike = 1.5x")
	BV.ambush_reveal(amb)
	_check(absf(BV.ambush_first_strike_mult(amb) - 1.0) < 0.001, "revealed ambusher loses first-strike bonus")
	_check(BV.pack_damage_mult(1) == 1.0 and BV.pack_damage_mult(3) == 1.5, "pack burst gates on 3+ allies")
	_check(absf(BV.swarm_damage_mult(0) - 1.0) < 0.001 and absf(BV.swarm_damage_mult(5) - 1.5) < 0.001, "swarm bonus scales then caps")
	var ph := BV.new_state("phase", 15.0, 8.0, 0.0)
	ph.phase_drifting = true
	_check(absf(BV.phase_damage_taken_mult(ph) - 0.5) < 0.001, "drifting phase enemy takes half damage (still hittable)")
	_check(BV.goblin_is_cowardly(0) and not BV.goblin_is_cowardly(2), "goblin courage flips at 2 allies")
	var comp := BV.profile_for("charger/brute")
	_check(str(comp["secondary"]) == "brute", "composite records its second half")
	_check(BV.profile_for("not_an_archetype")["special"] == "none", "unknown archetype falls back to brawler, no crash")

	print("BEHAVIORS: edge inputs + update() safety")
	var zero := BV.new_state("venom", 0.0, 0.0, 0.0)
	_check(BV.apply_venom(zero) >= 0, "venom on zero-HP state does not crash")
	_check(absf(BV.apply_venom_tick(zero, 0.0)) < 0.001, "zero delta venom tick = 0")
	_check(absf(BV.apply_regen(zero, 1.0, false)) < 0.001, "zero max-HP regen = 0")
	var dead := BV.new_state("brute", 32.0, 8.0, 1.0)
	dead.dead = true
	var di := BV.update(dead, 0.1, {"player_pos": Vector2(1, 0)})
	_check(di["action"] == "dead", "dead enemy update returns dead intent")
	var neg := BV.update(BV.new_state("brawler", 18.0, 4.0, 0.0), -1.0, {"player_pos": Vector2(1, 0)})
	_check(neg["action"] == "strike" or neg["action"] == "advance", "negative delta does not crash update")
	var null_i := BV.update(null, 0.1, {})
	_check(null_i["action"] == "idle", "null state update returns idle intent")
	var caster_i := BV.update(BV.new_state("caster", 22.0, 9.0, 0.0), 0.1, {"player_pos": Vector2(5, 0)})
	_check(caster_i["telegraph"] == "wail_windup" and caster_i["attack_kind"] == "scream", "caster in range telegraphs its scream")

	if _failures == 0:
		print("BEHAVIORS: ALL PASS")
	else:
		printerr("BEHAVIORS: %d FAILURES" % _failures)
	quit(_failures)
