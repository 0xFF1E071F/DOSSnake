	.model small
	.386
	.stack	200h
	include Snake\const.inc
	
	.data
MsgGameOver	db "Game Over", 0
MsgScore	db "Score: ", 0FFh
MsgRequest	db "Esc - exit game, Enter - retry", 0

GameTime	db 0
Snake	Cell SCREEN_RESOLUTION/(CELL_SIZE*CELL_SIZE) dup(<>)
SnakeTail	dw	2 ; Snake tail +1
Apple	Cell <10, 10>
RuntimeData	Settings <>

	.code
Begin	label	near
	mov	ax,	@data
	mov	ds,	ax
	mov es, ax ; Initializing segment to print messages

	call	SetGraphics
	call	InitializeRandom

	;Initializing snake position
	mov	[Snake].pos_x, SCREEN_WIDTH / 2 - CELL_SIZE
	mov	[Snake].pos_y, SCREEN_HEIGHT / 2 - CELL_SIZE
	mov	[Snake+(type Cell)].pos_x, SCREEN_WIDTH / 2
	mov	[Snake+(type Cell)].pos_y, SCREEN_HEIGHT / 2 - CELL_SIZE

	; Runs game in 100 FPS
	frame_loop: 
	;---------------------------------
	; Logic
		mov	ah, INT21_GET_SYSTEM_TIME
		int	SYSTEM_SERVICE 
		
		; dl = 1/100 second
		cmp	dl, [GameTime]
		je	frame_loop
		mov	[GameTime], dl

		lea	esi, Snake
		lea	edi, Apple
		lea	ebx, SnakeTail
		lea	edx, RuntimeData

		call	GetchAsync
		call	HandleMovements
		call	CheckCollisions

		cmp	[edx].game_ended, 1
		je	show_end_scren
	;--------------------------------
	;--------------------------------
	; Drawing
		call ClearScreen
		mov	al, COLOR_GREEN
		mov	cx, [SnakeTail]
		push	esi

		snake_draw_loop:
			call	DrawCell
			add	esi, (type Cell)
			loop	snake_draw_loop

		mov	al, COLOR_RED
		mov	esi, edi
		call DrawCell
		pop	esi
	;--------------------------------
		jmp	frame_loop

	show_end_scren:
		lea si, MsgGameOver
		mov	bl, COLOR_PINK
		mov	dh, SCREEN_HEIGHT / 2 - 15
		mov	dl, SCREEN_WIDTH / 2 - 9
		call	DrawString

		lea si, MsgScore
		add dh, 2
		call	DrawString

		push	dx
		mov ax, [edx].score
		add dl, 7
		call	DrawScore
		pop	dx

		lea si, MsgRequest
		mov	bl, COLOR_CYAN
		add dh, 4
		mov dl, SCREEN_WIDTH / 2 - 100
		call	DrawString

		getch_loop:
			mov	ah, INT16_READ_CHAR
			int	KEYBOARD_SERVICE
			cmp	al, 1Bh ; Escape
			je exit_game
			cmp al, 0Dh ; Enter
			je restart_game
			jmp	getch_loop

	restart_game:
		mov ax, es
		jmp Begin
	exit_game:
		call RestoreGraphics
		MOV	AH, INT21_EXIT_PROGRAM
		int	SYSTEM_SERVICE

	extrn	SetGraphics:	near
	extrn	RestoreGraphics:	near
	extrn	DrawCell:	near
	extrn	DrawString:	near
	extrn	DrawScore:	near
	extrn	ClearScreen:	near

	extrn	InitializeRandom:	near
	extrn	HandleMovements:	near
	extrn	CheckCollisions:	near
	extrn	GetchAsync:	near
end	Begin
