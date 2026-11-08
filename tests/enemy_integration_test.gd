extends SceneTree
## Wave 2 INTEGRATION tests: enemy.gd behavior + voice hookup.
## Drives the public integration surface only (setup / update_behavior /
## take_damage / vocal hooks / trap + grapple wrappers) and proves the
## triangle for all 28 staged types: (a) wired model or upgraded
## procedural form, (b) a voice pool with >= 1 unflagged clip per
## context, (c) a behavior archetype profile. No APK, no spawn-picker
## change, no apex boss, no HELD file, no flagged audio anywhere.
##
## Run: godot --headless --path . --script tests/enemy_integration_test.gd
## Exits 0 on pass, 1 on any failure.

const EN = preload("res://scripts/enemy.gd")
const MM = preload("res://scripts/monster_models.gd")
const BV = preload("res://scripts/behaviors.gd")
const VM = preload("res://scripts/voice_map.gd")

const ALL_TYPES := ["slime", "bat", "skeleton", "rat", "spider", "snake",
		"wasp", "frog", "wolf", "goblin", "zombie", "ghost", "golem", "boar",
		"scorpion", "centipede", "skeleton_archer", "kobold", "imp", "pixie",
		"orc", "troll", "minotaur", "harpy", "oni", "kappa", "drake", "banshee"]
## Space-form archetypes that Wave 2 resolved only via the brawler
## fallback. Wave 3 fixed the lookup in behaviors.gd (ARCHETYPE_ALIASES
## + canonical_archetype): the TYPES strings stay verbatim, but the
## profile/intent now resolve to the NAMED archetype. The check in the
## triangle loop below pins that — a regression here means the named
## mechanics (swarm, pack burst, phase drift, sting) stopped firing.
const FORMERLY_FALLBACK_ONLY := ["rat", "wolf", "ghost", "scorpion"]

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _spawn(tid: String, hp_mult := 1.0, atk_mult := 1.0) -> Enemy:
	var e := Enemy.new()
	e.setup(tid, hp_mult, atk_mult, Vector2i(3, 3))
	root.add_child(e)
	return e


func _prime_audio():
	var am = root.get_node_or_null("AudioManager")
	if am != null and am.get("_pool") is Array and (am.get("_pool") as Array).is_empty():
		am.call("_ready")
	return am


func _initialize() -> void:
	await process_frame
	await process_frame
	_run()


func _run() -> void:
	var am = _prime_audio()
	_check(am != null, "AudioManager autoload present")
	# Nov 1, 2026: the flagged list is legitimately EMPTY (the one Layer 1
	# flag was confirmed by James and moved to the undead pool). The
	# check now pins the invariant instead: no flagged file is wired.
	var flagged_paths: Array = []
	for f in VM.FLAGGED_FILES:
		flagged_paths.append(str(f.get("path", "")))
	var flagged_wired: Array = []
	for pool in VM.VOCAL_POOLS:
		for c in VM.VOCAL_POOLS[pool]:
			if c in flagged_paths:
				flagged_wired.append(c)
	_check(flagged_wired.is_empty(), "no flagged file wired in any pool", str(flagged_wired))

	print("INTEGRATION: triangle for all 28 staged types")
	for tid in ALL_TYPES:
		var e := _spawn(tid)
		var t: Dictionary = EN.TYPES[tid]
		# (c) behavior leg: one state, verbatim archetype, scaled stats.
		_check(e.behavior_state != null, tid + " has BehaviorState")
		if e.behavior_state != null:
			_check(e.behavior_state.archetype == str(t.get("archetype", "")),
					tid + " state archetype verbatim", e.behavior_state.archetype)
			_check(absf(e.behavior_state.max_hp - e.max_hp) < 0.001,
					tid + " state max_hp = scaled max_hp")
			_check(absf(e.behavior_state.atk - e.atk) < 0.001,
					tid + " state atk = scaled atk")
			_check(absf(e.behavior_state.def - e.def) < 0.001,
					tid + " state def = flat def")
			var prof: Dictionary = BV.profile_for(e.behavior_state.archetype)
			_check(prof.has("speed_mult") and prof.has("damage_mult"),
					tid + " has behavior profile")
			# Wave 3: formerly-fallback types must resolve to a NAMED
			# profile, never the brawler fallback ("steady_melee").
			if FORMERLY_FALLBACK_ONLY.has(tid):
				_check(str(prof["special"]) != "steady_melee",
					tid + " resolves to a named profile, not brawler fallback",
					str(prof["special"]))
		# (a) model leg: wired model, live model, or procedural build.
		var reg: Dictionary = MM.for_type(tid)
		var model_leg := (not reg.is_empty()) or t.has("model") or t.has("build")
		_check(model_leg, tid + " model leg (wired / live / procedural)")
		if not reg.is_empty():
			_check(not MM.is_held_path(str(reg.get("model", ""))),
					tid + " wired model is not HELD")
		# (b) voice leg: pool per context, >= 1 clip, none flagged.
		_check(am != null and am.has_method("has_monster_voice")
				and bool(am.call("has_monster_voice", tid)),
				tid + " has monster voice")
		for ctx in ["idle", "attack", "death"]:
			var resolved := "" if am == null else str(am.call("resolve_monster_vocal", tid, ctx))
			_check(resolved != "", tid + " voice resolves for " + ctx, resolved)
			# Nov 1, 2026: jalastram-voice-008 is no longer flagged —
			# James repurposed it as the undead gasp loop, so undead
			# types may legitimately resolve to it now. No exclusion.
		e.queue_free()

	print("INTEGRATION: no HELD file / flagged audio / apex in enemy.gd")
	# Wave 2b: "fire-ice-stone-golem" and "3dassets" are NO LONGER banned
	# here — James confirmed the golem's CC-BY 3.0 election and approved
	# the 3DAssets.dev AI models in principle (Oct 29, 2026), so enemy.gd
	# legitimately names those paths now. Still banned: Cerberus (apex
	# scope, separate worker). Bone Golem is NOT banned any more — Nov 8,
	# 2026: it now has a matching staged ROSTER type + model
	# (bestiary/golem-construct/bone-golem.glb), so the TYPES expansion
	# wires it (see design-notes/types-expansion-20261108.md).
	var src := ""
	var f := FileAccess.open("res://scripts/enemy.gd", FileAccess.READ)
	if f != null:
		src = f.get_as_text()
		f.close()
	for bad in ["animated-cerberus",
			"jalastram-voice-008", "Cerberus"]:
		_check(not src.contains(bad), "enemy.gd has no '" + bad + "'")
	_check(not src.contains("itch.io") and not src.contains("freesound"),
			"enemy.gd has no forbidden source")

	print("INTEGRATION: locked scaling untouched (depth-10 troll)")
	var hp_mult := pow(10.0, 1.2)
	var atk_mult := pow(10.0, 1.05)
	var troll := _spawn("troll", hp_mult, atk_mult)
	_check(absf(troll.max_hp - 48.0 * hp_mult) < 0.01, "troll depth-10 hp unchanged")
	_check(absf(troll.behavior_state.max_hp - troll.max_hp) < 0.01,
			"troll state carries scaled hp")
	_check(absf(troll.def - 2.0) < 0.001, "troll def still flat")
	troll.queue_free()

	print("INTEGRATION: update() called per tick, outputs stored")
	var boar := _spawn("boar")
	boar.grid_pos = Vector2i(3, 3)
	boar.request_charge()
	var intent: Dictionary = boar.update_behavior(0.1, {"player_pos": Vector2(3, 6)})
	_check(boar.behavior_state != null, "boar state survives tick")
	_check(boar.behavior_action == "telegraph", "boar charge telegraph action",
			boar.behavior_action)
	_check(boar.behavior_telegraph == "pawing", "boar telegraph = pawing",
			boar.behavior_telegraph)
	_check(boar.last_telegraph == "pawing", "boar last_telegraph stored")
	_check(is_instance_valid(boar._telegraph_label) and boar._telegraph_label.visible
			and boar._telegraph_label.text != "",
			"boar telegraph label visible with text",
			"" if not is_instance_valid(boar._telegraph_label) else boar._telegraph_label.text)
	_check(boar.in_telegraph_window(), "boar in telegraph window")
	_check(intent.has("move_dir") and intent.has("damage_mult")
			and intent.has("venom_damage") and intent.has("healed"),
			"intent carries all documented keys")
	boar.queue_free()

	print("INTEGRATION: brute telegraph + ranged kiting")
	var oni := _spawn("oni")
	oni.grid_pos = Vector2i(5, 5)
	oni.update_behavior(0.1, {"player_pos": Vector2(5, 6)})
	_check(oni.behavior_telegraph == "club_raised", "oni club_raised in range",
			oni.behavior_telegraph)
	oni.queue_free()
	var archer := _spawn("skeleton_archer")
	archer.grid_pos = Vector2i(5, 5)
	var a_intent := archer.update_behavior(0.1, {"player_pos": Vector2(5, 6)})
	_check(a_intent.get("action", "") == "step_back", "archer steps back when closed on",
			str(a_intent.get("action", "")))
	archer.queue_free()

	print("INTEGRATION: grapple restrictions apply")
	var kappa := _spawn("kappa")
	_check(BV.try_grab(kappa.behavior_state, 1.0), "kappa grab starts in range")
	kappa.update_behavior(0.6, {"player_pos": Vector2(3, 4)})
	_check(kappa.behavior_grapple_phase == "held", "kappa holds after telegraph",
			kappa.behavior_grapple_phase)
	_check(kappa.player_grappled, "player_grappled true while held")
	_check(not kappa.player_can_move, "player cannot move while held")
	_check(absf(kappa.player_attack_mult - 0.5) < 0.001,
			"player attack mult 0.5 while held", str(kappa.player_attack_mult))
	var restr: Dictionary = kappa.grapple_player_restrictions()
	_check(bool(restr.get("held", false)) and not bool(restr.get("can_move", true)),
			"grapple_player_restrictions() reports held")
	var broke := false
	for _i in 5:
		broke = kappa.struggle_grapple()
	_check(broke, "5 struggles break the hold")
	kappa.update_behavior(0.1, {})
	_check(kappa.behavior_grapple_phase == "recover", "kappa recovers after break",
			kappa.behavior_grapple_phase)
	kappa.queue_free()

	print("INTEGRATION: venom + regen + notify_damaged")
	var scorp := _spawn("scorpion")
	_check(scorp.apply_venom() == 1, "scorpion venom first stack = 1")
	scorp.update_behavior(1.0, {})
	_check(scorp.behavior_venom_damage > 0.0, "venom_damage reported this tick",
			str(scorp.behavior_venom_damage))
	scorp.queue_free()
	var troll2 := _spawn("troll")
	troll2.hp = 24.0
	troll2.update_behavior(1.0, {"in_combat": false})
	_check(troll2.behavior_healed > 0.0, "troll regen healed reported",
			str(troll2.behavior_healed))
	_check(troll2.hp > 24.0, "troll hp actually healed")
	var hp_before := troll2.hp
	troll2.take_damage(1.0)
	_check(troll2.behavior_state.regen_pause_timer > 0.0,
			"notify_damaged pauses regen")
	troll2.queue_free()
	var troll3 := _spawn("troll")
	var hp0 := troll3.hp
	_check(not troll3.take_damage(1.0) and troll3.hp < hp0, "take_damage still works")
	troll3.queue_free()

	print("INTEGRATION: faint hints (ambusher hidden, trapper traps)")
	var spider := _spawn("spider")
	_check(spider.behavior_state.hidden, "spider starts hidden")
	_check(is_instance_valid(spider._hint_label) and spider._hint_label.visible,
			"spider faint hint visible pre-perception")
	spider.reveal_ambush()
	_check(not spider.behavior_state.hidden, "reveal_ambush clears hidden")
	spider.queue_free()
	var kobold := _spawn("kobold")
	_check(kobold.place_behavior_trap(Vector2(4, 4)), "kobold places a trap")
	_check(is_instance_valid(kobold._hint_label) and kobold._hint_label.visible,
			"kobold trap faint hint visible")
	var trig := kobold.update_behavior_traps(2.5, Vector2(9, 9))
	_check(trig.is_empty(), "arming trap does not trigger")
	trig = kobold.update_behavior_traps(0.1, Vector2(4, 4))
	_check(trig.size() == 1, "armed trap triggers on victim cell")
	kobold.queue_free()

	print("INTEGRATION: voices trigger per context, unknown fails silent")
	var slime := _spawn("slime")
	_check(slime.play_idle_vocal(), "slime idle vocal plays")
	_check(slime.play_attack_vocal(), "slime attack vocal plays")
	_check(not slime._play_vocal("bogus_ctx"), "bogus context fails silent")
	_check(am != null and not bool(am.call("has_monster_voice", "nope_not_a_monster")),
			"unknown type has no voice")
	_check(am != null and str(am.call("resolve_monster_vocal", "nope_not_a_monster")) == "",
			"unknown type resolves empty")
	slime.queue_free()
	var banshee := _spawn("banshee")
	var b_idle := "" if am == null else str(am.call("resolve_monster_vocal", "banshee", "idle"))
	var b_atk := "" if am == null else str(am.call("resolve_monster_vocal", "banshee", "attack"))
	_check("Breath_Scared" in b_idle, "banshee idle = breath pool", b_idle)
	_check("Scream_Male" in b_atk, "banshee attack = scream pool (layering future)", b_atk)
	banshee.queue_free()
	var zombie := _spawn("zombie")
	_check(zombie.take_damage(9999.0), "zombie killed by damage")
	_check(zombie.dead and zombie.behavior_state.dead, "death marks state dead")
	zombie.queue_free()
	var drake := _spawn("drake")
	_check(drake.play_idle_vocal(), "drake idle vocal plays (thin 2-clip pool)")
	drake.queue_free()

	print("INTEGRATION: idle voice is periodic, not every tick")
	var bat := _spawn("bat")
	bat.update_behavior(0.1, {})
	_check(absf(bat._idle_voice_timer - 0.1) < 0.001, "idle timer accumulates, no vocal yet")
	bat.update_behavior(5.0, {})
	_check(bat._idle_voice_timer < 0.1, "idle timer resets after periodic vocal")
	bat.queue_free()

	print("INTEGRATION: flyer altitude rule exposed")
	var harpy := _spawn("harpy")
	_check(harpy.behavior_state.altitude > 0.5, "harpy starts at hover altitude")
	_check(not harpy.is_melee_reachable(), "hovering harpy not melee-reachable")
	harpy.queue_free()

	if _failures == 0:
		print("INTEGRATION: ALL PASS")
	else:
		printerr("INTEGRATION: %d FAILURES" % _failures)
	quit(_failures)
