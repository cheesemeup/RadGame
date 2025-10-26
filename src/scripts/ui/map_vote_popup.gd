extends Control

signal map_vote_response(accept: bool, timeout: bool)

@onready var map_vote_status_label = %map_vote_status_label
@onready var timer_label = %timer_label
@onready var button_yes = %button_yes
@onready var button_no = %button_no
@onready var join_box = %join_box
@onready var vote_results = %vote_results

@export var vote_duration: int = 10
var time_left: int = vote_duration
var timer: Timer

func _ready() -> void:
	button_yes.pressed.connect(func(): submit_vote(true, false))
	button_no.pressed.connect(func(): submit_vote(false, false))
	timer_label.text = str(time_left)

func initialize(player_name_str: String, map_name_str: String) -> void:
	map_vote_status_label.text = "Player %s wants to start %s" % [player_name_str, map_name_str]

	var player_is_requester = References.player_reference.name == player_name_str

	join_box.visible = not player_is_requester

	timer = Timer.new()
	timer.wait_time = 1
	timer.autostart = true
	timer.connect("timeout", func(): countDownOneSecond(not player_is_requester))
	add_child(timer)
	timer.start()

func countDownOneSecond(reject_after_timeout: bool) -> void:
	time_left -= 1
	timer_label.text = str(time_left)
	if time_left <= 0:
		# time is up, auto reject
		timer.stop()
		if reject_after_timeout:
			submit_vote(false, true)

func submit_vote(accept: bool, timeout: bool) -> void:
	map_vote_response.emit(accept, timeout)

func update_vote_result(results: Dictionary) -> void:
	for node in vote_results.get_children():
		vote_results.remove_child(node)
		node.queue_free()
	
	var players = results.keys()
	# keep the vote results in a consistent order
	players.sort()
	for player in players:
		var vote = results[player]
		var vote_str
		if vote.voted:
			vote_str = "Accepted" if vote["accepted"] else "Rejected"
		elif vote.timeout:
			vote_str = "Timed Out"
		else:
			vote_str = "No Vote"
		var label = Label.new()
		label.text = "Player %s: %s" % [vote.name, vote_str]
		vote_results.add_child(label)

func final_vote_result(accepted: bool) -> void:
	if timer and not timer.is_stopped():
		timer.stop()
	
	timer_label.visible = false
	join_box.visible = false

	if accepted:
		map_vote_status_label.text = "Map change accepted!"
	else:
		map_vote_status_label.text = "Map change rejected!"
	
	await get_tree().create_timer(5).timeout
	queue_free()
