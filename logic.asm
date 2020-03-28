	.model small
	.386
	include Snake\const.inc
	include helpers\const.inc
	include helpers\macros.mac
	
	.code

;===========================
; Checks if some key pressed
;
; Output: ah - keycode
;===========================
GetchAsync	proc	near
		mov	ah, INT16_KEY_STATUS
		int	KEYBOARD_SERVICE
		jz exit_getch ; No key pressed

		mov	ah, INT16_READ_CHAR
		int 	KEYBOARD_SERVICE

		exit_getch:
			RET
GetchAsync	endp

;================================
; Handles all movements
;
; Input: esi - snake head adress
;	edx - Settings adress
;	ah - pressed char
;================================
HandleMovements	proc	near
	cmp	ah, 4Bh
	je	turn_left
	cmp	ah, 4Dh
	je	turn_right
	cmp	ah, 48h
	je	turn_up
	cmp	ah, 50h
	je	turn_down
	jmp	move

	turn_left:
		mov	[edx].snake_direction, 0
		jmp	move
	turn_right:
		mov	[edx].snake_direction, 1
		jmp	move
	turn_up:
		mov	[edx].snake_direction, 2
		jmp	move
	turn_down:
		mov	[edx].snake_direction, 3

	move:
		cmp	[edx].snake_direction, 0
		jl	exit_handle_mov
		je	@move_left
		cmp	[edx].snake_direction, 1
		je	@move_right
		cmp	[edx].snake_direction, 2
		je	@move_up
		jg	@move_down

		@move_left:
			sub	[esi].pos_x, VELOCITY_X
			jmp	exit_handle_mov
		@move_right:
			add	[esi].pos_x, VELOCITY_X
			jmp	exit_handle_mov
		@move_up:
			sub	[esi].pos_y, VELOCITY_Y
			jmp	exit_handle_mov
		@move_down:
			add	[esi].pos_y, VELOCITY_Y

	exit_handle_mov:
		ret
HandleMovements	endp

;==========================================
; Checks if head of a snake collided
;	with a wall, apple or snake body
;
; Input: esi - adress of snake head
;	edx - Settings instance
;==========================================
CheckCollision	proc	near
	cmp	[esi].pos_x, 0
	jl	collided
	cmp	[esi].pos_x, SCREEN_WIDTH - CELL_SIZE
	jg	collided
	cmp	[esi].pos_y, 0
	jl	collided
	cmp	[esi].pos_y, SCREEN_HEIGHT - CELL_SIZE
	jg	collided
	jmp	exit_check_collision

	collided:
		mov [edx].game_ended, 1

	exit_check_collision:
		ret
CheckCollision	endp

;=======================================================
;                Private procedures
;=======================================================
GenerateApple	proc	near
	ret
GenerateApple	endp

ShiftSnakeCells	proc	near
	ret
ShiftSnakeCells	endp


public GetchAsync, HandleMovements, CheckCollision
end
