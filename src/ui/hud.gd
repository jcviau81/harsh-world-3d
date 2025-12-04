extends CanvasLayer

var stamina: float = 100.0
var health: float = 100.0
var max_stamina: float = 100.0
var max_health: float = 100.0
var current_time: String = "14:30"
var current_season: String = "Spring"

# UI Node references
var stamina_bar: ProgressBar
var stamina_label: Label
var health_bar: ProgressBar
var health_label: Label
var time_label: Label
var season_label: Label

func _ready():
	# Create stamina container (HBox)
	var stamina_container = HBoxContainer.new()
	stamina_container.position = Vector2(10, 10)
	stamina_container.custom_minimum_size = Vector2(200, 30)
	add_child(stamina_container)

	# Stamina label
	stamina_label = Label.new()
	stamina_label.text = "Stamina:"
	stamina_label.add_theme_font_size_override("font_size", 14)
	stamina_container.add_child(stamina_label)

	# Stamina progress bar
	stamina_bar = ProgressBar.new()
	stamina_bar.min_value = 0
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina
	stamina_bar.custom_minimum_size = Vector2(100, 20)
	stamina_bar.show_percentage = false
	stamina_container.add_child(stamina_bar)

	# Create health container (HBox)
	var health_container = HBoxContainer.new()
	health_container.position = Vector2(10, 45)
	health_container.custom_minimum_size = Vector2(200, 30)
	add_child(health_container)

	# Health label
	health_label = Label.new()
	health_label.text = "Health:"
	health_label.add_theme_font_size_override("font_size", 14)
	health_container.add_child(health_label)

	# Health progress bar
	health_bar = ProgressBar.new()
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.custom_minimum_size = Vector2(100, 20)
	health_bar.show_percentage = false
	health_container.add_child(health_bar)

	# Create time display (top-right)
	time_label = Label.new()
	time_label.text = "Time: " + current_time
	time_label.position = Vector2(1000, 10)
	time_label.add_theme_font_size_override("font_size", 14)
	add_child(time_label)

	# Create season display (top-right)
	season_label = Label.new()
	season_label.text = "Season: " + current_season
	season_label.position = Vector2(1000, 35)
	season_label.add_theme_font_size_override("font_size", 14)
	add_child(season_label)

func update_stamina(value: float, max_value: float = 100.0) -> void:
	stamina = clamp(value, 0, max_value)
	max_stamina = max_value
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

func update_health(value: float, max_value: float = 100.0) -> void:
	health = clamp(value, 0, max_value)
	max_health = max_value
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func update_time(hours: int, minutes: int) -> void:
	current_time = "%02d:%02d" % [hours, minutes]
	if time_label:
		time_label.text = "Time: " + current_time

func update_season(season: String) -> void:
	current_season = season
	if season_label:
		season_label.text = "Season: " + current_season
