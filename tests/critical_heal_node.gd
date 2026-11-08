extends Node
## Focused test for the critical-HP depth-shop patch-up (v0.7.0):
##  1. HP <= 25% in idle mode triggers the brain's critical retreat flag.
##  2. The retreating brain paths toward the stairs ("retreat" target).
##  3. _buy_shop_heal: affordable -> +50% max HP, gold deducted; poor ->
##     no purchase, gold untouched; full HP -> no-op.
##  4. The floor-clear shop offers the Field dressing button (shop mode only).
## Run: godot --headless --path . tests/critical_heal_scene.tscn
## Exits 0 on success, 1 on any failure.

const ShopScript := preload("res://scripts/shop.gd")

var _failures := 0
var _main: Node = null


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	# Fresh boot: a stale hub save (e.g. death_sort's town save) would
	# restore with no live floor and crash the brain-step assertions.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.idle_mode = true
	_test_retreat_trigger()
	_test_buy_heal()
	_test_shop_button()
	if _failures == 0:
		print("CRITHEAL: ALL PASS")
	else:
		printerr("CRITHEAL: %d FAILURES" % _failures)
	get_tree().quit(_failures)


## Dropping to <=25% HP flips the brain into critical retreat, and the next
## brain step paths toward the stairs instead of sweeping rooms.
func _test_retreat_trigger() -> void:
	GameState.max_hp = 100.0
	GameState.hp = 20.0
	GameState.health_potions = 0  # no potion to drink — retreat is the backup
	_main.set("_critical_retreat", false)
	_main._auto_step()
	_check(bool(_main.get("_critical_retreat")), "retreat flag set at 20% HP")
	_check(str(_main.get("debug_last_target")) == "retreat",
		"retreating brain targets the stairs",
		"got %s" % str(_main.get("debug_last_target")))
	# Healthy again: no retreat trigger.
	GameState.hp = 90.0
	_main.set("_critical_retreat", false)
	_main._auto_step()
	_check(not bool(_main.get("_critical_retreat")), "no retreat at 90% HP")


## The patch-up transaction itself: price, heal amount, affordability.
func _test_buy_heal() -> void:
	var price := ShopScript.field_heal_price(GameState.depth)
	_check(price > 0.0, "heal price positive (%s G)" % str(price))
	# Affordable: HP rises by exactly 50% of max, gold drops by price.
	GameState.max_hp = 100.0
	GameState.hp = 20.0
	GameState.gold = price + 50.0
	var bought: bool = _main._buy_shop_heal(true)
	_check(bought, "auto-buy succeeds when affordable")
	_check(is_equal_approx(GameState.hp, 70.0),
		"heal restores 50%% of max HP", "hp=%s" % str(GameState.hp))
	_check(is_equal_approx(GameState.gold, 50.0),
		"gold deducted exactly", "gold=%s" % str(GameState.gold))
	# Broke: no purchase, gold untouched, HP untouched.
	GameState.hp = 20.0
	GameState.gold = price - 1.0
	bought = _main._buy_shop_heal(true)
	_check(not bought, "auto-buy refused when unaffordable")
	_check(is_equal_approx(GameState.hp, 20.0), "no heal when broke")
	_check(is_equal_approx(GameState.gold, price - 1.0), "gold untouched when broke")
	# Full HP: no-op, no charge.
	GameState.hp = 100.0
	GameState.gold = 10000.0
	bought = _main._buy_shop_heal(false)
	_check(not bought, "no purchase at full HP")
	_check(is_equal_approx(GameState.gold, 10000.0), "no charge at full HP")


## The floor-clear shop lists Field dressing; the death shop does not.
func _test_shop_button() -> void:
	var hud: Node = _main.get("hud")
	GameState.hp = 50.0
	GameState.max_hp = 100.0
	GameState.gold = 100000.0
	hud.show_shop("Test resupply")
	await get_tree().process_frame
	var found := false
	for b in hud.get("_shop_items_list").get_children():
		if b is Button and str(b.text).begins_with("Field dressing"):
			found = true
			_check(not b.disabled, "heal button enabled when affordable+hurt")
	_check(found, "floor-clear shop offers Field dressing")
	# Buying through the real button heals and charges.
	var hp0 := GameState.hp
	var gold0 := GameState.gold
	var price := ShopScript.field_heal_price(GameState.depth)
	hud._on_shop_buy_heal()
	_check(is_equal_approx(GameState.hp, hp0 + 50.0), "button heals 50% max")
	_check(GameState.gold < gold0, "button charges gold")
	hud.hide_shop()
