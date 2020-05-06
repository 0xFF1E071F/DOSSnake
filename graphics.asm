	.model small
	.386
	include Snake\const.inc
	.data
int_buffer db 6 dup(0)
saved_graphics_mode db 0
	
	.code
;======================================
; Procedure used to initialize graphics
;======================================
SetGraphics	proc	near
	mov	ah, INT10_SET_MODE
	mov	al, 13h ; 320x200 256 colors
	int	VIDEO_SERVICE

	mov	ah, INT10_SET_COLOR_PALETTE
	xor	bh, bh 
	mov	bl, COLOR_CYAN ; Background color
	int	VIDEO_SERVICE
	ret	
SetGraphics	endp

;=========================================
; Procedure used to save initial graphics
;=========================================
SaveGraphics	proc	near
	mov	ah, INT10_GET_MODE
	int	VIDEO_SERVICE
	mov	[saved_graphics_mode], al
SaveGraphics	endp

;======================================
; Procedure used to restore graphics
;======================================
RestoreGraphics	proc	near
	mov	ah, INT10_SET_MODE
	mov	al, [saved_graphics_mode]
	int	VIDEO_SERVICE
	ret
RestoreGraphics	endp

ClearScreen	proc	near
	push	bx
	push	dx

	xor	al, al
	xor	bx, bx
	mov	ah, INT10_SCROLL_UP
	xor	cx, cx
	mov	dl, 0040h
	mov	dh, 0040h
	int	VIDEO_SERVICE

	pop	dx
	pop	bx
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
	mov	dx, [esi].pos_y
	mov	ah, INT10_WRITE_PIXEL
	mov	bh, 0 ; Page number

	draw_loop:
		int	VIDEO_SERVICE ; Draw pixel
		inc	cx

		push	cx
		sub	cx, [esi].pos_x
		cmp	cx, CELL_SIZE
		pop	cx
		jnge	draw_loop

		mov	cx, [esi].pos_x
		inc	dx ; Switch to new line

		push	dx
		sub	dx, [esi].pos_y
		cmp	dx, CELL_SIZE
		pop	dx
		jnge	draw_loop
	
	pop	dx
	pop	cx
	pop	bx
	ret
DrawCell	endp

;=================================
; Procedure to draw a string
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

;=================================
; Procedure to draw a score
;
; Input: ax - score
;	bl - color
;	dh - row position
;   dl - column position
;=================================
DrawScore	proc	near
	push	bx
	push	dx
	xor	cx,cx
	lea	si, int_buffer
	
	select_loop:
		mov	dx, 0
		mov	bx, 10
		div	bx
		push	dx
		inc	cx
		cmp	ax, 0
		jz	to_str_loop
		jmp	select_loop
		
	to_str_loop:
		cmp	cx, 0
		jz	draw
		dec	cx
		pop	dx
		add	dl, '0'
		mov	[si], dl
		inc	si
		jmp	to_str_loop
		
	draw:
		pop	dx
		pop	bx
		lea	si, int_buffer
		call	DrawString
		ret
DrawScore	endp

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

public	SaveGraphics, SetGraphics, RestoreGraphics, DrawCell, DrawString, DrawScore, ClearScreen
end
