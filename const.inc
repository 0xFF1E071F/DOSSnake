;*************************************************
;            Game constants and templates        *
;*************************************************

;=================================================
;                    Constants
;=================================================
SCREEN_WIDTH      = 320
SCREEN_HEIGHT     = 200
SCREEN_RESOLUTION = SCREEN_WIDTH * SCREEN_HEIGHT

CELL_SIZE  = 10 ; Width and height of one draw cell
VELOCITY_X = 10
VELOCITY_Y = 10 

COLOR_CYAN  = 00000011b
COLOR_RED   = 00000100b
COLOR_GREEN = 00001010b
COLOR_PINK  = 00111110b

VIDEO_SERVICE           = 10h
INT10_SET_MODE          = 00h
INT10_SCROLL_UP         = 06h
INT10_SET_COLOR_PALETTE = 0Bh
INT10_WRITE_PIXEL       = 0Ch
INT10_WRITE_STRING      = 13h

KEYBOARD_SERVICE        = 16h
INT16_READ_CHAR         = 00h
INT16_KEY_STATUS        = 01h

SYSTEM_SERVICE          = 21h
INT21_GET_SYSTEM_TIME   = 2Ch
INT21_EXIT_PROGRAM      = 4Ch


;=================================================
;                    Templates
;=================================================

Cell   struc
    pos_x   dw  0
    pos_y   dw  0
Cell   ends

Settings    struc
    score   dw  0
    game_ended db 0
    ; -1 - None, 0 - left, 1 - right, 2 - top, 3 - bottom
    snake_direction db -1 
Settings    ends