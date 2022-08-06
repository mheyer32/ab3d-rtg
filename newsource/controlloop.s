; Main control loop.
; This is the very outer loop of the program.

; What needs to be done and when?

; Black screen start.
; Load title music
; Load title screen
; Fade up title screen
; Select options
; Play game.

; Playing the game involves allocating screen and
; level memory, loading the level, loading the
; samples, loading the wall graphics, playing the
; level, deallocating the screen memory....

; Control part should therefore:

; 1. Load Title Music
; 2. Load title screen
; 3. Fade up title screen.
; 4. Add 'loading' message
; 5. Load samples and walls
; 6: LOOP START
; 7. Option select screens
; 8. Free music mem, allocate level mem.
; 9. Load level
;10. Play level with options selected
;11. Reload title music
;12. Reload title screen
;13. goto 6

;----------------------------------------------------------------------------

Main:			move.b	#'n',mors

				bsr		ClearTitlePal			;Clear screen to black

				bsr		LoadTitleScrn			;Load title bitmap
				bsr		DispTitleScrn			;Display title bitmap

;	move.l	ts_pal(pc),FadePal
;	jsr	SetPal

				clr.w	FadeVal					;Fade in title bitmap
				move.w	#63,FadeAmount
				bsr		FadeUpTitle

;	jsr	GetPensForCopCol	;Init table to map copper colours to game-palette pens
				;Takes ages so do it here when noone will notice :)

				jsr		LoadWalls				;Load game stuff
				jsr		LoadFloor
				jsr		LoadObjs

;	move.w       #31,FadeAmount	;Half-fade out title screen
;	bsr          FadeDownTitle

				bsr		SetDefaultGame

.menuloop:		clr.b	ExitGameSelected

				cmp.b	#'s',mors				;Decide which menu to display
				beq.s	.doSlaveMenu
				cmp.b	#'m',mors
				beq.s	.doMasterMenu

				bsr		DoOnePlyrMenu			;Handle 1 player menu
				bra.s	.doneMenu

.doMasterMenu:
				bsr		DoMasterMenu			;Handle 2-player master menu
				bra.s	.doneMenu

.doSlaveMenu:
				bsr		DoSlaveMenu				;Handle 2-player slave menu

.doneMenu:		bsr		ClrOptScreen			;Wipe displayed options

				move.w	#31,FadeAmount			;Fade out title screen
				bsr		FadeUpTitle
				move.w	#61,FadeAmount
				bsr		FadeDownTitle

				tst.b	ExitGameSelected		;Menu done - exit selected?
				bne		ExitGame				;Skip if yes

	;Must have selected to start game (brave!)

				clr.b	FinishedLevel			;Setup some things

				clr.w	PLR1s_angpos
				clr.w	PLR2s_angpos
				clr.w	PLR1_angpos
				clr.w	PLR2_angpos
				clr.b	PLR1_GunSelected
				clr.b	PLR2_GunSelected

				clr.b	NASTY					;Whats this?!?!

				jsr		PLAYTHEGAME				;Play selected level

				tst.b	FinishedLevel			;Level complete?
				beq.s	.dontusestats			;Skip if not

				bsr		GameToPassword			;Work out password for level just completed

.dontusestats:
				bsr		PasswordToGame

				bsr		LoadTitleScrn
				bsr		DispTitleScrn

				clr.w	FadeVal
				move.w	#63,FadeAmount
				bsr		FadeUpTitle
				move.w	#31,FadeAmount
				bsr		FadeDownTitle

				bra		.menuloop

;----------------------------------------------------------------------------

ExitGame:		;Exit	game

				jsr		ReleasePanel
				jsr		ReleaseWallMem
				jsr		RELEASESAMPMEM
				jsr		ReleaseFloorMem
				jsr		ReleaseObjMem

				rts

;----------------------------------------------------------------------------

DoOnePlyrMenu:
	;Handle the 1-player menu options

				move.b	#'n',mors

				move.w	MaxLevel,d0				;Copy level name to menu text
				mulu	#40,d0
				lea		LevelNames(pc),a0
				add.l	d0,a0
				lea		CURRENTLEVELLINE(pc),a1
				bsr		Copy40

.p1_fullloop:
				clr.w	OptScreenNum			;Render one-player options screen
				bsr		DrawOptScreen
				move.w	#1,CurrOpt
				bsr		HighlightCurrOpt
				bra.s	.p1_initloop

.p1_loop:		bsr		DrawP1LevelLine			;Re-render changable parts of menu
				bsr		DrawPwdLine

.p1_initloop:
				bsr		HandleMenu				;Get selection from menu

				tst.w	d0						;Skip if changed to 2-player master
				beq		DoMasterMenu

				cmp.w	#1,d0					;Start game?
				bne.s	.p1_not_playgame		;Skip if not

				move.w	MaxLevel(pc),LevelSelected
				rts

.p1_not_playgame:
				cmp.w	#2,d0					;Changing controls?
				bne.s	.p1_not_control			;Skip if not

				bsr		DoChangeControls
				bra.s	.p1_fullloop

.p1_not_control:
				cmp.w	#3,d0					;Show credits?
				bne.s	.p1_not_cred			;Skip if not

				bsr		DoShowCredits
				bra.s	.p1_fullloop

.p1_not_cred:
				cmp.w	#4,d0					;Enter passsword?
				bne.s	.p1_not_password		;Skip if not

				bsr		EnterPassword			;Get password string
				bmi.s	.p1_pass_aborted		;Skip if not entered

				bsr		PasswordToGame			;Try to convert password to game state

				tst.w	d0						;Password OK?
				bne.s	.p1_pass_aborted		;Skip if not

				move.w	MaxLevel(pc),d0			;Set level & level name from password
				muls	#40,d0
				lea		LevelNames(pc),a0
				add.l	d0,a0
				lea		CURRENTLEVELLINE(pc),a1
				bsr		Copy40

.p1_pass_aborted:
				bsr		GameToPassword
				bra.s	.p1_loop

.p1_not_password:
				st		ExitGameSelected		;Option must be "Exit"
				rts

;----------------------------------------------------------------------------------

DoMasterMenu:
	;Handle the 2-player master menu options

				move.b	#'m',mors

				clr.w	MasterLevel				;Put in name of level 1
				lea		LevelNames(pc),a0
				lea		CURRENTLEVELLINEM(pc),a1
				bsr		Copy40

.p2m_fullloop:
				move.w	#4,OptScreenNum			;Render 2-player master options screen
				bsr		DrawOptScreen
				move.w	#1,CurrOpt
				bsr		HighlightCurrOpt

.p2m_loop:		bsr		HandleMenu				;Get selection from menu

				tst.w	d0						;Slave menu?
				beq		DoSlaveMenu				;Skip if yes

				cmp.w	#1,d0					;Select next level?
				bne.s	.p2m_not_nextlev		;Skip if not

				move.w	MasterLevel(pc),d0		;Move to next level, up to max visited so far
				addq.w	#1,d0					;and wrapping round to start
				cmp.w	MaxLevel(pc),d0
				ble.s	.p2m_nowrap
				moveq	#0,d0
.p2m_nowrap:	move.w	d0,MasterLevel

				lea		CURRENTLEVELLINEM(pc),a1 ;Put new level name in
				mulu	#40,d0
				lea		LevelNames(pc),a0
				add.l	d0,a0
				bsr		Copy40
				bsr		DrawP2LevelLine
				bsr		HighlightCurrOpt

				bra.s	.p2m_loop

.p2m_not_nextlev:
				cmp.w	#2,d0					;Play game?
				bne.s	.p2m_not_playgame		;Skip if yes

				move.w	MasterLevel(pc),LevelSelected
				rts

.p2m_not_playgame:
				cmp.w	#3,d0					;Change controls?
				bne.s	.p2m_not_control		;Skip if not

				bsr		DoChangeControls
				bra.s	.p2m_fullloop

.p2m_not_control:
				st		ExitGameSelected		;Option must be "Exit"
				rts

;----------------------------------------------------------------------------------

DoSlaveMenu:	move.b	#'s',mors

.p2s_fullloop:
				move.w	#5,OptScreenNum			;Render 2-player master options screen
				bsr		DrawOptScreen
				move.w	#1,CurrOpt
				bsr		HighlightCurrOpt

.p2s_loop:		bsr		HandleMenu				;Get selection from menu

				tst.w	d0						;1-player game
				beq		DoOnePlyrMenu

				cmp.w	#1,d0					;Play game?
				bne.s	.p2s_not_playgame		;Skip if not

				rts

.p2s_not_playgame:
				cmp.w	#2,d0					;Change controls?
				bne.s	.p2s_not_control

				bsr		DoChangeControls
				bra.s	.p2s_fullloop

.p2s_not_control:
				st		ExitGameSelected		;Option must be "Exit"
				rts

;-----------------------------------------------------------------------------

DoChangeControls:
	;Handle the change control options screen

.dcc_fullloop:
				move.w	#6,OptScreenNum			;Render change control screen
				bsr		DrawOptScreen
				clr.w	CurrOpt
				bsr		HighlightCurrOpt

.dcc_loop		bsr		HandleMenu

				cmp.w	#12,d0					;All done?
				beq.s	.dcc_backtomain			;Skip if yes

				lea		KEY_LINES+32(pc),a0		;Blank out current key & redraw
				move.w	d0,d1
				mulu	#40,d1
				add.l	d1,a0
				move.l	#"    ",(a0)
				bsr.s	.dcc_renderline
				bsr		HighlightCurrOpt

.dcc_keyloop:
				jsr		WaitIntuiKeyMsg			;Wait for intuition keypress message
				move.l	Msg_Code,d1				;d1=keycode
				cmp.w	#256,d1
				bge.s	.dcc_keyloop

				lea		CONTROLBUFFER(pc),a1	;Set control key to message code
				move.b	d1,0(a1,d0.w)

				lea		KVALTOASC(pc),a1		;Convert keycode to ASC & redraw line
				move.l	0(a1,d1.w*4),(a0)
				bsr.s	.dcc_renderline
				bsr		HighlightCurrOpt

				bra.s	.dcc_loop

.dcc_backtomain:
				rts

.dcc_renderline:
	;d0=control number to rerender

				SAVEREGS

				lea		dl_x(pc),a1
				move.w	Scr_C320X+2,(a1)+		;Set x

				move.w	d0,d1					;y=(c+6)*8
				addq.w	#6,d1
				mulu	#8,d1
				add.l	Scr_C200Y,d1
				move.w	d1,(a1)+

				move.w	#320,(a1)+				;Width
				move.w	#40,(a1)+				;Height

				lea		KEY_LINES(pc),a0		;String start
				mulu	#40,d0
				add.l	d0,a0
				move.l	a0,(a1)+

				move.w	ts_stdpen(pc),(a1)		;Pen number

				bra		drawLineMain

;-------------------------------------------------------------------------------

DoShowCredits:
	;Display game credits

				move.w	#2,OptScreenNum
				bsr		DrawOptScreen

				jmp		WaitIntuiKeyMsg			;Wait for intuition keypress message

;----------------------------------------------------------------------------------

EnterPassword:
	;Get password for 1-player level from keyboard and store
	;Exit:	d0=0 if password was entered, -1 if aborted

				SAVEREGS

				lea		PASSWORDLINE+17(pc),a0	;Clear password line to spaces
				moveq	#15,d2
.pw_clrline:	move.b	#" ",(a0)+
				dbf		d2,.pw_clrline

				lea		PASSWORDLINE+17(pc),a0	;a0=buffer for password
				move.b	#"*",(a0)
				bsr		DrawPwdLine
				lea		KVALTOASC(pc),a1		;a1=rawkey->ASCII table
				moveq	#0,d3					;d3=length entered

.pw_enterloop:
				jsr		WaitIntuiKeyMsg			;Wait until we get a keypress

				move.l	Msg_Code,d2				;d2=keycode pressed

				cmp.w	#RAWKEY_DEL,d2			;Delete pressed?
				bne.s	.pw_notdelete
				tst.w	d3
				beq.s	.pw_notdelete

				subq.w	#1,d3					;Delete last character entered
				move.b	#" ",(a0)
				move.b	#"*",-(a0)
				bsr		DrawPwdLine
				bra.s	.pw_enterloop

.pw_notdelete:
				cmp.w	#RAWKEY_RETURN,d2		;Abort if RETURN or ESC pressed
				beq.s	.pw_abort
				cmp.w	#RAWKEY_ESC,d2
				beq.s	.pw_abort

				move.b	1(a1,d2.w*4),d2			;Convert keycode to ASCII
				cmp.b	#'A',d2					;Ignore non-alphabetic chars
				blt.s	.pw_enterloop
				cmp.b	#'Z',d2
				bgt.s	.pw_enterloop

				move.b	d2,(a0)+				;Store new char & display
				move.b	#"*",(a0)
				bsr		DrawPwdLine

				addq.w	#1,d3					;Inc length of string
				cmp.w	#16,d3					;Exit if 16 chars entered
				blt.s	.pw_enterloop

				move.b	#" ",(a0)
				bsr		DrawPwdLine

				GETREGS
				moveq	#0,d0
				rts

.pw_abort:		GETREGS
				moveq	#-1,d0
				rts

;-----

GameToPassword:
	;Convert game state to binary buffer & text password

				SAVEREGS

	;Build binary buffer from game state

				lea		PwdBinBuff(pc),a0		;a0=buffer
				lea		PLR1_GunData,a1

				move.b	PLR1_energy+1,d0
				bsr		.pw_getparity
				move.b	d0,(a0)

				moveq	#0,d0
				tst.b	32+7(a1)
				sne		d0
				lsl.w	#1,d0
				tst.b	32*2+7(a1)
				sne		d0
				lsl.w	#1,d0
				tst.b	32*4+7(a1)
				sne		d0
				lsl.w	#1,d0
				tst.b	32*7+7(a1)
				sne		d0
				lsr.w	#3,d0
				and.b	#%11110000,d0
				or.b	MaxLevel+1(pc),d0
				move.b	d0,1(a0)
				eor.b	#%10110101,d0
				neg.b	d0
				add.b	#50,d0
				move.b	d0,7(a0)

				move.w	(a1),d0
				lsr.w	#3,d0
				bsr		.pw_getparity
				move.b	d0,2(a0)

				move.w	32(a1),d0
				lsr.w	#3,d0
				bsr		.pw_getparity
				move.b	d0,3(a0)

				move.w	32*2(a1),d0
				lsr.w	#3,d0
				bsr		.pw_getparity
				move.b	d0,4(a0)

				move.w	32*4(a1),d0
				lsr.w	#3,d0
				bsr		.pw_getparity
				move.b	d0,5(a0)

				move.w	32*7(a1),d0
				lsr.w	#3,d0
				bsr		.pw_getparity
				move.b	d0,6(a0)

				moveq	#3,d0
				moveq	#0,d4
				lea		8(a0),a1				;a1=PwdBinBuff+8
				lea		PwdPreTxtBuff(pc),a2
.pw_mixemup:	move.b	(a0)+,d1
				move.b	-(a1),d2
				not.b	d2
				moveq	#0,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				lsr.b	#1,d1
				addx.w	d3,d3
				lsr.b	#1,d2
				addx.w	d3,d3
				move.w	d3,(a2)+
				dbf		d0,.pw_mixemup

				lea		PASSWORDLINE+17(pc),a0	;Build text password from buffer
				lea		PwdPreTxtBuff(pc),a1
				moveq	#7,d0
.pw_crttxtpass:
				move.b	(a1)+,d1
				move.b	d1,d2
				and.b	#%1111,d1
				add.b	#"A",d1
				move.b	d1,(a0)+

				lsr.b	#4,d2
				and.b	#%1111,d2
				add.b	#"A",d2
				move.b	d2,(a0)+
				dbf		d0,.pw_crttxtpass

				GETREGS
				rts
;---

.pw_getparity:
	;Calculate parity of d0.b and store in bit 7

				move.l	d3,-(a7)

				moveq	#6,d3
.gp_loop:		btst	d3,d0
				beq.s	.gp_nextbit
				bchg	#7,d0
.gp_nextbit:	dbf		d3,.gp_loop

				move.l	(a7)+,d3
				rts

;-----

PwdPreTxtBuff:	dcb.b	8						;Temp store to convert PwdBinBuff to text
PwdBinBuff:		dcb.b	8

;-----

PasswordToGame:
	;Convert text password to binary buffer & game state

				SAVEREGS

				lea		PASSWORDLINE+17(pc),a0	;Get binary values into buffer
				lea		PwdPreTxtBuff(pc),a1
				moveq	#7,d0
.pw_getbin:		move.b	(a0)+,d1
				move.b	(a0)+,d2
				sub.b	#"A",d1
				sub.b	#"A",d2
				and.b	#%1111,d1
				and.b	#%1111,d2
				lsl.b	#4,d2
				or.b	d2,d1
				move.b	d1,(a1)+
				dbf		d0,.pw_getbin

				lea		PwdPreTxtBuff(pc),a0	;Unscramble binary values
				lea		PwdBinBuff(pc),a1
				lea		8(a1),a2
				moveq	#3,d0
				moveq	#0,d4
.pw_unmix:		move.w	(a0)+,d1
				moveq	#0,d2
				moveq	#0,d3
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				lsr.w	#1,d1
				addx.w	d3,d3
				lsr.w	#1,d1
				addx.w	d2,d2
				not.b	d3
				move.b	d3,-(a2)
				move.b	d2,(a1)+
				dbf		d0,.pw_unmix

				lea		PwdBinBuff(pc),a0		;Check password is valid
				move.b	(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	2(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	3(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	4(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	5(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	6(a0),d0
				bsr		.pw_chkparity
				tst.b	d5
				bne		.pw_badpass

				move.b	1(a0),d0
				eor.b	#%10110101,d0
				neg.b	d0
				add.b	#50,d0
				cmp.b	7(a0),d0
				bne		.pw_badpass

	;Password is good - convert to game state

				moveq	#$7f,d1
				lea		PLR1_GunData,a1

				move.b	(a0),d0
				and.w	d1,d0
				move.w	d0,PLR1_energy

				move.b	1(a0),d0
				btst	#7,d0
				sne		32+7(a1)
				btst	#6,d0
				sne		32*2+7(a1)
				btst	#5,d0
				sne		32*4+7(a1)
				btst	#4,d0
				sne		32*7+7(a1)
				and.w	#%1111,d0
				move.w	d0,MaxLevel

				move.b	2(a0),d0
				and.w	d1,d0
				lsl.w	#3,d0
				move.w	d0,(a1)

				move.b	3(a0),d0
				and.w	d1,d0
				lsl.w	#3,d0
				move.w	d0,32(a1)

				move.b	4(a0),d0
				and.w	d1,d0
				lsl.w	#3,d0
				move.w	d0,32*2(a1)

				move.b	5(a0),d0
				and.w	d1,d0
				lsl.w	#3,d0
				move.w	d0,32*4(a1)

				move.b	6(a0),d0
				and.w	d1,d0
				lsl.w	#3,d0
				move.w	d0,32*7(a1)

				GETREGS
				moveq	#0,d0
				rts

.pw_badpass:	GETREGS	;BZZT!					Wrong Password!
				moveq	#-1,d0
				rts

;---

.pw_chkparity:
	;Check parity on d0.b
	;Exit:	d5 NZ if parity wrong

				movem.l	d0/d2-3,-(a7)

				moveq	#6,d3
				moveq	#0,d2
.cp_loop:		btst	d3,d0
				beq.s	.cp_nextbit
				bchg	#7,d2
.cp_nextbit:	dbf		d3,.cp_loop

				and.b	#$80,d0
				eor.b	d0,d2
				sne		d5

				movem.l	(a7)+,d0/d2-3
				rts

;-------------------------------------------------------------------------------

SetDefaultGame:
	;Set game state variables to defaults

				SAVEREGS

				clr.w	MaxLevel				;Level 1

				clr.w	OldEnergy				;Full energy
				move.w	#127,Energy
				jsr		EnergyBar

				move.w	#63,OldAmmo				;Full ammo
				clr.w	Ammo
				jsr		AmmoBar
				clr.w	OldAmmo

				move.w	#127,PLR1_energy		;Init players to full energy, 10 shots pistol
				lea		PLR1_GunData,a0
				bsr.s	.sd_setplyrgun
				clr.b	PLR1_GunSelected

				move.w	#127,PLR2_energy
				lea		PLR2_GunData,a0
				bsr.s	.sd_setplyrgun
				clr.b	PLR2_GunSelected

				bsr		GameToPassword			;Calc default password

				GETREGS
				rts

.sd_setplyrgun:
				move.w	#160,(a0)
				st		7(a0)
				clr.b	32+7(a0)
				clr.w	32(a0)
				clr.b	32*2+7(a0)
				clr.w	32*2(a0)
				clr.b	32*3+7(a0)
				clr.w	32*3(a0)
				clr.b	32*4+7(a0)
				clr.w	32*4(a0)
				clr.b	32*7+7(a0)
				clr.w	32*7(a0)
				rts

;-------------------------------------------------------------------------------

InitPlayers:	;Initialise player				variables for new game

				SAVEREGS

				move.l	#playerheight,PLR1s_targheight
				move.l	#playerheight,PLR1s_height
				move.l	#playerheight,PLR2s_targheight
				move.l	#playerheight,PLR2s_height
				clr.b	PLR1_StoodInTop

				clr.b	PLR1_Ducked
				clr.b	PLR2_Ducked
				clr.b	p1_ducked
				clr.b	p2_ducked

				cmp.b	#'s',mors
				beq.s	.ip_SLAVESETUP
				cmp.b	#'m',mors
				beq.s	.ip_MASTERSETUP

				st		NASTY
				GETREGS
				rts

;---

.ip_MASTERSETUP:
				bsr.s	.ip_TWOPLAYER			;2 player init
				move.w	LevelSelected(pc),d0	;Send level number to slave
				jsr		SENDFIRST

				GETREGS
				rts

;---

.ip_SLAVESETUP:
				bsr		.ip_TWOPLAYER			;2 player init

				jsr		RECFIRST				;Get level number from master
				move.w	d0,LevelSelected

				GETREGS
				rts
;-----

.ip_TWOPLAYER:
				clr.b	NASTY

				clr.w	OldEnergy
				move.w	#127,Energy
				jsr		EnergyBar

				move.w	#63,OldAmmo
				clr.w	Ammo
				jsr		AmmoBar
				clr.w	OldAmmo

				move.w	#127,PLR1_energy
				clr.b	PLR1_GunSelected
				lea		PLR1_GunData,a0
				bsr.s	.ip_2pmain

				move.w	#127,PLR2_energy
				clr.b	PLR2_GunSelected
				lea		PLR2_GunData,a0
				bsr.s	.ip_2pmain

				rts

;---

.ip_2pmain:		move.w	#160,(a0)
				st		7(a0)

				st.b	32+7(a0)
				move.w	#80*4,32(a0)

				st.b	32*2+7(a0)
				move.w	#80*4,32*2(a0)

				st.b	32*3+7(a0)
				move.w	#80*4,32*3(a0)

				st.b	32*4+7(a0)
				move.w	#80*4,32*4(a0)

				st.b	32*7+7(a0)
				move.w	#80*4,32*7(a0)
				rts


;-------------------------------------------------------------------------------

Copy40:			;Copy	40						bytes to a menu text line

				moveq	#39,d0
.c4_loop:		move.b	(a0)+,(a1)+
				dbf		d0,.c4_loop
				rts

;-----------------------------------------------------------------------------

DrawOptScreen2:
	;Render options screen without erasing previous screen
	;Entry:	OptScreenNum.w holds the screen number to render

				SAVEREGS
				bsr.s	drawOptScreenMain
				GETREGS
				rts
;---

DrawOptScreen:
	;Render an options screen
	;Entry:	OptScreenNum.w holds the screen number to render

				SAVEREGS

				bsr		ClrOptScreen			;Wipe previous options

drawOptScreenMain:
				move.l	Scr_Base,a0
				move.l	a0,-(a7)

				move.w	ts_stdpen(pc),d0		;Set drawmode and pens to menutext
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				RTGCALL	RtgSetTextMode

				move.l	(a7),a0					;Set font for printing
				move.l	TitleFont,a1
				CALLA6	RtgSetFont

				move.l	(a7),a0
				CALLA6	RtgWaitTOF

				lea		MENUDATA(pc),a2			;Get a2=this menu's data
				move.w	OptScreenNum(pc),d0
				move.l	0(a2,d0.w*8),a2

				move.l	Scr_C200Y,d1			;d1=initial Y coord
				moveq	#25-1,d7				;d7=number of lines
.dos_lineloop:
				movem.l	d1/d7/a2,-(a7)

				move.l	12(a7),a0				;Set drawmode and pens to shadow
				moveq	#0,d0
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				CALLA6	RtgSetTextMode

				move.l	12(a7),a0				;Draw shadow text
				move.l	Scr_Buf0,a1
				move.l	8(a7),a2
				moveq	#40,d0
				move.l	Scr_C320X,d1
				move.l	(a7),d2
				addq.l	#1,d2
				CALLA6	RtgText

				move.l	12(a7),a0				;Set drawmode and pens to text
				move.w	ts_stdpen(pc),d0
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				CALLA6	RtgSetTextMode

				move.l	12(a7),a0				;Draw actual text
				move.l	Scr_Buf0,a1
				move.l	8(a7),a2
				moveq	#40,d0
				move.l	Scr_C320X,d1
				addq.l	#1,d1
				move.l	(a7),d2
				CALLA6	RtgText

				movem.l	(a7)+,d1/d7/a2			;Move to next line
				add.l	#40,a2
				addq.w	#8,d1
				dbf		d7,.dos_lineloop

				addq.l	#4,a7					;Forget rtgscreen address
				GETREGS
				rts

;-----

HandleMenu:		;Handle	with					selecting menu options from current menu
	;Exit:	d0=option selected

				movem.l	d1-7/a0-6,-(a7)

				move.w	OptScreenNum(pc),d0		;Get a4=option data
				lea		MENUDATA(pc),a4
				move.l	4(a4,d0.w*8),a4

.hm_menuloop:
				jsr		WaitIntuiKeyMsg			;Wait for intuition keypress message
				move.l	Msg_Code,d0				;d0=keycode pressed

				cmp.w	#RAWKEY_SPACE,d0		;Skip if fire/SPACE/RETURN pressed
				beq.s	.hm_selected
				cmp.w	#RAWKEY_RETURN,d0
				beq.s	.hm_selected
				cmp.w	#RAWKEY_PORT1_BUTTON_BLUE,d0
				blt.s	.hm_notselected
				cmp.w	#RAWKEY_PORT1_BUTTON_PLAY,d0
				ble.s	.hm_selected

.hm_notselected:
				move.w	CurrOpt(pc),d7			;d7=current option number

				cmp.w	#RAWKEY_PORT1_JOY_UP,d0	;Up pressed?
				beq.s	.hm_moveup
				cmp.w	#RAWKEY_CURSU,d0
				bne.s	.hm_testdown

.hm_moveup:		subq.w	#1,d7					;Move to prev option
				bge.s	.hm_optchanged
				moveq	#0,d7
				bra.s	.hm_optchanged

.hm_testdown:
				cmp.w	#RAWKEY_PORT1_JOY_DOWN,d0 ;Down pressed?
				beq.s	.hm_movedown
				cmp.w	#RAWKEY_CURSD,d0
				bne.s	.hm_menuloop

.hm_movedown:
				addq.w	#1,d7					;Move to next option
				tst.w	0(a4,d7.w*8)
				bge.s	.hm_optchanged
				subq.w	#1,d7

.hm_optchanged:
	;Current option has been changed
	;d7=new option

				bsr.s	HighlightCurrOpt		;Un-highlight current option
				move.w	d7,CurrOpt				;and highlight new one
				bsr.s	HighlightCurrOpt
				bra.s	.hm_menuloop

.hm_selected:
	;Current option has been selected

				moveq	#0,d0					;Return option number in d0
				move.w	CurrOpt(pc),d0

				movem.l	(a7)+,d1-7/a0-6
				rts

;-----

HighlightCurrOpt:
	;Highlight current option
	;Entry:	OptScreenNum holds option screen number
	;	CurrOpt holds option number to highlight

				rts

				SAVEREGS

				move.w	OptScreenNum(pc),d0		;Get dimensions of bar to invert
				lea		MENUDATA(pc),a1
				move.l	0(a1,d0.w*8),a2			;a2=base option text
				move.l	4(a1,d0.w*8),a0			;a0=base menu options
				move.w	CurrOpt(pc),d0
				lea		(a0,d0.w*8),a0			;a0=this options info

				movem.w	(a0)+,d0-2				;d0=left, d1=top, d2=width
				move.w	d1,d3					;d3=top

				lea		dl_x(pc),a0

				lsl.w	#3,d0					;Set left X
				move.w	d0,(a0)+

				lsl.w	#3,d1					;Set top Y
				move.w	d1,(a0)+

				move.w	d2,d0					;Set width & text length
				lsl.w	#3,d2
				move.w	d2,(a0)+
				move.w	d0,(a0)+

				mulu	#40,d3					;Set text string
				add.l	d3,a2
				move.l	a2,(a0)+

				move.w	ts_hipen(pc),(a0)		;Set pen number

				bra		drawLineMain			;Draw line in highlight mode

;-----

DrawP2LevelLine:
	;Draw the level name line on the 2-player master menu

				SAVEREGS

				lea		dl_x(pc),a0
				clr.w	(a0)+
				move.w	#112,(a0)+
				move.w	#320,(a0)+
				move.w	#40,(a0)+
				move.l	#CURRENTLEVELLINEM,(a0)+
				move.w	ts_stdpen(pc),(a0)
				bra.s	drawLineMain

;-----

DrawP1LevelLine:
	;Draw the level name line on the 1-player menu

				SAVEREGS

				lea		dl_x(pc),a0
				clr.w	(a0)+
				move.w	#88,(a0)+
				move.w	#320,(a0)+
				move.w	#40,(a0)+
				move.l	#CURRENTLEVELLINE,(a0)+
				move.w	ts_stdpen(pc),(a0)
				bra.s	drawLineMain
;---

DrawPwdLine:	;Draw	the						level password line

				SAVEREGS

				lea		dl_x(pc),a0
				move.w	#136,(a0)+
				move.w	#168,(a0)+
				move.w	#137,(a0)+
				move.w	#17,(a0)+
				move.l	#PASSWORDLINE+17,(a0)+
				move.w	ts_stdpen(pc),(a0)

;---

drawLineMain:
	;Redraw a specified line of text

				move.l	Scr_Base,a0
				move.l	a0,-(a7)
				RTGCALL	RtgWaitTOF

	;Erase current line first

				move.l	(a7),a0
				move.l	Scr_Buf0,a1				;a1=dest address
				move.l	BGPicMem,a2				;a2=source address
				sub.l	a3,a3
				move.l	Scr_C320X,d0
				move.w	dl_y(pc),d1
				move.w	d1,d7
				add.w	Scr_C200Y+2,d1
				move.w	#320,d2
				moveq	#9,d3
				move.l	#320,d4
				move.l	#256,d5
				moveq	#0,d6
				CALLA6	CopyRtgBlit

				move.l	(a7),a0					;Set drawmode and pens to shadow
				moveq	#0,d0
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				CALLA6	RtgSetTextMode

				move.l	(a7),a0					;Draw shadow text
				move.l	Scr_Buf0,a1
				move.l	dl_str(pc),a2
				move.w	dl_len(pc),d0
				move.w	dl_x(pc),d1
				move.w	dl_y(pc),d2
				CALLA6	RtgText

				move.l	(a7),a0					;Set drawmode and pens to text
				move.w	dl_pen(pc),d0
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				CALLA6	RtgSetTextMode

				move.l	(a7)+,a0				;Draw text
				move.l	Scr_Buf0,a1
				move.l	dl_str(pc),a2
				move.w	dl_len(pc),d0
				move.w	dl_x(pc),d1
				move.w	dl_y(pc),d2
				CALLA6	RtgText

				GETREGS
				rts

				CNOP	0,4
dl_x:			dc.w	0
dl_y:			dc.w	0
dl_size:		dc.w	0
dl_len:			dc.w	0
dl_str:			dc.l	0
dl_pen:			dc.w	0

;---------------------------------------------------------------------------

FadeUpTitle:	;Fade	title					screen palette up (brighten) from current
				move.w	#4,FadeDir
				move.l	ts_pal(pc),FadePal
				jmp		FadeMain


FadeDownTitle:
	;Fade title screen palette down (darken) from current
				move.w	#-4,FadeDir
				move.l	ts_pal(pc),FadePal
				jmp		FadeMain


ClearTitlePal:
	;Set title screen palette to all black

				move.l	ts_pal(pc),FadePal
				jmp		ClearPal

;---------------------------------------------------------------------------------

LoadTitleScrn:
	;Load title screen picture

				move.l	d1,-(a7)
				move.l	#ts_name,d1
				jsr		LoadBGPic
				move.l	(a7)+,d1
				rts

;----------

ClrOptScreen:
DispTitleScrn:
	;Copy title screen picture to screen memory

				SAVEREGS

				move.l	Scr_Base,a0
				move.l	a0,-(a7)

				lea		.dts_menupal(pc),a1		;Set colour of menu text
				move.w	ts_stdpen(pc),d0
				move.w	d0,2(a1)
				RTGCALL	LoadRGBRtg

				move.l	(a7),a0					;Copy picture data to screen
				move.l	Scr_Buf0,a1
				move.l	BGPicMem,a2
				sub.l	a3,a3
				moveq	#0,d0
				moveq	#0,d1
				move.l	#320,d2
				move.l	Scr_Height,d3
				cmp.w	#256,d3
				ble.s	.dts_less256
				move.l	#256,d3
.dts_less256:
				move.l	#320,d4
				move.l	#256,d5
				moveq	#0,d6
				moveq	#0,d7
				CALLA6	CopyRtgBlit

				move.l	(a7),a0
				CALLA6	WaitRtgBlit

				move.l	(a7),a0
				moveq	#0,d0
				CALLA6	SwitchScreens

				move.l	(a7)+,a0
				CALLA6	WaitRtgSwitch

				GETREGS
				rts

.dts_menupal:
				dc.w	1,0
				dc.l	$ffffffff,$ffffffff,$ffffffff ;Menu text colour
				dc.w	0

;---------------------------------------------------------------------------------

MaxLevel:		dc.w	0
MasterLevel:	dc.w	0
LevelSelected:	dc.w	0

FinishedLevel:	dc.w	0
CurrOpt:		dc.w	0
OptScreenNum:	dc.w	0
ExitGameSelected: dc.b	0
				EVEN

ts_stdpen:		dc.w	0
ts_hipen:		dc.w	0

ts_pal:			dc.l	0

tspal_8:		INCBIN	TitleNew.pal
tspal_6:		INCBIN	TitleNewEHB.pal

ts_name:		dc.b	'PROJ:AB3D/NewStuff/TitleNew.'
ts_namenum:		dc.b	'8',0
				EVEN

RVAL1:			dc.w	0
RVAL2:			dc.w	0
NASTY:			dc.w	0

SSTACK:			dc.l	0

CONTROLBUFFER:
turn_left_key:	dc.b	RAWKEY_CURSL
turn_right_key:	dc.b	RAWKEY_CURSR
forward_key:	dc.b	RAWKEY_CURSU
backward_key:	dc.b	RAWKEY_CURSD
fire_key:		dc.b	RAWKEY_CTRL
operate_key:	dc.b	RAWKEY_SPACE
run_key:		dc.b	RAWKEY_LSHIFT
force_sidestep_key: dc.b RAWKEY_LALT
sidestep_left_key: dc.b	RAWKEY_Z
sidestep_right_key: dc.b RAWKEY_X
duck_key:		dc.b	RAWKEY_D
look_behind_key: dc.b	RAWKEY_L

templeftkey:	dc.b	0
temprightkey:	dc.b	0
tempslkey:		dc.b	0
tempsrkey:		dc.b	0

				EVEN

;----------------------------------------------------------------------------

				CNOP	0,4
KVALTOASC:		dc.b	" `  "," 1  "," 2  "," 3  "
				dc.b	" 4  "," 5  "," 6  "," 7  "
				dc.b	" 8  "," 9  "
				dc.b	" 0  "," -  "," +  "," \  "
				dc.b	'    ','    '," Q  "," W  "
				dc.b	" E  "," R  "
				dc.b	" T  "," Y  "," U  "," I  "
				dc.b	" O  "," P  "," [  "," ]  "
				dc.b	'    ','KP1 '
				dc.b	'KP2 ','KP3 '," A  "," S  "
				dc.b	" D  "," F  "," G  "," H  "
				dc.b	" J  "," K  "
				dc.b	" L  "," ;  "," #  ",'    '
				dc.b	'    ','KP4 ','KP5 ','KP6 '
				dc.b	'    '," Z  "
				dc.b	" X  "," C  "," V  "," B  "
				dc.b	" N  "," M  "," ,  "," .  "
				dc.b	" /  ",'    '
				dc.b	'    ','KP7 ','KP8 ','KP9 '
				dc.b	'SPC ','<-- ','TAB ','ENT '
				dc.b	'RTN ','ESC '
				dc.b	'DEL ','    ','    ','    '
				dc.b	'KP- ','    ','CSRU','CSRD'
				dc.b	'CSRR','CSRL'
				dc.b	' F1 ',' F2 ',' F3 ',' F4 '
				dc.b	' F5 ',' F6 ',' F7 ',' F8 '
				dc.b	' F9 ','F10 '
				dc.b	'KP( ','KP) ','KP/ ','KP* '
				dc.b	'KP+ '
				dc.b	'HELP','LSH ','RSH '
				dc.b	'CPL ','CTRL'
				dc.b	'LALT','RALT','LAMI','RAMI'
				dc.b	'    ','    ','    ','    '
				dc.b	'    ','    '
				dc.b	'    ','    ','    ','    '
				dc.b	'    ','    ','    ','    '
				dc.b	'    ','    '
				EVEN

				INCLUDE	menudata.s

;---------------------------------------------------------------------------------
