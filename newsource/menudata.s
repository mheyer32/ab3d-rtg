
MENUDATA:
	;0
				dc.l	ONEPLAYERMENU_TXT
				dc.l	ONEPLAYERMENU_OPTS

	;1
				dc.l	0
				dc.l	0

	;2
				dc.l	CREDITMENU_TXT
				dc.l	CREDITMENU_OPTS

	;3
				dc.l	0
				dc.l	0

	;4
				dc.l	MASTERPLAYERMENU_TXT
				dc.l	MASTERPLAYERMENU_OPTS

	;5
				dc.l	SLAVEPLAYERMENU_TXT
				dc.l	SLAVEPLAYERMENU_OPTS

	;6
				dc.l	CONTROL_TXT
				dc.l	CONTROL_OPTS

	;7
				dc.l	0
				dc.l	0

;--------------------------------------------------------------------------------

LevelNames:		dc.b	'      LEVEL  1 :          THE GATE      '
				dc.b	'      LEVEL  2 :       STORAGE BAY      '
				dc.b	'      LEVEL  3 :     SEWER NETWORK      '
				dc.b	'      LEVEL  4 :     THE COURTYARD      '
				dc.b	'      LEVEL  5 :      SYSTEM PURGE      '
				dc.b	'      LEVEL  6 :         THE MINES      '
				dc.b	'      LEVEL  7 :       THE FURNACE      '
				dc.b	'      LEVEL  8 :  TEST ARENA GAMMA      '
				dc.b	'      LEVEL  9 :      SURFACE ZONE      '
				dc.b	'      LEVEL 10 :     TRAINING AREA      '
				dc.b	'      LEVEL 11 :       ADMIN BLOCK      '
				dc.b	'      LEVEL 12 :           THE PIT      '
				dc.b	'      LEVEL 13 :            STRATA      '
				dc.b	'      LEVEL 14 :      REACTOR CORE      '
				dc.b	'      LEVEL 15 :     COOLING TOWER      '
				dc.b	'      LEVEL 16 :    COMMAND CENTRE      '

;--------------------------------------------------------------------------------

ONEPLAYERMENU_TXT:
;		 0123456789012345678901234567890123456789
				dc.b	'                                        ' ;1
				dc.b	'                                        ' ;2
				dc.b	'    ALIEN BREED 3D - SPECIAL EDITION    ' ;3
				dc.b	'                                        ' ;4
				dc.b	'                                        ' ;5
				dc.b	'                                        ' ;6
				dc.b	'                                        ' ;7
				dc.b	'                                        ' ;8
				dc.b	'                                        ' ;9
CURRENTLEVELLINE:
				dc.b	'           LEVEL 1 : THE GATE           ' ;0
				dc.b	'                                        ' ;1
				dc.b	'                1 PLAYER                ' ;2
				dc.b	'                                        ' ;3
				dc.b	'               PLAY  GAME               ' ;4
				dc.b	'                                        ' ;5
				dc.b	'            CONTROL  OPTIONS            ' ;6
				dc.b	'                                        ' ;7
				dc.b	'              GAME CREDITS              ' ;8
				dc.b	'                                        ' ;9
PASSWORDLINE:
				dc.b	'       PASSWORD: ................       ' ;0
				dc.b	'                                        ' ;1
				dc.b	'                                        ' ;2
				dc.b	'                  EXIT                  ' ;3
				dc.b	'                                        ' ;4
				dc.b	'                                        ' ;5

ONEPLAYERMENU_OPTS:
	;left, top, width
				dc.w	16,12,08,1
				dc.w	15,14,10,1
				dc.w	12,16,16,1
				dc.w	14,18,12,1
				dc.w	07,20,08,1
				dc.w	18,23,04,1
				dc.w	-1

;--------------------------------------------------------------------------------

MASTERPLAYERMENU_TXT:
;                          0123456789012345678901234567890123456789
				dc.b	'                                        ' ;1
				dc.b	'                                        ' ;2
				dc.b	'                                        ' ;3
				dc.b	'    ALIEN BREED 3D - SPECIAL EDITION    ' ;4
				dc.b	'                                        ' ;5
				dc.b	'                                        ' ;6
				dc.b	'                                        ' ;7
				dc.b	'                                        ' ;8
				dc.b	'                                        ' ;9
				dc.b	'                                        ' ;0
				dc.b	'                                        ' ;1
				dc.b	'            2 PLAYER  MASTER            ' ;2
				dc.b	'                                        ' ;3
CURRENTLEVELLINEM:
				dc.b	'           LEVEL 1 : THE GATE           ' ;4
				dc.b	'                                        ' ;5
				dc.b	'               PLAY  GAME               ' ;6
				dc.b	'                                        ' ;7
				dc.b	'            CONTROL  OPTIONS            ' ;8
				dc.b	'                                        ' ;9
				dc.b	'                                        ' ;0
				dc.b	'                  EXIT                  ' ;1
				dc.b	'                                        ' ;2
				dc.b	'                                        ' ;3
				dc.b	'                                        ' ;4
				dc.b	'                                        ' ;5

MASTERPLAYERMENU_OPTS:
	;left, top, width
				dc.w	12,12,16,1
				dc.w	07,14,26,1
				dc.w	15,16,10,1
				dc.w	12,18,16,1
				dc.w	18,21,4,1
				dc.w	-1

;--------------------------------------------------------------------------------

SLAVEPLAYERMENU_TXT:
;      0123456789012345678901234567890123456789
				dc.b	'                                        ' ;1
				dc.b	'                                        ' ;2
				dc.b	'                                        ' ;3
				dc.b	'    ALIEN BREED 3D - SPECIAL EDITION    ' ;4
				dc.b	'                                        ' ;5
				dc.b	'                                        ' ;6
				dc.b	'                                        ' ;7
				dc.b	'                                        ' ;8
				dc.b	'                                        ' ;9
				dc.b	'                                        ' ;0
				dc.b	'                                        ' ;1
				dc.b	'             2 PLAYER SLAVE             ' ;2
				dc.b	'                                        ' ;3
				dc.b	'               PLAY  GAME               ' ;4
				dc.b	'                                        ' ;5
				dc.b	'            CONTROL  OPTIONS            ' ;6
				dc.b	'                                        ' ;7
				dc.b	'                                        ' ;8
				dc.b	'                  EXIT                  ' ;9
				dc.b	'                                        ' ;0
				dc.b	'                                        ' ;1
				dc.b	'                                        ' ;2
				dc.b	'                                        ' ;3
				dc.b	'                                        ' ;4
				dc.b	'                                        ' ;5

SLAVEPLAYERMENU_OPTS:
	;left, top, width
				dc.w	12,12,16,1
				dc.w	15,14,10,1
				dc.w	12,16,16,1
				dc.w	18,19,4,1
				dc.w	-1

;--------------------------------------------------------------------------------

CONTROL_TXT:
;      0123456789012345678901234567890123456789
				dc.b	'                                        ' ;1
				dc.b	'            DEFINE  CONTROLS            ' ;2
				dc.b	'                                        ' ;3
KEY_LINES:		dc.b	'     TURN LEFT                  CSRL    ' ;4
				dc.b	'     TURN RIGHT                 CSRR    ' ;5
				dc.b	'     FORWARDS                   CSRU    ' ;6
				dc.b	'     BACKWARDS                  CSRD    ' ;7
				dc.b	'     FIRE                       CTRL    ' ;8
				dc.b	'     OPERATE DOOR/LIFT/SWITCH   SPC     ' ;9
				dc.b	'     RUN                        LSH     ' ;0
				dc.b	'     FORCE SIDESTEP             LALT    ' ;1
				dc.b	'     SIDESTEP LEFT               Z      ' ;2
				dc.b	'     SIDESTEP RIGHT              X      ' ;3
				dc.b	'     DUCK                        D      ' ;4
				dc.b	'     LOOK BEHIND                 L      ' ;5
				dc.b	'                                        ' ;6
				dc.b	'             OTHER CONTROLS             ' ;7
				dc.b	'                                        ' ;8
				dc.b	' PULSE RIFLE      1  PAUSE            P ' ;9
				dc.b	' SHOTGUN          2  QUIT           ESC ' ;0
				dc.b	' PLASMA GUN       3  MOUSE CONTROL    M ' ;1
				dc.b	' GRENADE LAUNCHER 4  JOYSTICK CONTROL J ' ;2
				dc.b	' ROCKET LAUNCHER  5  KEYBOARD CONTROL K ' ;3
				dc.b	'                                        ' ;4
				dc.b	'               MAIN  MENU               ' ;5

CONTROL_OPTS:
	;left, top, width
				dc.w	05,04,31,1
				dc.w	05,05,31,1
				dc.w	05,06,31,1
				dc.w	05,07,31,1
				dc.w	05,08,31,1
				dc.w	05,09,31,1
				dc.w	05,10,31,1
				dc.w	05,11,31,1
				dc.w	05,12,31,1
				dc.w	05,13,31,1
				dc.w	05,14,31,1
				dc.w	05,15,31,1
				dc.w	15,25,10,1
				dc.w	-1

;--------------------------------------------------------------------------------

CREDITMENU_TXT:
;      0123456789012345678901234567890123456789
				dc.b	'             Main Game Code:            ' ;0
				dc.b	'                   by                   ' ;1
				dc.b	'            Andrew Clitheroe            ' ;2
				dc.b	'                                        ' ;3
				dc.b	'    Serial Link and 3D Object Editor:   ' ;4
				dc.b	'                   by                   ' ;5
				dc.b	'            Charles Blessing            ' ;6
				dc.b	'                                        ' ;7
				dc.b	'                Graphics:               ' ;8
				dc.b	'                   by                   ' ;9
				dc.b	'              Mike  Oakley              ' ;0
				dc.b	'                                        ' ;1
				dc.b	'             Title  Picture             ' ;2
				dc.b	'                   by                   ' ;3
				dc.b	'               Mike Green               ' ;4
				dc.b	'                                        ' ;5
				dc.b	' Inspiration, incentive, moral support, ' ;6
				dc.b	'     level design and plenty of tea     ' ;7
				dc.b	'         generously supplied by         ' ;8
				dc.b	'                                        ' ;9
				dc.b	'              Jackie  Lang              ' ;0
				dc.b	'                                        ' ;1
				dc.b	'    Music for the last demo composed    ' ;2
				dc.b	'       by the inexpressibly evil:       ' ;3
				dc.b	'                                        ' ;8
				dc.b	'            *BAD* BEN CHANTER           ' ;9
				dc.b	'                                        ' ;7

CREDITMENU_OPTS:
				dc.w	0,0,1,1
				dc.w	-1

;--------------------------------------------------------------------------------
