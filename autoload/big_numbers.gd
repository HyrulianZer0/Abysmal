extends Node
## BigNumbers autoload — formats huge values with K/M/B/T… suffixes,
## the "incremental infinity" feel for the idle-game number scaling.
## Usage: BigNumbers.format(1234567.0) -> "1.23M"

const SUFFIXES: PackedStringArray = [
	"", "K", "M", "B", "T",
	"Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc",
	"Vg", "UVg", "DVg", "TVg", "QaVg", "QiVg", "SxVg", "SpVg", "OcVg", "NoVg",
	"Tg",
]


## Format a number for HUD display. Handles ints, floats, negatives,
## and values far beyond the named suffix list (falls back to 1.23e45).
static func format(value: float) -> String:
	if is_nan(value) or is_inf(value):
		return "???"
	var negative := value < 0.0
	var v := absf(value)
	var prefix := "-" if negative else ""
	if v < 1000.0:
		# Small values: plain integer when whole, one decimal otherwise.
		if v == floor(v):
			return "%s%d" % [prefix, int(v)]
		return "%s%.1f" % [prefix, v]
	var tier := int(floor(log(v) / log(1000.0)))
	if tier < SUFFIXES.size():
		var scaled := v / pow(1000.0, float(tier))
		return "%s%.2f%s" % [prefix, scaled, SUFFIXES[tier]]
	# Beyond named suffixes: scientific notation, still incremental-friendly.
	var exp := int(floor(log(v) / log(10.0)))
	var mantissa := v / pow(10.0, float(exp))
	return "%s%.2fe%d" % [prefix, mantissa, exp]


## Parse back a formatted string (best effort, for save data later). TODO.
static func parse(_text: String) -> float:
	push_warning("BigNumbers.parse not implemented yet (Phase 2: save/load).")
	return 0.0
