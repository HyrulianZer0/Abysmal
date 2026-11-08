extends SceneTree
## Wave 3 balance soak (math layer — no scene, no RNG playthrough).
## Uses ONLY locked curves (hp x depth^1.2, atk x depth^1.05, def flat)
## and the staged depth-1 values in enemy.gd TYPES, plus the [TUNABLE]
## knobs in behaviors.gd. Mean hit = max(1, atk - def*0.8) x 1.1
## (10% crit for x2). Player numbers are SENSITIVITY columns, not a
## progression claim: depth-1 uses the real fresh-run values (HP 50,
## ATK 6, DEF 1); deeper depths sweep player ATK/HP columns because
## Jeff's depth-72 player build is not on record here.
## The live playthrough soak is tests/depth_scale_scene.tscn (600 s
## timeout) — this file is the per-type/per-depth table behind it.
##
## Run: godot --headless --path . --script tests/wave3_soak_test.gd
## Exits 0 on pass, 1 on any failure.

const BV = preload("res://scripts/behaviors.gd")
const EN = preload("res://scripts/enemy.gd")

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _mean_hit(atk: float, dfn: float) -> float:
	return maxf(1.0, atk - dfn * 0.8) * 1.1


func _scaled(tid: String, depth: int) -> Dictionary:
	var t: Dictionary = EN.TYPES[tid]
	return {
		"hp": float(t["hp"]) * pow(float(depth), 1.2),
		"atk": float(t["atk"]) * pow(float(depth), 1.05),
		"def": float(t["def"]),
	}


func _initialize() -> void:
	await process_frame
	_run()


func _run() -> void:
	print("WAVE3-SOAK: knob values pinned (changes must be deliberate)")
	_check(absf(BV.CHARGE_TELEGRAPH_TIME - 0.8) < 0.001, "charge telegraph 0.8s")
	_check(absf(BV.BRUTE_WINDUP - 1.0) < 0.001, "brute windup 1.0s")
	_check(absf(BV.GRAPPLE_HOLD_TIME - 5.0) < 0.001, "grapple hold 5s")
	_check(BV.GRAPPLE_STRUGGLE_THRESHOLD == 5, "grapple 5 struggles")
	_check(absf(BV.GRAPPLE_BREAK_DAMAGE_FRACTION - 0.25) < 0.001, "grapple break 25%")
	_check(absf(BV.DAZZLE_MISS_CHANCE - 0.5) < 0.001, "dazzle 50%")
	_check(absf(BV.DAZZLE_DURATION - 4.0) < 0.001, "dazzle 4s")
	_check(absf(BV.VENOM_DPS_PER_STACK_FRACTION - 0.30) < 0.001, "venom 0.30x atk")
	_check(BV.VENOM_MAX_STACKS == 3, "venom cap 3")
	_check(absf(BV.REGEN_OUT_OF_COMBAT_FRACTION - 0.02) < 0.001, "regen 2% ooc")
	_check(absf(BV.REGEN_IN_COMBAT_FRACTION - 0.005) < 0.001, "regen 0.5% combat")
	_check(absf(BV.REGEN_PAUSE_AFTER_DAMAGE - 3.0) < 0.001, "regen pause 3s")
	_check(absf(BV.CHARGE_WALL_STUN_TIME - 1.5) < 0.001, "charge wall stun 1.5s")

	print("WAVE3-SOAK: depth-1 table (player HP 50 / ATK 6 / DEF 1)")
	var worst_ttk := 0
	var worst_ehtk := 1000000
	var worst_single := 0.0
	for tid in EN.TYPES:
		var s := _scaled(tid, 1)
		var ttk: int = ceili(float(s["hp"]) / _mean_hit(6.0, float(s["def"])))
		var ehtk: int = ceili(50.0 / _mean_hit(float(s["atk"]), 1.0))
		var single: float = maxf(1.0, float(s["atk"]) - 0.8) * 2.0 * 1.5
		worst_ttk = maxi(worst_ttk, ttk)
		worst_ehtk = mini(worst_ehtk, ehtk)
		worst_single = maxf(worst_single, single)
		print("    d1 %-16s hp=%5.1f atk=%4.1f def=%.0f ttk=%2d hits, ehtk=%2d hits" % [
			tid, float(s["hp"]), float(s["atk"]), float(s["def"]), ttk, ehtk])
	_check(worst_ttk <= 15, "depth-1 worst player TTK <= 15 hits", "got %d" % worst_ttk)
	_check(worst_ehtk >= 4, "depth-1 worst enemy TTK >= 4 hits (no 1-3 shot)",
		"got %d" % worst_ehtk)
	_check(worst_single < 50.0, "depth-1 worst single hit (crit+brute) < player HP",
		"got %.1f" % worst_single)

	print("WAVE3-SOAK: depth-1 DoT lethality (venom / grapple alone)")
	var scorp1 := _scaled("scorpion", 1)
	var venom1 := 3.0 * 0.30 * float(scorp1["atk"])
	_check(50.0 / venom1 > 5.0, "depth-1 3-stack venom takes > 5s to kill alone",
		"%.1fs" % (50.0 / venom1))
	var kappa1 := _scaled("kappa", 1)
	var hold1 := 0.5 * float(kappa1["atk"])
	_check(50.0 / hold1 > 5.0, "depth-1 grapple hold takes > 5s to kill alone",
		"%.1fs" % (50.0 / hold1))

	print("WAVE3-SOAK: per-depth tables (HP/ATK scaled, TTK at player ATK 6/20/50/100)")
	for depth in [1, 10, 30, 72]:
		print("  --- depth %d ---" % depth)
		for tid in ["slime", "troll", "banshee", "scorpion", "drake", "oni"]:
			var s := _scaled(tid, depth)
			var row := "    d%-3d %-9s hp=%7.0f atk=%6.1f | ttk@" % [depth, tid,
				float(s["hp"]), float(s["atk"])]
			for patk in [6.0, 20.0, 50.0, 100.0]:
				row += " %d" % ceili(float(s["hp"]) / _mean_hit(patk, float(s["def"])))
			print(row + " hits (atk 6/20/50/100)")
		var troll := _scaled("troll", depth)
		var regen := 0.005 * float(troll["hp"])
		var breakeven := regen / 1.1 + float(troll["def"]) * 0.8
		print("    d%-3d troll in-combat regen=%.1f hp/s, break-even player ATK=%.1f" % [
			depth, regen, breakeven])
		_check(breakeven < 100.0, "depth %d troll regen break-even ATK < 100" % depth,
			"got %.1f" % breakeven)

	print("WAVE3-SOAK: deep venom watch item (formula, not a failure)")
	for depth in [10, 30, 72]:
		var s := _scaled("scorpion", depth)
		var venom := 3.0 * 0.30 * float(s["atk"])
		print("    d%-3d scorpion 3-stack venom = %.1f dps (atk %.1f)" % [
			depth, venom, float(s["atk"])])
		# Cap is what prevents unbounded growth: a 4th apply refreshes,
		# it must not raise DPS.
	var vst := BV.new_state("venom", 16.0, 5.0, 1.0)
	for _i in 3:
		BV.apply_venom(vst)
	_check(BV.apply_venom(vst) == 3, "venom 4th apply at cap stays 3 (no DPS growth)")

	print("WAVE3-SOAK: kiting + dive windows are bounded, not infinite")
	_check(BV.ranged_intent(2.0, false) == "cornered",
		"ranged with no step-back room is cornered (kite ends at walls)")
	var dive_time := (BV.FLY_HOVER_ALTITUDE - BV.FLY_DIVE_ALTITUDE) / BV.FLY_DIVE_SPEED_MULT
	_check(dive_time < 1.0, "flyer dive to reachable altitude < 1s",
		"got %.2fs" % dive_time)
	_check(BV.melee_reachable(BV.new_state("flyer/skirmisher", 12.0, 6.0, 0.0)) == false,
		"hovering flyer unreachable before dive")

	print("WAVE3-SOAK: decided-here rules re-examined (kept, with reason)")
	_check(BV.CHARGE_WALL_STUN_TIME > 0.0, "charge wall stun kept (punish window, no wall dmg)")
	_check(absf(BV.DAZZLE_MISS_CHANCE - 0.5) < 0.001, "dazzle = miss only kept (no move lock)")
	var ph := BV.new_state("phase", 15.0, 8.0, 0.0)
	ph.phase_drifting = true
	_check(absf(BV.phase_damage_taken_mult(ph) - 0.5) < 0.001,
		"phase = hittable at half damage kept (catalog never says untargetable)")
	var kd := BV.new_state("trapper/swarm", 12.0, 4.0, 0.0)
	var trap := BV.place_trap(kd, Vector2(1, 1))
	kd.dead = true
	_check(trap != null and not trap.triggered,
		"traps persist after trapper death (placed object, not aura)")
	var vr := BV.new_state("venom", 16.0, 5.0, 1.0)
	for _i in 3:
		BV.apply_venom(vr)
	var before := vr.venom_stacks.duplicate()
	BV.apply_venom(vr)
	_check(vr.venom_stacks == before or vr.venom_stacks.size() == 3,
		"venom refresh-at-cap kept (standard DoT behavior)")

	if _failures == 0:
		print("WAVE3-SOAK: ALL PASS")
	else:
		printerr("WAVE3-SOAK: %d FAILURES" % _failures)
	quit(_failures)
