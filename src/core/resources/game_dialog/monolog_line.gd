@tool
extends MillieMonolog
class_name MillieMonologLine

enum MillieEmotion {
	NEUTRAL = 0,
	GREET = 1,
	EXCITED = 2,
	NERVOUS = 3,
	EXPLAIN = 4,
	SERIOUS = 5,
	POGO_FACE = 6
}

## List of emotions expressed while the monolog line is spoken.
## Each entry corresponds to an emotion state used during the line.
@export var monolog_emotion: Millie.Expressions = Millie.Expressions.NEUTRAL
@export var monolog_eyes: Millie.Eyes = Millie.Eyes.REGULAR
## The dialogue line spoken during this monolog entry.
@export_multiline var monolog_line: String
