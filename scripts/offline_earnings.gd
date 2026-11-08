class_name OfflineEarnings
extends RefCounted
## Offline-earnings measurement ("While You Were Away…").
##
## Live play feeds kill timestamps + awarded gold into a rolling 30-minute
## window. At save time the medians (kills/min, gold/kill over per-minute
## buckets) are snapshotted into the save; at load time the pure formula
## below turns time-away into gold. James's Oct 10 call: FULL speed, NO cap.
## Depth is HELD while away, the hero never dies while away, and backward
## clock jumps credit zero with no punishment. The wall clock is trusted for
## the save/load delta and nothing else.

const WINDOW_SEC := 1800.0           # rolling 30-minute measurement window
const BUCKET_SEC := 60.0             # medians are taken over per-minute buckets
const BUCKET_COUNT := 30
const DEFAULT_KILLS_PER_MIN := 4.0   # paper's conservative depth-1 fallback
const DEFAULT_GOLD_PER_KILL := 5.0   # small safe default — never a crash

var _kill_times: Array[float] = []
var _gold_events: Array = []         # Array of Vector2(t_seconds, amount)


## Monotonic in-session clock for the measurement window. The save/load
## delta uses the wall clock instead (Android kills background processes,
## so there is no cross-session monotonic counter).
static func now_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


func record_kill(t: float) -> void:
	_kill_times.append(t)
	_prune(t)


func record_gold(amount: float, t: float) -> void:
	if amount <= 0.0:
		return
	_gold_events.append(Vector2(t, amount))
	_prune(t)


func clear() -> void:
	_kill_times.clear()
	_gold_events.clear()


func has_data(t: float) -> bool:
	_prune(t)
	return not _kill_times.is_empty()


func _prune(t: float) -> void:
	# Times are appended in non-decreasing order, so front-pruning is valid.
	var cutoff := t - WINDOW_SEC
	while not _kill_times.is_empty() and _kill_times[0] < cutoff:
		_kill_times.pop_front()
	while not _gold_events.is_empty() and (_gold_events[0] as Vector2).x < cutoff:
		_gold_events.pop_front()


## Bucket index (0 = newest) for an event time, or -1 if outside the window.
func _bucket_of(t: float, event_t: float) -> int:
	var age := t - event_t
	if age < 0.0:
		return -1
	var b := int(age / BUCKET_SEC)
	return b if b < BUCKET_COUNT else -1


## Median kills/min across active (non-zero) per-minute buckets. Sparse
## data (< 3 active buckets) falls back to the mean over the observed span.
func kills_per_min(t: float) -> float:
	_prune(t)
	if _kill_times.is_empty():
		return DEFAULT_KILLS_PER_MIN
	var buckets: Array[int] = []
	buckets.resize(BUCKET_COUNT)
	buckets.fill(0)
	for kt in _kill_times:
		var b := _bucket_of(t, kt)
		if b >= 0:
			buckets[b] += 1
	var active: Array = []
	for c in buckets:
		if c > 0:
			active.append(c)
	if active.size() >= 3:
		return _median(active)
	# Sparse: mean rate over the actual observed span (min 1 second).
	var span_min := maxf((t - _kill_times[0]) / 60.0, 1.0 / 60.0)
	return float(_kill_times.size()) / span_min


## Median gold/kill across per-minute buckets with kills. Sparse data falls
## back to total gold / total kills; no kills at all -> safe default.
func gold_per_kill(t: float) -> float:
	_prune(t)
	if _kill_times.is_empty():
		return DEFAULT_GOLD_PER_KILL
	var kills: Array[int] = []
	var golds: Array[float] = []
	kills.resize(BUCKET_COUNT)
	kills.fill(0)
	golds.resize(BUCKET_COUNT)
	golds.fill(0.0)
	for kt in _kill_times:
		var b := _bucket_of(t, kt)
		if b >= 0:
			kills[b] += 1
	for ev in _gold_events:
		var v := ev as Vector2
		var b2 := _bucket_of(t, v.x)
		if b2 >= 0:
			golds[b2] += v.y
	var avgs: Array = []
	var tot_k := 0
	var tot_g := 0.0
	for i in BUCKET_COUNT:
		tot_k += kills[i]
		tot_g += golds[i]
		if kills[i] > 0:
			avgs.append(golds[i] / float(kills[i]))
	if avgs.size() >= 3:
		return _median(avgs)
	if tot_k > 0:
		return tot_g / float(tot_k)
	return DEFAULT_GOLD_PER_KILL


static func _median(a: Array) -> float:
	var s := a.duplicate()
	s.sort()
	var n := s.size()
	if n % 2 == 1:
		return float(s[n / 2])
	return (float(s[n / 2 - 1]) + float(s[n / 2])) / 2.0


## What the save stores: the two medians plus whether any live data backed
## them (lets the loader tell "fresh/short session" from "measured").
func snapshot(t: float) -> Dictionary:
	return {
		"kills_per_min": kills_per_min(t),
		"gold_per_kill": gold_per_kill(t),
		"measured": has_data(t),
	}


## The earnings formula — pure math. FULL speed, NO cap (Oct 10 call).
## Non-positive time (backward clock jump) credits zero, never negative.
static func compute_earnings(time_away_min: float, kpm: float, gpk: float,
		gold_mult: float) -> float:
	if time_away_min <= 0.0:
		return 0.0
	return time_away_min * maxf(kpm, 0.0) * maxf(gpk, 0.0) * maxf(gold_mult, 0.0)
