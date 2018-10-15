extends KinematicBody2D

enum State {
	walk,
	startHit,
	activeHit,
	recoverHit,
}

export (int) var speed

signal staminaChanged
signal lifeChanged

var direction = Vector2()
var velocity = Vector2()
var state = State.walk
var framerate = 1.0/60.0

var startup = 0
var active = 0
var recover = 0
var stamina = 100

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
		if state != State.startHit && stamina > 10:
			stamina -= 10
			state = State.startHit
			startup = 6
			active = 4
			recover = 8
			attack()
	
	if Input.is_action_just_pressed("action2"):
		if state != State.startHit && stamina > 20:
			stamina -= 20
			state = State.startHit
			startup = 9
			active = 6
			recover = 12
			attack()

func attack():
	$HitTween.stop(self)
	$ActionTimer.wait_time = framerate * startup
	$ActionTimer.start()
	$Sprite.modulate = Color(0, 1, 0)
	var targetPos = global_position + (direction * 20)
	var tweenDuration = framerate * (startup + active)
	$HitTween.interpolate_property(self, 'position', global_position, targetPos, tweenDuration, Tween.TRANS_BACK, Tween.EASE_OUT)
	$HitTween.start()
	print(global_position)

func _physics_process(delta):
	direction = (get_global_mouse_position() - global_position).normalized() 
	processControls()
	move_and_slide(velocity)
	velocity = Vector2()

func _on_ActionTimer_timeout():
	$ActionTimer.stop()
	if state == State.startHit:
		$Sprite.modulate = Color(0, 0, 1)
		state = State.activeHit
		$ActionTimer.wait_time = framerate * active
		$ActionTimer.start()
	elif state == State.activeHit:
		$Sprite.modulate = Color(1, 0, 0)
		state = State.recoverHit
		$ActionTimer.wait_time = framerate * recover
		$ActionTimer.start()
	elif state == State.recoverHit:
		$Sprite.modulate = Color(1, 1, 1)
		state = State.walk


func _on_StaminaTimer_timeout():
	if stamina < 100:
		stamina += 1
