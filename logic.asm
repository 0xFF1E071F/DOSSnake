	.model small
	.386
	include DOSSnake\const.inc
	.data
random_seed dw 0

	.code
;===========================
; Checks if some key pressed
;
; Output: ah - keycode
;===========================
GetchAsync	proc	near
	mov	ah, INT16_KEY_STATUS
	int	KEYBOARD_SERVICE
	jz	exit_getch ; No key pressed

	mov	ah, INT16_READ_CHAR
	int	KEYBOARD_SERVICE

	exit_getch:
		ret
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
		cmp	[edx].snake_direction, 1 ; If going right
		je	move
		mov	[edx].snake_direction, 0
		jmp	move
	turn_right:
		cmp	[edx].snake_direction, 0 ; If going left
		je	move
		mov	[edx].snake_direction, 1
		jmp	move
	turn_up:
		cmp	[edx].snake_direction, 3 ; If going down
		je	move
		mov	[edx].snake_direction, 2
		jmp	move
	turn_down:
		cmp	[edx].snake_direction, 2 ; If going up
		je	move
		mov	[edx].snake_direction, 3

	move:
		cmp	[edx].snake_direction, -1
		je	exit_handle_mov
		
		call ShiftSnakeCells
		inc	word ptr [ebx]
		cmp	[edx].snake_direction, 0
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
;	edi - apple adress
;	ebx - snake tail
;	edx - Settings instance
;==========================================
CheckCollisions	proc	near
	push	edx
	cmp	[esi].pos_x, 0
	jl	collided_wall
	cmp	[esi].pos_x, SCREEN_WIDTH - CELL_SIZE
	jg	collided_wall
	cmp	[esi].pos_y, 0
	jl	collided_wall
	cmp	[esi].pos_y, SCREEN_HEIGHT - CELL_SIZE
	jg	collided_wall
	
	mov	ax, [esi].pos_x
	sub	ax, [edi].pos_x
	cwd        ;
	xor	ax, dx ; abs(ax)
	sub	ax, dx ; 
	cmp	ax, CELL_SIZE
	jge	check_body_collision

	mov	ax, [esi].pos_y
	sub	ax, [edi].pos_y
	cwd        ;
	xor	ax, dx ; abs(ax)
	sub	ax, dx ; 
	
	cmp ax, CELL_SIZE - 1
	jl	collided_food
	jmp	check_body_collision

	check_body_collision:
		push	edi
		mov	edi, esi
		call	CheckSnakeCollision
		cmp	ax, 1
		je	collided_itself
		pop	edi
		jmp	exit_check_collision

	collided_itself:
		pop	edi
	collided_wall:
		pop	edx
		mov	[edx].game_ended, 1
		push	edx
		jmp	exit_check_collision
	collided_food:
		pop	edx
		inc	[edx].score
		push	edx
		inc	word ptr [ebx]
		call	GenerateApple
		jmp	exit_check_collision

	exit_check_collision:
		pop	edx
		ret
CheckCollisions	endp

;==========================================
; Resets all game data
;
; Input: esi - adress of snake head
;	edi - apple adress
;	ebx - snake tail
;	edx - Settings instance
;==========================================
ResetAllData	proc	near
	; Settings
	mov	[edx].score, 0
	mov	[edx].game_ended, 0
	mov	[edx].snake_direction, -1

	; Apple
	mov	[edi].pos_x, 10
	mov	[edi].pos_y, 10

	;Snake tail
	mov	[ebx], 2 

	snake_clear_loop:
		cmp	[esi].pos_x, 0
		je	exit_reset

		mov	[esi].pos_x, 0
		mov	[esi].pos_y, 0
		add	esi, (type Cell)
		jmp	snake_clear_loop

	exit_reset:
		ret
ResetAllData	endp

InitializeRandom	proc	near
	mov	Ah, 00h ; Interrupt to get system timer
	int	1Ah
	mov	[random_seed], dx
	ret
InitializeRandom	endp

;=======================================================
;                Private procedures
;=======================================================

;==========================================
; Checks if snake body collides with a cell
;
; Input: esi - snake head adress
;	edi - cell adress to check collider
;	ebx - snake tail adress
; Output: ax - 1 if collides, otherwise 0
;=========================================
CheckSnakeCollision	proc	near
	push	esi
	push	edx
	mov	cx, [ebx]

	check_loop:
		add	esi, (type Cell)
		dec	cx

		cmp	cx, 0
		jz	not_collided

		mov	ax, [esi].pos_x
		sub	ax, [edi].pos_x
		cwd        ;
		xor	ax, dx ; abs(ax)
		sub	ax, dx ; 
		cmp	ax, CELL_SIZE
		jge	check_loop

		mov	ax, [esi].pos_y
		sub	ax, [edi].pos_y
		cwd        ;
		xor	ax, dx ; abs(ax)
		sub	ax, dx ; 
		
		cmp	ax, CELL_SIZE - 1
		jl	collided
		jg	check_loop

	collided:
		mov	ax, 1
		jmp	exit_check_snake_collision
	not_collided:
		xor	ax, ax
	exit_check_snake_collision:
		pop	edx
		pop	esi
		ret

CheckSnakeCollision	endp

Randomize	proc	near
	push	cx
	
	mov	ax, 25173          
	mul	word ptr [random_seed]
	add	ax, 13849          
	mov	[random_seed], ax 

	pop	cx
	xor	dx, dx   
	div	cx  
	
	ret
Randomize	endp

GenerateApple	proc	near
	push	ax	
	push	bx
	push	edx

	randomize_loop:
		mov	cx, SCREEN_WIDTH - CELL_SIZE
		call	Randomize
		mov	bx, dx
		mov	cx, SCREEN_HEIGHT - CELL_SIZE
		call	Randomize

		mov	[edi].pos_x, bx
		mov	[edi].pos_y, dx

		call	CheckSnakeCollision
		cmp	ax, 1
		je randomize_loop

	pop	edx
	pop	bx
	pop	ax
	ret
GenerateApple	endp

ShiftSnakeCells	proc	near
	push	eax
	push	edi

	mov	edi,	esi
	xor	eax, eax
	mov	ax, [ebx]
	imul	ax, (type Cell)
	add	edi,	eax

	shift_loop:
		mov	ax, [edi-(type Cell)].pos_x
		mov	[edi].pos_x, ax
		mov	ax, [edi-(type Cell)].pos_y
		mov	[edi].pos_y, ax

		sub	edi, (type Cell)
		cmp	edi, esi
		jg	shift_loop

	dec	word ptr [ebx] ; Removing tail
	pop	edi
	pop	eax
	ret
ShiftSnakeCells	endp


public GetchAsync, HandleMovements, CheckCollisions, InitializeRandom, ResetAllData
end
