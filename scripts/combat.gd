class_name Combat
extends RefCounted
## Combat math helpers (pure functions — easy to unit test).


## Damage = max(1, atk - def * 0.8) with ±10% variance, 10% crit for x2
## by default. crit_chance / crit_mult are parameters (defaults = today's
## behavior) so a future crit-overflow rule can pass its own values in;
## NO overflow math lives here yet — the conversion rate and the
## crit-chance source are both undecided director calls (systems step,
## Nov 4, 2026). Returns { "amount": float, "crit": bool }.
static func calc_damage(atk: float, dfn: float, rng: RandomNumberGenerator, crit_chance: float = 0.10, crit_mult: float = 2.0) -> Dictionary:
	var variance := rng.randf_range(0.9, 1.1)
	var amount := maxf(1.0, (atk - dfn * 0.8) * variance)
	var crit := rng.randf() < crit_chance
	if crit:
		amount *= crit_mult
	return {"amount": amount, "crit": crit}


## XP reward scales gently with enemy level so deep floors stay rewarding.
static func xp_for_level(enemy_level: int) -> float:
	return 8.0 * pow(float(maxi(enemy_level, 1)), 1.25)
