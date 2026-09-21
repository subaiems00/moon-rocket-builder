extends Node
class_name FailureManager
## Listens to RocketController.failure_event and produces a single,
## consistent "outcome" the rest of the game consumes.
##
## Outcomes:
##   "success"            — clean landing, optional perfect-landing bonus
##   "fail_speed"         — too fast on touchdown
##   "fail_upside_down"   — landed upside down (comedic)
##   "fail_out_of_fuel"   — drifted back without thrust
##   "fail_spin"          — spinning out of control
##   "fail_crash"         — hit the ground from altitude
##
## Each outcome has:
##   - title (big UI text)
##   - subtitle (small UI text)
##   - sfx (audio name)
##   - score_multiplier (1.0 normal, 1.25 bonus for "perfect landings", 0.4 for failures)
##   - coin_bonus (extra coins on top of the base reward)
##   - camera_jolt (camera-shake strength to apply on results screen)

class Outcome:
	var kind: StringName
	var title: String
	var subtitle: String
	var sfx: String
	var score_multiplier: float
	var coin_bonus: int
	var camera_jolt: float

	func _init(_kind: StringName, _title: String, _subtitle: String,
			_sfx: String, _score_multiplier: float, _coin_bonus: int, _camera_jolt: float) -> void:
		kind = _kind
		title = _title
		subtitle = _subtitle
		sfx = _sfx
		score_multiplier = _score_multiplier
		coin_bonus = _coin_bonus
		camera_jolt = _camera_jolt


const _PERFECT_BOUNDRY := 18.0  # m/s — under this is a "clean" landing


static func classify(rocket_kind: StringName, rocket_details: Dictionary,
		touchdown_v: float, max_altitude_m: float, avg_stability: float) -> Outcome:
	var kind: StringName = rocket_kind
	match kind:
		&"upside_down":
			return _make(&"fail_upside_down",
				"UPSIDE DOWN!",
				"Try righting the rocket before touchdown.",
				"failure", 0.4, 30, 0.7)
		&"too_fast":
			return _make(&"fail_speed",
				"TOO FAST!",
				"Brake earlier — your legs can take so much.",
				"failure", 0.4, 20, 0.8)
		&"fumes_landing":
			return _make(&"success",
				"BARELY MADE IT!",
				"Coasted down on the last fumes. Impressive!",
				"victory", 1.25, 80, 0.5)
		&"out_of_fuel":
			return _make(&"fail_out_of_fuel",
				"OUT OF FUEL",
				"Add a bigger tank next time.",
				"failure", 0.4, 25, 0.4)
		&"spin_out":
			return _make(&"fail_spin",
				"SPIN-OUT!",
				"Use both boosters evenly.",
				"failure", 0.4, 20, 0.6)
		&"landed":
			# Touchdown kind: was it perfect?
			if touchdown_v < _PERFECT_BOUNDRY and avg_stability > 0.92:
				return _make(&"success",
					"PERFECT LANDING!",
					"Pinpoint touchdown. The Moon is jealous.",
					"victory", 1.5, 120, 0.6)
			return _make(&"success",
				"MOON LANDING!",
				"Welcome to the Moon, friend.",
				"victory", 1.0, 100, 0.4)
		&"crash":
			return _make(&"fail_crash",
				"CRASH LANDING!",
				"Maybe add more fins?",
				"failure", 0.4, 15, 0.8)
		_:
			return _make(&"fail_crash",
				"OOPS!",
				"Something unexpected happened.",
				"failure", 0.4, 10, 0.5)


static func _make(kind: StringName, title: String, subtitle: String, sfx: String,
		score_multiplier: float, coin_bonus: int, camera_jolt: float) -> Outcome:
	return Outcome.new(kind, title, subtitle, sfx, score_multiplier, coin_bonus, camera_jolt)
