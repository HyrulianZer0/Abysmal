extends Node
## Headless test: guild-hall unlock chain (Phase 2).
## Data model, buy/upgrade through all 4 stages, denial cases, death
## persistence, save/load round-trip, and stub-view distinguishability.
## Run: godot --headless --path . tests/guild_hall_scene.tscn
## Exits 0 on success, nonzero = failure count.

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _labels_under(n: Node) -> Array:
	var out: Array = []
	var stack: Array = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is Label3D:
			out.append(cur)
		stack.append_array(cur.get_children())
	return out


func _label_texts(view: GuildHallView) -> Array:
	var out: Array = []
	for l in _labels_under(view):
		out.append(str(l.text))
	return out


func _ready() -> void:
	print("GUILDHALL: starting")
	var gs = GameState
	_test_data_model()
	_test_buy_through(gs)
	_test_denials(gs)
	_test_death_persistence(gs)
	_test_save_roundtrip(gs)
	_test_view_distinguishability()
	_test_transition()
	if _failures == 0:
		print("GUILDHALL: ALL PASS")
	else:
		printerr("GUILDHALL: %d FAILURES" % _failures)
	get_tree().quit(_failures)


func _test_data_model() -> void:
	print("GUILDHALL: data model")
	_check(GuildHall.STAGE_COUNT == 4, "4 stages")
	var ids := {}
	var last_price := 0.0
	var last_req := 0
	var last_area := 0.0
	for i in range(1, 5):
		var s := GuildHall.stage(i)
		_check(not s.is_empty(), "stage %d exists" % i)
		_check(not ids.has(str(s["id"])), "stage %d id unique" % i)
		ids[str(s["id"])] = true
		_check(GuildHall.stage_by_id(str(s["id"]))["id"] == s["id"], "by_id round-trips")
		_check(GuildHall.stage_index(str(s["id"])) == i, "stage_index round-trips")
		var price := float(s["price"])
		_check(price > last_price, "stage %d price rises" % i, "%f" % price)
		last_price = price
		var req := int(s["depth_req"])
		_check(req >= last_req, "stage %d depth req non-decreasing" % i)
		last_req = req
		var fp: Vector2 = s["footprint"]
		var area := fp.x * fp.y
		_check(area > last_area, "stage %d footprint grows" % i, "%s" % str(fp))
		last_area = area
	_check(GuildHall.stage(0).is_empty(), "stage 0 invalid")
	_check(GuildHall.stage(5).is_empty(), "stage 5 invalid")
	var fc := GuildHall.format_cost(1)
	_check("gold" in fc, "format_cost mentions gold", fc)
	var fc2 := GuildHall.format_cost(2)
	_check("depth 10" in fc2, "format_cost shows depth req", fc2)


func _test_buy_through(gs) -> void:
	print("GUILDHALL: buy through all stages")
	gs.guild_stage = 0
	gs.max_depth = 99
	gs.gold = 1_000_000.0
	var spent := 0.0
	for i in range(1, 5):
		var price := GuildHall.stage_price(i)
		_check(gs.buy_guild_stage(), "buy stage %d" % i)
		_check(gs.guild_stage == i, "guild_stage == %d" % i)
		spent += price
		_check(is_equal_approx(gs.gold, 1_000_000.0 - spent),
			"gold deducted for stage %d" % i, "gold=%f" % gs.gold)
	_check(gs.guild_stage_info()["id"] == "hq", "stage 4 info is HQ")
	_check(not gs.buy_guild_stage(), "no stage 5")


func _test_denials(gs) -> void:
	print("GUILDHALL: denial cases")
	gs.guild_stage = 0
	gs.max_depth = 99
	gs.gold = GuildHall.stage_price(1) - 1.0
	_check(not gs.buy_guild_stage(), "insufficient gold denied")
	_check(gs.guild_stage == 0, "stage unchanged when broke")
	_check(is_equal_approx(gs.gold, GuildHall.stage_price(1) - 1.0), "gold untouched when denied")
	# Depth requirement.
	gs.gold = 1_000_000.0
	gs.max_depth = GuildHall.stage_depth_req(2) - 1
	gs.guild_stage = 1
	_check(not gs.buy_guild_stage(), "depth req denied")
	_check(gs.guild_stage == 1, "stage unchanged on depth denial")
	gs.max_depth = GuildHall.stage_depth_req(2)
	_check(gs.buy_guild_stage(), "depth req met -> buy succeeds")
	# Sequential-only rules at the data layer.
	var skip := GuildHall.can_purchase(3, 1e9, 99, 1)
	_check(not bool(skip["ok"]) and "first" in str(skip["reason"]), "no skipping stages")
	var owned := GuildHall.can_purchase(1, 1e9, 99, 1)
	_check(not bool(owned["ok"]), "re-buy of owned stage denied")
	var beyond := GuildHall.can_purchase(5, 1e9, 99, 4)
	_check(not bool(beyond["ok"]), "beyond HQ denied")


func _test_death_persistence(gs) -> void:
	print("GUILDHALL: death persistence")
	gs.guild_stage = 3
	gs.max_depth = 25
	gs.gold = 5000.0
	gs.skills = {"attack": 2}
	gs.charms = {"blood_vial": 1}
	gs.reset_run()  # simulated death -> new run
	_check(gs.guild_stage == 3, "guild_stage survives death")
	_check(gs.max_depth == 25, "max_depth survives death")
	_check(gs.gold == 5000.0, "gold untouched by reset")
	_check(int(gs.skills.get("attack", 0)) == 2, "skills untouched by reset")


func _test_save_roundtrip(gs) -> void:
	print("GUILDHALL: save/load round-trip")
	gs.guild_stage = 2
	gs.max_depth = 17
	gs.gold = 12345.0
	gs.skills = {"luck": 5}
	var d: Dictionary = gs.to_dict()
	_check(int(d.get("guild_stage", -1)) == 2, "guild_stage in save dict")
	_check(int(d.get("max_depth", -1)) == 17, "max_depth in save dict")
	# Wipe and restore (what main.gd's load path does via from_dict).
	gs.guild_stage = 0
	gs.max_depth = 1
	gs.gold = 0.0
	gs.skills = {}
	gs.from_dict(d)
	_check(gs.guild_stage == 2, "guild_stage restored")
	_check(gs.max_depth == 17, "max_depth restored")
	_check(is_equal_approx(gs.gold, 12345.0), "gold restored")
	_check(int(gs.skills.get("luck", 0)) == 5, "skills restored alongside guild")
	# Corrupt/clamped input can't break the chain.
	gs.from_dict({"guild_stage": 99, "max_depth": -5, "depth": 3})
	_check(gs.guild_stage == 4, "guild_stage clamped to HQ")
	_check(gs.max_depth == 3, "max_depth sane after bad data")


func _test_view_distinguishability() -> void:
	print("GUILDHALL: stage views distinguishable")
	var views: Array = []
	for i in range(0, 5):
		var v := GuildHallView.new()
		add_child(v)
		v.set_stage(i)
		views.append(v)
	# Stage 0: empty lot with FOR SALE sign.
	_check("FOR SALE" in _label_texts(views[0]), "stage 0 shows FOR SALE")
	var last_area := 0.0
	var colors := {}
	var prev_child_count := 0
	for i in range(1, 5):
		var s := GuildHall.stage(i)
		var texts := _label_texts(views[i])
		_check(str(s["label"]) in texts, "stage %d label visible" % i, str(texts))
		var fp: Vector2 = s["footprint"]
		var area := fp.x * fp.y
		_check(area > last_area, "stage %d view footprint grows" % i)
		last_area = area
		var walls: Color = s["walls"]
		_check(not colors.has(walls.to_html()), "stage %d wall color unique" % i)
		colors[walls.to_html()] = true
		var cc: int = views[i]._root.get_child_count()
		_check(cc > prev_child_count, "stage %d has more geometry than prior" % i,
			"%d vs %d" % [cc, prev_child_count])
		prev_child_count = cc
	# Prop sets differ across stages (the vocabulary each stage uses).
	_check("tilted_chimney" in (GuildHall.stage(1)["props"] as Array),
		"tavern has the leaning chimney")
	_check("tilted_chimney" not in (GuildHall.stage(2)["props"] as Array),
		"guild hall has no leaning chimney")
	_check("towers" in (GuildHall.stage(4)["props"] as Array), "HQ has towers")
	_check("towers" not in (GuildHall.stage(1)["props"] as Array),
		"tavern has no towers")
	for v in views:
		v.queue_free()


func _test_transition() -> void:
	print("GUILDHALL: stage transition")
	var v := GuildHallView.new()
	add_child(v)
	var seen: Array = []
	v.stage_shown.connect(func(idx: int) -> void: seen.append(idx))
	v.set_stage(1)
	_check(v.stage == 1, "view at stage 1")
	_check("RUN-DOWN TAVERN" in _label_texts(v), "tavern label after set")
	v.set_stage(4)  # the transition: old stage fully replaced
	_check(v.stage == 4, "view at stage 4")
	var texts := _label_texts(v)
	_check("ADVENTURERS' GUILD HQ" in texts, "HQ label after transition", str(texts))
	_check(not ("RUN-DOWN TAVERN" in texts), "old stage label gone")
	_check(seen == [1, 4], "stage_shown emitted per transition", str(seen))
	v.queue_free()
