	.model small
	.386
	include Snake\const.inc
	
	.code
;======================================
; Procedure used to initialize graphics
;======================================
SetGraphics	proc	near
	mov	ah, INT10_SET_MODE
	mov	al,	12h ; 640x480 16 colors
	int	VIDEO_SERVICE

	mov	ah, INT10_SET_COLOR_PALETTE
	xor	bh,	bh 
	mov	bl, COLOR_CYAN ; Background color
	int	VIDEO_SERVICE
	ret	
SetGraphics	endp

ClearScreen	proc	near
	xor	al, al
	mov	ah, INT10_SCROLL_UP
	xor	cx, cx
	mov	dl, 0050h
	mov	dh, 0050h
	int	VIDEO_SERVICE
	ret
ClearScreen	endp

;==================================
; Procedure to draw one cell
;
; Input: esi - cell instance adress
;	al - color
;==================================
DrawCell	proc	near
	push	bx
	push	cx
	push	dx

	mov	cx, [esi].pos_x
	mov	dx,	[esi].pos_y
	mov	ah,	INT10_WRITE_PIXEL
	mov	bh, 0 ; Page number

	draw_loop:
		int	VIDEO_SERVICE ; Draw pixel
		inc	cx

		push	cx
		sub	cx, [esi].pos_x
		cmp	cx, CELL_SIZE
		pop	cx
		jng	draw_loop

		mov	cx, [esi].pos_x
		inc	dx ; Switch to new line

		push	dx
		sub	dx, [esi].pos_y
		cmp	dx, CELL_SIZE
		pop	dx
		jng	draw_loop
	
	pop	dx
	pop	cx
	pop	bx
	ret
DrawCell	endp

;=================================
; Procedure to draw string
;
; Input: si - string adress
;	bl - color
;	dh - row position
;   dl - column position
;=================================
DrawString	proc	near
	xor	bh, bh
	xor	al, al
	mov	bp, si
	mov	ah, INT10_WRITE_STRING
	call	StringLength
	
	int	VIDEO_SERVICE
	ret
DrawString	endp

;==================================
; Procedure to count string length
;
; Input: si - string adress
; Output: cx - length
;==================================
StringLength	proc	near
	xor	cx, cx
	count_loop:  
		cmp	byte ptr [si], 0
		je	exit_string_length
		cmp	byte ptr [si], 0FFh
		je	exit_string_length
		inc	cx
		inc	si
		jmp	count_loop
	exit_string_length:
		ret
StringLength 	endp

public	SetGraphics, DrawCell, DrawString, ClearScreen
end
