	.model small
	.386
	.stack	200h
	include Snake\const.inc
	
	.data
MsgGameOver	db "Game Over", 0
MsgScore	db "Score: ", 0FFh
MsgRequest	db "Press Esc to exit game, Enter to retry", 0

GameTime	db 0
Snake	Cell SCREEN_RESOLUTION/(CELL_SIZE*CELL_SIZE) dup(<>)
Apple	Cell <>
RuntimeData	Settings <>

	.code
Begin	label	near
	mov	ax,	@data
	mov	ds,	ax

	call   SetGraphics

	;lea	esi, Apple
	;lea edi, Snake
	;lea edx, RuntimeData

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

		lea	esi, Apple
		lea	edi, Snake
		lea	edx, RuntimeData

		call	GetchAsync
		call	HandleMovements
		call	CheckCollision

		cmp	[edx].game_ended, 1
		je	show_end_scren
	;--------------------------------
	;--------------------------------
	; Drawing
		call ClearScreen
		mov	al, COLOR_RED
		call	DrawCell
	;--------------------------------
		jmp	frame_loop

	show_end_scren:
		lea	si, MsgGameOver
		mov	bl, COLOR_RED
		mov	dh, 10
		mov	dl, 10
		call	DrawString

	exit_game:
		ret

	extrn	SetGraphics:	near
	extrn	DrawCell:	near
	extrn	DrawString:	near
	extrn	ClearScreen:	near

	extrn	HandleMovements:	near
	extrn	CheckCollision:	near
	extrn	GetchAsync:	near
end	Begin
