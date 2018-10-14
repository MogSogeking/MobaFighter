extends KinematicBody2D

enum State {
	walk,
	startHit,
	activeHit,
	recoverHit,
}

export (int) var speed

var direction = Vector2()
var velocity = Vector2()
var state = State.walk
var framerate = 1.0/60.0

var startup = 0
var active = 0
var recover = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func processControls():
	if state == State.walk:
		if Input.is_action_pressed("up"):
			velocity.y -= speed
		if Input.is_action_pressed("right"):
			velocity.x += speed
		if Input.is_action_pressed("down"):
			velocity.y += speed
		if Input.is_action_pressed("left"):
			velocity.x -= speed
			
	if Input.is_action_just_pressed("action1"):
		if $actionTimer.is_stopped():
			state = State.startHit
			startup = 8
			active = 4
			recover = 8
			$actionTimer.wait_time = framerate * startup
			$actionTimer.start()
			$Sprite.modulate = Color(0, 1, 0)
			var targetPos = global_position * direction
			print(targetPos)
			$HitTween.interpolate_property(self, "transform:pos", global_position, targetPos, (startup+active+recover)*framerate, Tween.TRANS_QUINT, Tween.EASE_OUT)


func _physics_process(delta):
	direction = get_angle_to(get_global_mouse_position())
	processControls()
	move_and_slide(velocity)
	velocity = Vector2()

func _on_actionTimer_timeout():
	$actionTimer.stop()
	if state == State.startHit:
		$Sprite.modulate = Color(0, 0, 1)
		state = State.activeHit
		$actionTimer.wait_time = framerate * active
		$actionTimer.start()
	elif state == State.activeHit:
		$Sprite.modulate = Color(1, 0, 0)
		state = State.recoverHit
		$actionTimer.wait_time = framerate * recover
		$actionTimer.start()
	elif state == State.recoverHit:
		$Sprite.modulate = Color(1, 1, 1)
		state = State.walk