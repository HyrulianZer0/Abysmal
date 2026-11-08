extends SceneTree
## Wave 4 apex boss treatments test (Oct 29, 2026).
## Drives scripts/apex_bosses.gd only — no spawn wiring, no enemy.gd
## combat-math changes, no behaviors.gd changes, no APK.
## Run: godot --headless --path . --script tests/apex_bosses_test.gd
## Exits 0 on pass, 1 on any failure.
##
## Covers: all 16 bosses (Cerberus, the 16th, landed Nov 1, 2026 in a
## director-authorized build); every
## boss has form + voice pool + behavior pattern + proposal slot data;
## voice pools match voice_map.gd APEX_VOCAL_POOLS exactly and resolve
## only to staged, loadable, unflagged clips (unwired pools never
## resolve); stat derivation pins the locked curves + the one explicit
## boss-tier step at depths 1/10/30; boss twists fire (vessel, heads,
## frenzy, drink pause, brood timer, gaze, totems, illusions, shell);
## no apex boss in the normal spawn table or picker; encounter hooks
## exist but are NOT activated; capstone data is the Crown of the
## Deep with the action-expression rule and no endgame built.

const AB = preload("res://scripts/apex_bosses.gd")
const VM = preload("res://scripts/voice_map.gd")
const DG = preload("res://scripts/dungeon_gen.gd")
const EN = preload("res://scripts/enemy.gd")

const EXPECTED_IDS := ["medusa", "typhon", "echidna", "fenrir",
	"jormungandr", "surtr", "fafnir", "baba_yaga", "koschei",
	"humbaba", "shuten_doji", "orochi", "ravana", "anzu", "tarasque",
	"cerberus"]
const EXPECTED_SLOTS := ["face", "chest", "neck", "hands", "waist",
	"weapon", "shoulders", "trinket", "ring_l", "ring_r", "arms",
	"off_hand", "legs", "feet", "back", "head"]
const VALID_SLOTS := ["head", "face", "neck", "shoulders", "chest",
	"back", "arms", "hands", "waist", "legs", "feet", "ring_l",
	"ring_r", "trinket", "weapon", "off_hand"]

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _approx(a: float, b: float, tol: float = 0.01) -> bool:
	return absf(a - b) <= tol * maxf(1.0, absf(b))


func _initialize() -> void:
	await process_frame
	_run()


func _run() -> void:
	print("APEX: roster = all 16 apex bosses")
	var ids: Array = AB.boss_ids()
	_check(ids.size() == 16, "16 apex bosses", "got %d: %s" % [ids.size(), str(ids)])
	for eid in EXPECTED_IDS:
		_check(AB.is_apex(eid), "boss present: %s" % eid)
	_check(AB.is_apex("cerberus"), "Cerberus has an entry (16th boss landed Nov 1, 2026)")
	_check(not AB.boss("cerberus").is_empty(), "Cerberus dict is non-empty")
	_check(not AB.is_apex("apex") and not AB.is_apex(""), "unknown ids rejected")

	print("APEX: code text contains no HELD markers or removed-capstone text")
	var text: String = FileAccess.get_file_as_string("res://scripts/apex_bosses.gd")
	for banned in ["3dassets", "bone-golem", "fire-ice-stone",
			"jalastram", "warden of the abyss"]:
		_check(not (banned in text.to_lower()),
			"apex code free of: %s" % banned, "found in apex_bosses.gd")

	print("APEX: four legs per boss (form + voice + behavior + slot proposal)")
	var seen_slots: Array = []
	for bid in EXPECTED_IDS:
		var b: Dictionary = AB.boss(bid)
		_check(str(b["display"]).length() > 0, "%s display name" % bid)
		_check(str(b["silhouette"]).length() > 30, "%s silhouette" % bid)
		_check(float(b["scale_m"]) > 0.0, "%s scale > 0" % bid)
		_check((b["colors"] as Array).size() >= 2, "%s palette >= 2 colors" % bid)
		_check(str(b["idle_motion"]).length() > 0 and str(b["attack_motion"]).length() > 0
			and str(b["death_motion"]).length() > 0, "%s idle/attack/death motion" % bid)
		if bid == "cerberus":
			_check(str(b["model"]) == "res://assets/models/apex/cerberus_v003_fixed.glb",
				"cerberus wires the verified v003 model")
			_check("CC-BY 3.0" in str(b["model_note"]) and "eyeballed" in str(b["model_note"]),
				"cerberus model note carries attribution + eyeball record")
		else:
			_check(str(b["model"]) == "res://assets/models/apex/%s.glb" % bid.replace("_", "-"),
				"%s wires its guide-built apex model" % bid)
		_check(str(b["twist"]).length() > 0 and str(b["counters"]).length() > 0,
			"%s twist + counters" % bid)
		var attacks: Array = b["attacks"]
		_check(attacks.size() >= 3, "%s >= 3 signature attacks" % bid, "got %d" % attacks.size())
		for a in attacks:
			_check(str(a["name"]).length() > 0 and str(a["tell"]).length() > 0
				and str(a["counter"]).length() > 0 and str(a["mechanic"]).length() > 0,
				"%s attack %s has name/tell/counter/mechanic" % [bid, str(a["name"])])
		_check(VALID_SLOTS.has(str(b["slot"])), "%s slot is a real body slot" % bid)
		_check(not seen_slots.has(str(b["slot"])), "%s slot unique" % bid)
		seen_slots.append(str(b["slot"]))
		_check(bool(b["slot_proposal"]), "%s slot flagged PROPOSAL" % bid)
		_check(str(b["slot_item"]).length() > 0, "%s slot item named" % bid)
		_check(str(b["material"]).length() > 0, "%s material drop from filled list" % bid)
		_check("filled list" in str(b["material_source"]), "%s material source is filled list" % bid)
	seen_slots.sort()
	var want_slots: Array = EXPECTED_SLOTS.duplicate()
	want_slots.sort()
	_check(seen_slots == want_slots, "16 slots = every body slot including head",
		"got %s" % str(seen_slots))
	_check(AB.boss("surtr")["slot"] == "weapon", "Surtr keeps Weapon (lore-doc resolution)")
	_check(AB.boss("orochi")["slot"] == "legs", "Orochi takes legs/greaves, not Weapon")

	print("APEX: voice pools match voice_map APEX_VOCAL_POOLS exactly")
	var flagged: Array = []
	for fl in VM.FLAGGED_FILES:
		flagged.append(str(fl["path"]))
	for bid in EXPECTED_IDS:
		var pools: Array = AB.apex_vocal_pools(bid)
		var key: String = str(AB.ID_TO_VOICE_KEY.get(bid, ""))
		var want: Array = []
		for p in (VM.APEX_VOCAL_POOLS.get(key, []) as Array):
			want.append(str(p))
		_check(pools == want, "%s pools match voice_map" % bid, "got %s want %s" % [str(pools), str(want)])
		var entry: Dictionary = AB.apex_voice_entry(bid)
		for p in (entry["wired_pools"] as Array):
			_check(VM.VOCAL_POOLS.has(str(p)), "%s wired pool %s is a real pool" % [bid, str(p)])
		for p in (entry["unwired_pools"] as Array):
			_check(VM.APEX_ONLY_POOLS.has(str(p)), "%s unwired pool %s is a known unwired pool" % [bid, str(p)])
		var resolved: Dictionary = AB.resolve_apex_vocal(bid, "idle")
		if (entry["wired_pools"] as Array).is_empty():
			_check(str(resolved["clip"]) == "", "%s with no wired pool resolves to no clip" % bid)
		else:
			_check(FileAccess.file_exists(str(resolved["clip"])), "%s clip exists" % bid)
			_check(load(str(resolved["clip"])) != null, "%s clip loads" % bid)
			_check(not flagged.has(str(resolved["clip"])), "%s clip is not flagged" % bid)
		var atk_v: Dictionary = AB.resolve_apex_vocal(bid, "attack")
		var dth_v: Dictionary = AB.resolve_apex_vocal(bid, "death")
		_check(float(atk_v["pitch"]) > float(resolved["pitch"]), "%s attack pitch > idle" % bid)
		_check(float(dth_v["pitch"]) < float(resolved["pitch"]), "%s death pitch < idle" % bid)
	_check(AB.apex_voice_entry("baba_yaga")["wired_pools"].is_empty()
		and AB.apex_voice_entry("baba_yaga")["unwired_pools"].has("human"),
		"Baba Yaga: human pool unwired, never resolved")
	_check(AB.apex_voice_entry("typhon")["unwired_pools"].has("abyssal")
		and str(AB.resolve_apex_vocal("typhon", "idle")["pool"]) == "dragon",
		"Typhon: abyssal unwired, dragon primary resolves")

	print("APEX: stat derivation (locked curves + one explicit boss step)")
	_check(AB.APEX_HP_MULT == 5.0 and AB.APEX_ATK_MULT == 2.0 and AB.APEX_DEF_BONUS == 2.0,
		"boss-tier step pinned: HP x5, ATK x2, DEF +2")
	for bid in EXPECTED_IDS:
		var b: Dictionary = AB.boss(bid)
		var s1: Dictionary = AB.scaled_stats(bid, 1)
		_check(_approx(float(s1["hp"]), float(b["base_hp"]) * 5.0), "%s depth-1 HP" % bid)
		_check(_approx(float(s1["atk"]), float(b["base_atk"]) * 2.0), "%s depth-1 ATK" % bid)
		_check(_approx(float(s1["def"]), float(b["base_def"]) + 2.0), "%s depth-1 DEF" % bid)
		var s10: Dictionary = AB.scaled_stats(bid, 10)
		_check(_approx(float(s10["hp"]), float(b["base_hp"]) * 5.0 * pow(10.0, 1.2), 0.001),
			"%s depth-10 HP (locked x depth^1.2)" % bid)
		_check(_approx(float(s10["atk"]), float(b["base_atk"]) * 2.0 * pow(10.0, 1.05), 0.001),
			"%s depth-10 ATK (locked x depth^1.05)" % bid)
		_check(_approx(float(s10["def"]), float(s1["def"])), "%s DEF flat across depths" % bid)
		var s30: Dictionary = AB.scaled_stats(bid, 30)
		_check(_approx(float(s30["hp"]), float(b["base_hp"]) * 5.0 * pow(30.0, 1.2), 0.001),
			"%s depth-30 HP" % bid)
	_check(AB.scaled_stats("nope", 10).is_empty(), "unknown boss stats empty")

	print("APEX: behavior machine (phases + twists)")
	var med := AB.new_state("medusa", 1)
	var mi := AB.update(med, 0.1, {})
	_check(str(mi["attack_kind"]) == "Petrifying Gaze" and bool(mi["gaze_active"]),
		"Medusa first attack is the gaze with eye-glow tell", str(mi))
	med.hp = med.max_hp * 0.4
	var mi2 := AB.update(med, 3.5, {})
	_check(int(mi2["phase"]) == 2, "phase 2 at/below 50% HP")
	var kos := AB.new_state("koschei", 1)
	_check(AB.damage_taken_mult(kos) == 0.0, "Koschei invulnerable while vessel lives")
	_check(AB.break_vessel(kos) and AB.damage_taken_mult(kos) == 1.0,
		"breaking the vessel ends invulnerability")
	_check(not AB.break_vessel(kos), "second vessel break fails (already broken)")
	var oro := AB.new_state("orochi", 1)
	_check(oro.heads_remaining == 8, "Orochi starts with 8 heads")
	oro.hp = oro.max_hp * 0.5
	var oi := AB.update(oro, 0.1, {})
	_check(int(oi["heads_remaining"]) == 4, "Orochi at 50% HP has 4 heads", str(oi))
	oro.hp = oro.max_hp * 0.05
	var oi2 := AB.update(oro, 3.5, {})
	_check(int(oi2["heads_remaining"]) == 1, "Orochi never drops below 1 head")
	var shu := AB.new_state("shuten_doji", 1)
	_check(_approx(AB.frenzy_mult(shu), 1.0), "Shuten frenzy 1.0 at full HP")
	shu.hp = shu.max_hp * 0.5
	_check(_approx(AB.frenzy_mult(shu), 1.25), "Shuten frenzy 1.25 at half HP")
	var drink_seen := false
	var shu2 := AB.new_state("shuten_doji", 1)
	for _i in 8:
		shu2.attack_timer = 0.0
		var si := AB.update(shu2, 0.1, {})
		if bool(si["drink_pause"]):
			drink_seen = true
			_check(float(si["damage_mult"]) == 0.0, "drink pause deals no damage (the opening)")
	_check(drink_seen, "Shuten drinking pause appears in the attack cycle")
	var ech := AB.new_state("echidna", 1)
	var ei := AB.update(ech, 12.5, {})
	_check(bool(ei["summon_wave"]), "Echidna brood wave fires on its 12s timer")
	var rav := AB.new_state("ravana", 1)
	rav.hp = rav.max_hp * 0.4
	var ri := AB.update(rav, 0.1, {})
	_check(bool(ri["illusions_active"]), "Ravana illusions active in phase 2")
	var tar := AB.new_state("tarasque", 1)
	var ti := AB.update(tar, 0.1, {})
	_check(_approx(float(ti["frontal_damage_mult"]), 0.5), "Tarasque frontal hits halved (shell)")
	var bab := AB.new_state("baba_yaga", 1)
	_check(bab.totems_remaining == 3, "Baba Yaga starts with 3 skull totems")
	_check(AB.destroy_totem(bab) and bab.totems_remaining == 2, "destroying a totem thins the volley")
	var dead := AB.new_state("fenrir", 1)
	dead.hp = 0.0
	_check(str(AB.update(dead, 0.1, {})["action"]) == "dead", "dead boss update returns dead")
	var null_i := AB.update(null, 0.1, {})
	_check(str(null_i["action"]) == "idle", "null state update returns idle")
	_check(AB.breath_hits(Vector2.ZERO, Vector2(1, 0), Vector2(2, 0)),
		"breath cone hits a target in front (generic reuse)")
	_check(not AB.breath_hits(Vector2.ZERO, Vector2(1, 0), Vector2(-2, 0)),
		"breath cone misses a target behind")
	_check(_approx(AB.aoe_damage_at(0.0, 3.0, 10.0), 10.0), "AoE full damage at center")
	_check(_approx(AB.aoe_damage_at(3.0, 3.0, 10.0), 2.5), "AoE 25% at the rim (generic falloff)")
	_check(AB.venom_tick_damage(AB.new_state("fafnir", 1), 1.0, 2) > 0.0,
		"venom tick damage positive for a venom boss")

	print("APEX: never in the normal spawn picker")
	for d in [1, 2, 3, 4, 5, 6, 8, 10, 30, 72]:
		for entry in DG.spawn_table(d):
			var t := str(entry[0])
			_check(EN.TYPES.has(t), "depth %d table type %s is staged" % [d, t])
			_check(not AB.is_apex(t), "depth %d table has no apex (%s)" % [d, t])
	var rng := RandomNumberGenerator.new()
	rng.seed = 987654321
	var apex_seen := false
	for _i in 2000:
		var t2: String = DG._pick_type(30, rng, false)
		if AB.is_apex(t2):
			apex_seen = true
	_check(not apex_seen, "2000 picker rolls at depth 30 never return an apex boss")

	print("APEX: encounter hooks exist but are NOT activated")
	for bid in EXPECTED_IDS:
		var hook: Dictionary = AB.encounter_hook(bid)
		_check(int(hook["depth_min"]) >= 12, "%s hook has a depth threshold" % bid)
		_check(not bool(hook["activated"]), "%s hook not activated" % bid)
		_check(bool(hook["proposal"]), "%s hook flagged proposal" % bid)
		_check(not AB.encounter_available(bid, int(hook["depth_min"]) - 1),
			"%s hook closed below threshold" % bid)
		_check(AB.encounter_available(bid, int(hook["depth_min"])),
			"%s hook open at threshold" % bid)
	print("APEX: Cerberus (16th boss) specifics")
	_check(AB.boss("cerberus")["slot"] == "head", "Cerberus takes the head slot")
	_check(str(AB.boss("cerberus")["slot_item"]) == "Gatekeeper's Triune Helm",
		"Cerberus drops the Triune Helm")
	_check(AB.boss("cerberus")["base_type"] == "Hellhound", "Cerberus rides the Hellhound base")
	_check(str(AB.boss("cerberus")["material"]) == "sulfurous canine fang",
		"Cerberus material is the Hellhound filled-list entry")
	var cer := AB.new_state("cerberus", 1)
	var ci := AB.update(cer, 0.1, {})
	_check(str(ci["attack_kind"]) == "Triple Bite", "Cerberus first attack is Triple Bite", str(ci))
	var cer_attacks: Array = AB.boss("cerberus")["attacks"]
	_check(str(cer_attacks[0].get("side_effect", "")) == "stab",
		"Cerberus Triple Bite gains the stab side effect (horns stab, Nov 1 refinement)",
		str(cer_attacks[0]))

	print("APEX: capstone data (Crown of the Deep, actions not menus)")
	_check(str(AB.CAPSTONE["name"]) == "Crown of the Deep", "capstone is the Crown of the Deep")
	_check(int(AB.CAPSTONE["pieces_required"]) == 16, "capstone needs 16 pieces")
	_check(int(AB.CAPSTONE["pieces_in_wave4"]) == 16, "all 16 pieces wired (Wave 4's 15 + Cerberus Nov 1)")
	_check("ACTIONS" in str(AB.CAPSTONE["expression_rule"]).to_upper(),
		"capstone good/evil expressed through player actions")
	_check("NOT IMPLEMENTED" in str(AB.CAPSTONE["set_bonus"]),
		"no set bonus implemented beyond data")
	_check("NO world-destroying endgame" in str(AB.CAPSTONE["endgame_note"]),
		"no world-destroying endgame")

	if _failures == 0:
		print("APEX_BOSSES: ALL PASS")
	else:
		printerr("APEX_BOSSES: %d FAILURES" % _failures)
	quit(_failures)
