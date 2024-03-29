*				SECTION	main,CODE
				OPT		O+,W-,P=68020

				INCDIR	INCLUDE
				INCDIR	TMP:AB3D/AB3D-RTG/NewSource
				INCDIR	TMP:AB3D/AB3D-RTG/NewInclude
				INCDIR	TMP:AB3D/AB3D-RTG/NewVectObj
				INCDIR	TMP:AB3D/AB3D-RTG/NewStuff

				INCLUDE	funcdef.i
				INCLUDE	exec/exec.i
				INCLUDE	lvo/exec_lib.i
				INCLUDE	dos/dos.i
				INCLUDE	lvo/dos_lib.i
				INCLUDE	dos/dosextens.i
				INCLUDE	libraries/diskfont.i
				INCLUDE	lvo/diskfont_lib.i
				INCLUDE	libraries/lowlevel.i
				INCLUDE	lvo/lowlevel_lib.i
				INCLUDE	intuition/intuition.i
				INCLUDE	lvo/intuition_lib.i
				INCLUDE	graphics/gfxbase.i
				INCLUDE	lvo/graphics_lib.i
				INCLUDE	graphics/text.i
				INCLUDE	graphics/videocontrol.i
				INCLUDE	devices/input.i
				INCLUDE	devices/inputevent.i
				INCLUDE	devices/keyboard.i
				INCLUDE	lvo/cia_lib.i
				INCLUDE	hardware/custom.i
				INCLUDE	hardware/cia.i
				INCLUDE	hardware/intbits.i
				INCLUDE	hardware/dmabits.i
				INCLUDE	rtgmaster/rtgmaster_lib.i
				INCLUDE	rtgmaster/rtgmaster.i
				INCLUDE	rtgmaster/rtgsublibs.i
				INCLUDE	rtgmaster/rtgc2p.i

				INCLUDE	rawkeys.i
				INCLUDE	macros.s
				INCLUDE	defs.s

custom			equ		$dff000

;----------------------------------------------------------------------
	;For NewStartup

StartSkip:		equ		0						;0=WB/CLI, 1=CLI only (eg. from AsmOne)
Processor:		equ		68020					;0/680x0 (= 0 is faster than 68000)
MathProc:		equ		0						;FPU: 0(none)/68881/68882/68040

;----------------------------------------------------------------------

CD32VER:		equ		0

;------------------------------------------------------------------------------

spr0ctl			equ		$142
spr1ctl			equ		$14a
spr2ctl			equ		$152
spr3ctl			equ		$15a
spr4ctl			equ		$162
spr5ctl			equ		$16a
spr6ctl			equ		$172
spr7ctl			equ		$17a
spr0pos			equ		$140
spr1pos			equ		$148
spr2pos			equ		$150
spr3pos			equ		$158
spr4pos			equ		$160
spr5pos			equ		$168
spr6pos			equ		$170
spr7pos			equ		$178
color00			equ		$180
color01			equ		$182
color02			equ		$184
color03			equ		$186
color04			equ		$188
color05			equ		$18a
color06			equ		$18c
color07			equ		$18e
color08			equ		$190
color09			equ		$192
color10			equ		$194
color11			equ		$196
color12			equ		$198
color13			equ		$19a
intreqrl		equ		$01f
bpl1pth			equ		$e0
bpl1ptl			equ		$e2
bpl2pth			equ		$e4
bpl2ptl			equ		$e6
bpl3pth			equ		$e8
bpl3ptl			equ		$ea
bpl4pth			equ		$ec
bpl4ptl			equ		$ee
bpl5pth			equ		$f0
bpl5ptl			equ		$f2
bpl6pth			equ		$f4
bpl6ptl			equ		$f6
bpl7pth			equ		$f8
bpl7ptl			equ		$fa
bpl8pth			equ		$fc
bpl8ptl			equ		$fe
spr0pth			equ		$120
spr0ptl			equ		$122
spr1pth			equ		$124
spr1ptl			equ		$126
spr2pth			equ		$128
spr2ptl			equ		$12a
spr3pth			equ		$12c
spr3ptl			equ		$12e
spr4pth			equ		$130
spr4ptl			equ		$132
spr5pth			equ		$134
spr5ptl			equ		$136
spr6pth			equ		$138
spr6ptl			equ		$13a
spr7pth			equ		$13c
spr7ptl			equ		$13e
;------------------------------------------------------------------------------

				INCLUDE	Startup.asm

				CNOP	0,4
				dc.b	"$VER: AB3D-SE ("
;				INCLUDE	BuildTime		; FIXME: recreate some time
				dc.b	")"
				dc.b	0
				EVEN

Init:			TaskName "AB3D-SE"

				DefLib	dos,39					;Open the libs we need
				DefLib	graphics,39
				DefLib	intuition,39
				DefLib	diskfont,39
				DefLib	lowlevel,40
				DefLib	rtgmaster,27
				DefEnd	;ALWAYS					REQUIRED!!!

				CNOP	0,4
_SysBase:		dc.l	0

;------------------------------------------------------------------------------

Start:			;What	a						lovely main loop! My CSci lecturers would be so proud...

				bsr		Setup
				bsr		Main
				bsr		Cleanup

				moveq	#0,d0
				rts

;------------------------------------------------------------------------------

				INCLUDE	setup.s
				INCLUDE	screen.s
				INCLUDE	keyboard.s
				INCLUDE	controlloop.s
				INCLUDE	fade.s

				INCLUDE	tweentext.s
				INCLUDE	loadlevel.s
				INCLUDE	chunkyconvert.s
				INCLUDE	kalms_cpu5blit0.s
				INCLUDE	sound.s

;--------------------------------------------------------------------------------

PLAYTHEGAME:	;...erm...play the				game!

				jsr		Win_Clear

				cmp.b	#'n',mors				;Display TweenText screen if needed
				bne.s	.notweentext

				jsr		RenderTweenText
				jsr		FadeInTweenText

.notweentext:
				jsr		InitPlayers				;Init players & level number

				jsr		LoadPanel				;Load status panel

				jsr		LoadLevel				;Alloc & load level data

				jsr		InitSound				;Initialise sound stuff

				jsr		MAKEBACKROUT

				clr.w	Conditions
				cmp.b	#'n',mors
				beq.s	.nokeys
				move.w	#%111111111111,Conditions

.nokeys:		jsr		ClearKeyboard

				jsr		AddVBTask				;Add task to check keys & sounds

				st		doanything

				clr.b	MASTERQUITTING
				cmp.b	#'n',mors
				seq		SLAVEQUITTING

				move.w	#0,hitcol
				move.w	#0,hitcol2

				cmp.b	#'n',mors				;UnDisplay TweenText screen if needed
				bne.s	.notweentext2
				jsr		WaitIntuiKeyMsg
				jsr		FadeOutTweenText
.notweentext2:
				jsr		InitGameScreen			;Initialise the game screen

;	jsr	ReleasePanel
;	jsr	UnLoadLevel
;	rts

;-----

mainloop:		;Start	of						main game loop

				cmp.b	#'n',mors				;See if we pause or not
				bne.s	.nopause

				lea		KeyMap,a5				;"P" pressed?
				tst.b	KEY_P(a5)
				beq.s	.nopause
				clr.b	doanything

.waitrel:		move.l	a5,-(a7)				;Wait for P to be released
				GRAFCALL WaitTOF
				move.l	(a7)+,a5
				tst.b	KEY_P(a5)
				bne.s	.waitrel

				bsr		PauseOpts				;Do the pause options
				st		doanything

.nopause:		st		READCONTROLS
				move.l	#$dff000,a6

				move.w	hitcol,d0
				beq.s	nofadedownhc
				sub.w	#$100,d0
				move.w	d0,hitcol
				move.w	d0,hitcol2
nofadedownhc:

				cmp.b	#'n',mors
				beq		.nopause

				move.b	SLAVEPAUSE,d0
				or.b	MASTERPAUSE,d0
				beq.s	.nopause
				clr.b	doanything

				move.l	#KeyMap,a5
.waitrel:		tst.b	$19(a5)
				bne.s	.waitrel

				bsr		PauseOpts

				cmp.b	#'m',mors
				bne.s	.slavelast
				Jsr		SENDFIRST
				bra		.masfirst
.slavelast		jsr		RECFIRST
.masfirst:		clr.b	SLAVEPAUSE
				clr.b	MASTERPAUSE
				st		doanything

.nopause:		move.l	drawpt,a3
				adda.w	#10,a3
				move.l	a3,frompt
				add.l	#96*40*2,a3
				move.l	a3,midpt

				cmp.b	#'s',mors
				beq.s	nowaitslave

				GRAFCALL WaitTOF
				lea		custom,a6

				move.l	#PLR1_GunData,GunData
				move.b	PLR1_GunSelected,GunSelected
				bra		waitmaster

nowaitslave:	move.l	#PLR2_GunData,GunData
				move.b	PLR2_GunSelected,GunSelected
waitmaster:		move.l	waterpt,a0
				move.l	(a0)+,watertouse
				cmp.l	#endwaterlist,a0
				blt.s	okwat
				move.l	#waterlist,a0
okwat:			move.l	a0,waterpt

				add.w	#640,wtan
				and.w	#8191,wtan
				add.w	#1,wateroff
				and.w	#63,wateroff

				move.l	GunData,a6
				moveq	#0,d0
				move.b	GunSelected,d0
				lsl.w	#2,d0
				lea		(a6,d0.w*8),a6
				move.w	(a6),d0
				asr.w	#3,d0
				move.w	d0,Ammo

				move.l	PLR1_xoff,OLDX1
				move.l	PLR1_zoff,OLDZ1
				move.l	PLR2_xoff,OLDX2
				move.l	PLR2_zoff,OLDZ2



				move.l	#$dff000,a6

				cmp.b	#'s',mors
				beq		ASlaveShouldWaitOnHisMaster

				cmp.b	#'n',mors
				bne		NotOnePlayer

				move.w	PLR1_energy,Energy
				move.w	FramesToDraw,TempFrames
				cmp.w	#15,TempFrames
				blt.s	.okframe
				move.w	#15,TempFrames
.okframe:		move.w	#0,FramesToDraw

*********************************************
*********** TAKE THIS OUT *******************
*********************************************

				move.l	#KeyMap,a5
				tst.b	KEY_HELP(a5)
				beq.s	.nocheat
				move.w	#127,PLR1_energy
				bsr		EnergyBar
.nocheat
**********************************************
**********************************************
**********************************************

				move.l	PLR1s_xoff,p1_xoff
				move.l	PLR1s_zoff,p1_zoff
				move.l	PLR1s_yoff,p1_yoff
				move.l	PLR1s_height,p1_height
				move.w	PLR1s_angpos,p1_angpos
				move.w	PLR1_bobble,p1_bobble
				move.b	PLR1_clicked,p1_clicked
				move.b	PLR1_fire,p1_fire
				clr.b	PLR1_clicked
				move.b	PLR1_SPCTAP,p1_spctap
				clr.b	PLR1_SPCTAP
				move.b	PLR1_Ducked,p1_ducked
				move.b	PLR1_GunSelected,p1_gunselected

				jsr		PLR1_Control

				move.l	PLR1_Roompt,a0
				move.l	ToZoneRoof(a0),SplitHeight
				move.w	p1_xoff,THISPLRxoff
				move.w	p1_zoff,THISPLRzoff


				move.l	#$60000,p2_yoff
				move.l	PLR2_Obj,a0
				move.w	#-1,GraphicRoom(a0)
				move.w	#-1,12(a0)
				move.b	#0,17(a0)
				move.l	#BollocksRoom,PLR2_Roompt

				bra		donetalking

NotOnePlayer:
				move.l	#KeyMap,a5
				tst.b	$19(a5)
				sne		MASTERPAUSE

*********************************
				move.w	PLR1_energy,Energy
; change this back
*********************************

				jsr		SENDFIRST

				move.w	FramesToDraw,TempFrames
				cmp.w	#15,TempFrames
				blt.s	.okframe
				move.w	#15,TempFrames
.okframe:		move.w	#0,FramesToDraw

				move.l	PLR1s_xoff,p1_xoff
				move.l	PLR1s_zoff,p1_zoff
				move.l	PLR1s_yoff,p1_yoff
				move.l	PLR1s_height,p1_height
				move.w	PLR1s_angpos,p1_angpos
				move.w	PLR1_bobble,p1_bobble
				move.b	PLR1_clicked,p1_clicked
				clr.b	PLR1_clicked
				move.b	PLR1_fire,p1_fire
				move.b	PLR1_SPCTAP,p1_spctap
				clr.b	PLR1_SPCTAP
				move.b	PLR1_Ducked,p1_ducked
				move.b	PLR1_GunSelected,p1_gunselected

				move.l	p1_xoff,d0
				jsr		SENDFIRST
				move.l	d0,p2_xoff

				move.l	p1_zoff,d0
				jsr		SENDFIRST
				move.l	d0,p2_zoff

				move.l	p1_yoff,d0
				jsr		SENDFIRST
				move.l	d0,p2_yoff

				move.l	p1_height,d0
				jsr		SENDFIRST
				move.l	d0,p2_height

				move.w	p1_angpos,d0
				swap	d0
				move.w	p1_bobble,d0
				jsr		SENDFIRST
				move.w	d0,p2_bobble
				swap	d0
				move.w	d0,p2_angpos


				move.w	TempFrames,d0
				swap	d0
				move.b	p1_spctap,d0
				lsl.w	#8,d0
				move.b	p1_clicked,d0
				jsr		SENDFIRST
				move.b	d0,p2_clicked
				lsr.w	#8,d0
				move.b	d0,p2_spctap


				move.w	Rand1,d0
				swap	d0
				move.b	p1_ducked,d0
				lsl.w	#8,d0
				move.b	p1_gunselected,d0
				jsr		SENDFIRST
				move.b	d0,p2_gunselected
				lsr.w	#8,d0
				move.b	d0,p2_ducked

				move.b	p1_fire,d0
				lsl.w	#8,d0
				move.b	MASTERQUITTING,d0
				or.b	d0,SLAVEQUITTING
				swap	d0
				move.b	MASTERPAUSE,d0
				or.b	d0,SLAVEPAUSE
				jsr		SENDFIRST
				or.b	d0,MASTERPAUSE
				or.b	d0,SLAVEPAUSE
				swap	d0
				or.b	d0,SLAVEQUITTING
				or.b	d0,MASTERQUITTING
				lsr.w	#8,d0
				move.b	d0,p2_fire

				jsr		PLR1_Control
				jsr		PLR2_Control
				move.l	PLR1_Roompt,a0
				move.l	ToZoneRoof(a0),SplitHeight
				move.w	p1_xoff,THISPLRxoff
				move.w	p1_zoff,THISPLRzoff

				bra		donetalking

ASlaveShouldWaitOnHisMaster:

				move.l	#KeyMap,a5
				tst.b	$19(a5)
				sne		SLAVEPAUSE


				move.w	PLR2_energy,Energy

				jsr		RECFIRST

				move.l	PLR2s_xoff,p2_xoff
				move.l	PLR2s_zoff,p2_zoff
				move.l	PLR2s_yoff,p2_yoff
				move.l	PLR2s_height,p2_height
				move.w	PLR2s_angpos,p2_angpos
				move.w	PLR2_bobble,p2_bobble
				move.b	PLR2_clicked,p2_clicked
				clr.b	PLR2_clicked
				move.b	PLR2_fire,p2_fire
				move.b	PLR2_SPCTAP,p2_spctap
				clr.b	PLR2_SPCTAP
				move.b	PLR2_Ducked,p2_ducked
				move.b	PLR2_GunSelected,p2_gunselected

				move.l	p2_xoff,d0
				jsr		RECFIRST
				move.l	d0,p1_xoff

				move.l	p2_zoff,d0
				jsr		RECFIRST
				move.l	d0,p1_zoff

				move.l	p2_yoff,d0
				jsr		RECFIRST
				move.l	d0,p1_yoff

				move.l	p2_height,d0
				jsr		RECFIRST
				move.l	d0,p1_height

				move.w	p2_angpos,d0
				swap	d0
				move.w	p2_bobble,d0
				jsr		RECFIRST
				move.w	d0,p1_bobble
				swap	d0
				move.w	d0,p1_angpos


				move.b	p2_spctap,d0
				lsl.w	#8,d0
				move.b	p2_clicked,d0
				jsr		RECFIRST
				move.b	d0,p1_clicked
				lsr.w	#8,d0
				move.b	d0,p1_spctap
				swap	d0
				move.w	d0,TempFrames


				move.b	p2_ducked,d0
				lsl.w	#8,d0
				move.b	p2_gunselected,d0
				jsr		RECFIRST
				move.b	d0,p1_gunselected
				lsr.w	#8,d0
				move.b	d0,p1_ducked
				swap	d0
				move.w	d0,Rand1

				move.b	p2_fire,d0
				lsl.w	#8,d0
				move.b	SLAVEQUITTING,d0
				or.b	d0,MASTERQUITTING
				swap	d0
				move.b	SLAVEPAUSE,d0
				or.b	d0,MASTERPAUSE
				jsr		RECFIRST
				or.b	d0,MASTERPAUSE
				or.b	d0,SLAVEPAUSE
				swap	d0
				or.b	d0,SLAVEQUITTING
				or.b	d0,MASTERQUITTING
				lsr.w	#8,d0
				move.b	d0,p1_fire


				jsr		PLR1_Control
				jsr		PLR2_Control
				move.w	p2_xoff,THISPLRxoff
				move.w	p2_zoff,THISPLRzoff
				move.l	PLR2_Roompt,a0
				move.l	ToZoneRoof(a0),SplitHeight

donetalking:	move.l	#ZoneBrightTable,a1
				move.l	ZoneAdds,a2
				move.l	PLR2_ListOfGraphRooms,a0
				move.l	PLR2_PointsToRotatePtr,a5
				cmp.b	#'s',mors
				beq.s	doallz
				move.l	PLR1_ListOfGraphRooms,a0
				move.l	PLR1_PointsToRotatePtr,a5

doallz			move.w	(a0),d0
				blt.s	doneallz
				add.w	#8,a0

				move.l	(a2,d0.w*4),a3
				add.l	LevelDataPtr,a3
				move.w	ToZoneBrightness(a3),d2

				blt.s	justbright
				move.w	d2,d3
				lsr.w	#8,d3
				tst.b	d3
				beq.s	justbright

				move.l	#BrightAnimTable,a4
				move.w	-2(a4,d3.w*2),d2

justbright:		move.w	d2,(a1,d0.w*4)

				move.w	ToUpperBrightness(a3),d2

				blt.s	justbright2
				move.w	d2,d3
				lsr.w	#8,d3
				tst.b	d3
				beq.s	justbright2

				move.l	#BrightAnimTable,a4
				move.w	-2(a4,d3.w*2),d2

justbright2:	move.w	d2,2(a1,d0.w*4)

				bra		doallz

doneallz:		move.l	PointBrights,a2
				move.l	#CurrentPointBrights,a3
justtheone:		move.w	(a5)+,d0
				blt.s	whythehell
				move.w	(a2,d0.w*4),d2

				tst.b	d2
				blt.s	.justbright
				move.w	d2,d3
				lsr.w	#8,d3
				tst.b	d3
				beq.s	.justbright

				move.w	d3,d4
				and.w	#$f,d3
				lsr.w	#4,d4
				add.w	#1,d4

				move.l	#BrightAnimTable,a0
				move.w	-2(a0,d3.w*2),d3
				ext.w	d2
				sub.w	d2,d3
				muls	d4,d3
				asr.w	#4,d3
				add.w	d3,d2

.justbright:	ext.w	d2

				move.w	d2,(a3,d0.w*4)
				move.w	2(a2,d0.w*4),d2

				tst.b	d2
				blt.s	.justbright2
				move.w	d2,d3
				lsr.w	#8,d3
				tst.b	d3
				beq.s	.justbright2

				move.w	d3,d4
				and.w	#$f,d3
				lsr.w	#4,d4
				add.w	#1,d4

				move.l	#BrightAnimTable,a0
				move.w	-2(a0,d3.w*2),d3
				ext.w	d2
				sub.w	d2,d3
				muls	d4,d3
				asr.w	#4,d3
				add.w	d3,d2

.justbright2:
				ext.w	d2

				move.w	d2,2(a3,d0.w*4)

				bra.s	justtheone

whythehell:		cmp.b	#'n',mors
				beq		nosee

				move.l	PLR1_Roompt,FromRoom
				move.l	PLR2_Roompt,ToRoom
				move.w	p1_xoff,Viewerx
				move.w	p1_zoff,Viewerz
				move.l	p1_yoff,d0
				asr.l	#7,d0
				move.w	d0,Viewery
				move.w	p2_xoff,Targetx
				move.w	p2_zoff,Targetz
				move.l	p2_yoff,d0
				asr.l	#7,d0
				move.w	d0,Targety
				move.b	PLR1_StoodInTop,ViewerTop
				move.b	PLR2_StoodInTop,TargetTop
				jsr		CanItBeSeen

				move.l	PLR1_Obj,a0
				move.b	CanSee,d0
				and.b	#2,d0
				move.b	d0,17(a0)
				move.l	PLR2_Obj,a0
				move.b	CanSee,d0
				and.b	#1,d0
				move.b	d0,17(a0)

nosee:			move.l	PLR1_Obj,a0
				move.b	#5,16(a0)
				move.l	PLR2_Obj,a0
				move.b	#11,16(a0)

				move.w	TempFrames,d0
				add.w	d0,p1_holddown
				cmp.w	#30,p1_holddown
				blt.s	oklength
				move.w	#30,p1_holddown
oklength:		tst.b	p1_fire
				bne.s	okstillheld
				sub.w	d0,p1_holddown
				bge.s	okstillheld
				move.w	#0,p1_holddown

okstillheld:	move.w	TempFrames,d0
				add.w	d0,p2_holddown

				cmp.w	#30,p2_holddown
				blt.s	oklength2
				move.w	#30,p2_holddown
oklength2:		tst.b	p2_fire
				bne.s	okstillheld2
				sub.w	d0,p2_holddown
				bge.s	okstillheld2
				move.w	#0,p2_holddown
okstillheld2:

; move.l #PLR1_GunData,a1
; move.w p1_holddown,d0
; move.w #50,10+32*3(a1)
; move.l #PLR2_GunData,a1
; move.w p2_holddown,d0
; move.w #50,10+32*3(a1)


******************************************
******************************************

				move.w	TempFrames,d1
				bgt.s	noze
				moveq	#1,d1
noze:			move.w	PLR1_xoff,d0
				sub.w	OLDX1,d0
				asl.w	#4,d0
				ext.l	d0
				divs	d1,d0
				move.w	d0,XDIFF1
				move.w	PLR2_xoff,d0
				sub.w	OLDX2,d0
				asl.w	#4,d0
				ext.l	d0
				divs	d1,d0
				move.w	d0,XDIFF2
				move.w	PLR1_zoff,d0
				sub.w	OLDZ1,d0
				asl.w	#4,d0
				ext.l	d0
				divs	d1,d0
				move.w	d0,ZDIFF1
				move.w	PLR2_zoff,d0
				sub.w	OLDZ2,d0
				asl.w	#4,d0
				ext.l	d0
				divs	d1,d0
				move.w	d0,ZDIFF2

				cmp.b	#'s',mors
				beq.s	ImPlayer2OhYesIAm
				bsr		USEPLR1
				bra		IWasPlayer1

ImPlayer2OhYesIAm:
				bsr		USEPLR2

IWasPlayer1:	cmp.b	#'s',mors
				beq		drawplayer2

				move.w	#0,scaleval

				move.l	PLR1_xoff,xoff
				move.l	PLR1_yoff,yoff
				move.l	PLR1_zoff,zoff
				move.w	PLR1_angpos,angpos
				move.w	PLR1_cosval,cosval
				move.w	PLR1_sinval,sinval

				move.l	PLR1_ListOfGraphRooms,ListOfGraphRooms
				move.l	PLR1_PointsToRotatePtr,PointsToRotatePtr
				move.l	PLR1_Roompt,Roompt

				bsr		OrderZones
;	jsr          objmoveanim
;	bsr          EnergyBar
;	bsr          AmmoBar

				move.w	#0,leftclip
				move.w	#96,rightclip
				move.w	#0,deftopclip
				move.w	#79,defbotclip
				move.w	#0,topclip
				move.w	#79,botclip

				bsr		DrawDisplay
				bra		nodrawp2

drawplayer2		move.w	#0,scaleval
				move.l	PLR2_xoff,xoff
				move.l	PLR2_yoff,yoff
				move.l	PLR2_zoff,zoff
				move.w	PLR2_angpos,angpos
				move.w	PLR2_cosval,cosval
				move.w	PLR2_sinval,sinval



				move.l	PLR2_ListOfGraphRooms,ListOfGraphRooms
				move.l	PLR2_PointsToRotatePtr,PointsToRotatePtr
				move.l	PLR2_Roompt,Roompt

				bsr		OrderZones
				jsr		objmoveanim
				bsr		EnergyBar
				bsr		AmmoBar

				move.w	#0,leftclip
				move.w	#96,rightclip
				move.w	#0,deftopclip
				move.w	#79,defbotclip
				move.w	#0,topclip
				move.w	#79,botclip

;	bsr          DrawDisplay

nodrawp2:
				jsr		ChunkyConvert			;Chunky conversion

				move.l	PLR2_Roompt,a0
				move.l	#WorkSpace,a1
				clr.l	(a1)
				clr.l	4(a1)
				clr.l	8(a1)
				clr.l	12(a1)
				clr.l	16(a1)
				clr.l	20(a1)
				clr.l	24(a1)
				clr.l	28(a1)

				cmp.b	#'n',mors
				beq.s	plr1only

				lea		ToListOfGraph(a0),a0
.doallrooms:	move.w	(a0),d0
				blt.s	.allroomsdone
				addq	#8,a0
				move.w	d0,d1
				asr.w	#3,d0
				bset	d1,(a1,d0.w)
				bra		.doallrooms
.allroomsdone:

plr1only:		move.l	PLR1_Roompt,a0
				lea		ToListOfGraph(a0),a0
.doallrooms2:
				move.w	(a0),d0
				blt.s	.allroomsdone2
				addq	#8,a0
				move.w	d0,d1
				asr.w	#3,d0
				bset	d1,(a1,d0.w)
				bra		.doallrooms2
.allroomsdone2:

				move.l	ObjectData,a0
				sub.w	#64,a0
.doallobs:		add.w	#64,a0
				move.w	(a0),d0
				blt.s	.allobsdone
				move.w	12(a0),d0
				blt.s	.doallobs
				move.w	d0,d1
				asr.w	#3,d0
				btst	d1,(a1,d0.w)
				beq.s	.doallobs
				or.b	#127,worry(a0)
				bra.s	.doallobs
.allobsdone:
; move.l #brightentab,a0
; move.l frompt,a3
; adda.w #(4*33)+(104*4*20),a3
; move.w #20,d7
; move.w #20,d6
;horl:
; move.w d6,d5
; move.l a3,a1
;vertl
; move.w (a1),d0
; move.w (a0,d0.w*2),(a1)
; addq #4,a1
; dbra d5,vertl
; adda.w #104*4,a3
; dbra d7,horl

				move.l	#$dff000,a6

; move.w #$300,col0(a6)

				move.l	#KeyMap,a5
				tst.b	$45(a5)
				beq.s	noend

blarg:			cmp.b	#'s',mors
				beq		plr2quit

				st		MASTERQUITTING
				bra		noend

plr2quit:		st		SLAVEQUITTING
noend:			tst.b	MASTERQUITTING
				beq.s	.noquit
				tst.b	SLAVEQUITTING
				bne		endnomusic
.noquit			cmp.b	#'n',mors
				bne.s	.noexit
				move.l	PLR1_Roompt,a0
				move.w	(a0),d0
				move.w	LevelSelected,d1
				move.l	#ENDZONES,a0
				cmp.w	(a0,d1.w*2),d0
				beq		end
.noexit:		tst.w	PLR1_energy
				ble		end
				tst.w	PLR2_energy
				ble		end

; move.l SwitchData,a0
; tst.b 24+8(a0)
; bne end

				JSR		STOPTIMER

				bra		mainloop

MASTERQUITTING:
				dc.b	0
SLAVEQUITTING:
				dc.b	0
MASTERPAUSE:	dc.b	0
SLAVEPAUSE:		dc.b	0

				INCLUDE	pauseopts.s

ENDZONES:
; LEVEL 1
				dc.w	132
; LEVEL 2
				dc.w	149
; LEVEL 3
				dc.w	155
; LEVEL 4
				dc.w	107
; LEVEL 5
				dc.w	67
; LEVEL 6
				dc.w	132
; LEVEL 7
				dc.w	203
; LEVEL 8
				dc.w	166
; LEVEL 9
				dc.w	118
; LEVEL 10
				dc.w	102
; LEVEL 11
				dc.w	103
; LEVEL 12
				dc.w	2
; LEVEL 13
				dc.w	98
; LEVEL 14
				dc.w	0
; LEVEL 15
				dc.w	148
; LEVEL 16
				dc.w	103

***************************************************************************
***************************************************************************
****************** End of Main Loop here **********************************
***************************************************************************
***************************************************************************

putinsmallscr:
putinlargescr:
				rts


READCONTROLS:
				dc.w	0

BollocksRoom:
				dc.w	-1
				ds.l	50

GUNYOFFS:		dc.w	20
				dc.w	20
				dc.w	0
				dc.w	20
				dc.w	20
				dc.w	0
				dc.w	0
				dc.w	20

;----------------------------------------------------------------------------

USEPLR1:		move.l	PLR1_Obj,a0
				move.l	ObjectPoints,a1
				move.l	#ObjRotated,a2
				move.w	(a0),d0
				move.l	PLR1_xoff,(a1,d0.w*8)
				move.l	PLR1_zoff,4(a1,d0.w*8)
				move.l	PLR1_Roompt,a1

				moveq	#0,d2
				move.b	damagetaken(a0),d2
				beq		.notbeenshot
				move.w	#$f00,hitcol
				move.w	#$f00,hitcol2
				sub.w	d2,PLR1_energy
				movem.l	d0-d7/a0-a6,-(a7)
				move.b	#$fb,IDNUM
				move.w	#19,Samplenum
				clr.b	notifplaying
				move.w	#0,Noisex
				move.w	#0,Noisez
				move.w	#100,Noisevol
				jsr		MakeSomeNoise

				movem.l	(a7)+,d0-d7/a0-a6

.notbeenshot	move.b	#0,damagetaken(a0)
				move.b	PLR1_energy+1,numlives(a0)

				move.b	PLR1_StoodInTop,ObjInTop(a0)

				move.w	(a1),12(a0)
				move.w	(a1),d2
				move.l	#ZoneBrightTable,a1
				move.l	(a1,d2.w*4),d2
				tst.b	PLR1_StoodInTop
				bne.s	.okinbott
				swap	d2
.okinbott:		move.w	d2,2(a0)

				move.l	p1_yoff,d0
				move.l	p1_height,d1
				asr.l	#1,d1
				add.l	d1,d0
				asr.l	#7,d0
				move.w	d0,4(a0)

***********************************

				move.l	PLR2_Obj,a0

				move.w	PLR2_angpos,d0
				and.w	#8190,d0
				move.w	d0,Facing(a0)

				jsr		ViewpointToDraw
				asl.w	#2,d0
				moveq	#0,d1
				move.b	p2_bobble,d1
				not.b	d1
				lsr.b	#3,d1
				and.b	#$3,d1
				add.w	d1,d0
				move.w	d0,10(a0)
				move.w	#10,8(a0)

				move.l	ObjectPoints,a1
				move.l	#ObjRotated,a2
				move.w	(a0),d0
				move.l	PLR2_xoff,(a1,d0.w*8)
				move.l	PLR2_zoff,4(a1,d0.w*8)
				move.l	PLR2_Roompt,a1

				moveq	#0,d2
				move.b	damagetaken(a0),d2
				beq		.notbeenshot2
				sub.w	d2,PLR2_energy
.notbeenshot2
				move.b	#0,damagetaken(a0)
				move.b	PLR2_energy+1,numlives(a0)

				move.b	PLR2_StoodInTop,ObjInTop(a0)

				move.w	(a1),12(a0)
				move.w	(a1),d2
				move.l	#ZoneBrightTable,a1
				move.l	(a1,d2.w*4),d2
				tst.b	PLR2_StoodInTop
				bne.s	.okinbott2
				swap	d2
.okinbott2:		move.w	d2,2(a0)

				move.l	p2_yoff,d0
				move.l	p2_height,d1
				asr.l	#1,d1
				add.l	d1,d0
				asr.l	#7,d0
				move.w	d0,4(a0)

**********************************


				move.l	PLR1_Obj,a0
				move.w	#-1,12+128(a0)

				rts

DRAWINGUN:		move.l	#Objects+9*16,a0
				move.l	4(a0),a5				; ptr
				move.l	8(a0),a2				; frames
				move.l	12(a0),a4				; pal
				move.l	(a0),a0					; wad

				move.l	#GunAnims,a1
				move.l	(a1,d0.w*8),a1
				move.w	(a1,d1.w*2),d5			; frame of anim

				move.l	#GUNYOFFS,a1
				move.w	(a1,d0.w*2),d7			; yoff
				move.l	frompt,a6
				move.w	d7,d6
				muls	#96*2,d6
				add.l	d6,a6					; screen pointer

				asl.w	#2,d0
				add.w	d5,d0					; frame
				move.w	(a2,d0.w*4),d1			; xoff

				lea		(a5,d1.w),a5			; right ptr

				move.w	#31,d0
				bsr		DRAWCHUNK
				addq.w	#4,a6
				move.w	#31,d0
				bsr		DRAWCHUNK
				addq.w	#4,a6
				move.w	#31,d0
				bsr		DRAWCHUNK
				rts


DRAWCHUNK:		move.w	#78,d3
				sub.w	d7,d3
				move.l	a6,a3
				move.b	(a5),d2
				move.l	(a5)+,d1
				bne.s	.noblank
				addq	#4,a6
				dbra	d0,DRAWCHUNK
				rts

.noblank:		and.l	#$ffffff,d1
				lea		(a0,d1.l),a1
				cmp.b	#1,d2
				bgt.s	thirdd
				beq.s	secc
.drawdown:		move.w	(a1)+,d2
				and.w	#%11111,d2
				beq.s	.itsblank
				move.w	(a4,d2.w*2),(a3)
.itsblank		add.w	#96*2,a3
				dbra	d3,.drawdown

				addq	#4,a6
				dbra	d0,DRAWCHUNK
				rts

secc:
.drawdown:		move.w	(a1)+,d2
				lsr.w	#5,d2
				and.w	#%11111,d2
				beq.s	.itsblank
				move.w	(a4,d2.w*2),(a3)
.itsblank		add.w	#96*2,a3
				dbra	d3,.drawdown

				addq	#4,a6
				dbra	d0,DRAWCHUNK
				rts

thirdd:
.drawdown:		move.b	(a1),d2
				addq	#2,a1
				lsr.b	#2,d2
				and.w	#%11111,d2
				beq.s	.itsblank
				move.w	(a4,d2.w*2),(a3)
.itsblank		add.w	#96*2,a3
				dbra	d3,.drawdown

				addq	#4,a6
				dbra	d0,DRAWCHUNK
				rts

;----------------------------------------------------------------------------

USEPLR2:		move.l	PLR2_Obj,a0
				move.l	ObjectPoints,a1
				move.l	#ObjRotated,a2
				move.w	(a0),d0
				move.l	PLR2_xoff,(a1,d0.w*8)
				move.l	PLR2_zoff,4(a1,d0.w*8)
				move.l	PLR2_Roompt,a1

				moveq	#0,d2
				move.b	damagetaken(a0),d2
				beq		.notbeenshot
				move.w	#$f00,hitcol
				move.w	#$f00,hitcol2
				sub.w	d2,PLR2_energy
				movem.l	d0-d7/a0-a6,-(a7)
				move.w	#19,Samplenum
				clr.b	notifplaying
				move.b	#$fb,IDNUM
				move.w	#0,Noisex
				move.w	#0,Noisez
				move.w	#100,Noisevol
				jsr		MakeSomeNoise

				movem.l	(a7)+,d0-d7/a0-a6

.notbeenshot	move.b	#0,damagetaken(a0)
				move.b	PLR2_energy+1,numlives(a0)

				move.b	PLR2_StoodInTop,ObjInTop(a0)

				move.w	(a1),12(a0)
				move.w	(a1),d2
				move.l	#ZoneBrightTable,a1
				move.l	(a1,d2.w*4),d2
				tst.b	PLR2_StoodInTop
				bne.s	.okinbott
				swap	d2
.okinbott:		move.w	d2,2(a0)

				move.l	PLR2_yoff,d0
				move.l	p2_height,d1
				asr.l	#1,d1
				add.l	d1,d0
				asr.l	#7,d0
				move.w	d0,4(a0)

***********************************

				move.l	PLR1_Obj,a0

				move.w	PLR1_angpos,d0
				and.w	#8190,d0
				move.w	d0,Facing(a0)

				jsr		ViewpointToDraw
				asl.w	#2,d0
				moveq	#0,d1
				move.b	p1_bobble,d1
				not.b	d1
				lsr.b	#3,d1
				and.b	#$3,d1
				add.w	d1,d0
				move.w	d0,10(a0)
				move.w	#10,8(a0)

				move.l	ObjectPoints,a1
				move.l	#ObjRotated,a2
				move.w	(a0),d0
				move.l	PLR1_xoff,(a1,d0.w*8)
				move.l	PLR1_zoff,4(a1,d0.w*8)
				move.l	PLR1_Roompt,a1

				moveq	#0,d2
				move.b	damagetaken(a0),d2
				beq		.notbeenshot2
				sub.w	d2,PLR1_energy
.notbeenshot2
				move.b	#0,damagetaken(a0)
				move.b	PLR1_energy+1,numlives(a0)

				move.b	PLR1_StoodInTop,ObjInTop(a0)

				move.w	(a1),12(a0)
				move.w	(a1),d2
				move.l	#ZoneBrightTable,a1
				move.l	(a1,d2.w*4),d2
				tst.b	PLR1_StoodInTop
				bne.s	.okinbott2
				swap	d2
.okinbott2:		move.w	d2,2(a0)

				move.l	PLR1_yoff,d0
				move.l	p1_height,d1
				asr.l	#1,d1
				add.l	d1,d0
				asr.l	#7,d0
				move.w	d0,4(a0)

**********************************

				move.l	PLR2_Obj,a0
				move.w	#-1,12+64(a0)

				rts


GunSelected:	dc.b	0
				EVEN

GunAnims:		dc.l	MachineAnim,3
				dc.l	PlasmaAnim,5
				dc.l	RocketAnim,5
				dc.l	FlameThrowerAnim,5
				dc.l	GrenadeAnim,12
				dc.l	0,0
				dc.l	0,0
				dc.l	ShotGunAnim,12+19+11+20+1

MachineAnim:	dc.w	0,1,2,3
PlasmaAnim:		dc.w	0,1,2,3,3,3
RocketAnim:		dc.w	0,1,2,3,3,3
FlameThrowerAnim:
				dc.w	0,1,2,3,3,3
GrenadeAnim:	dc.w	0,1,1,1,1
				dc.w	2,2,2,2,3
				dc.w	3,3,3
ShotGunAnim:	dc.w	0
				dcb.w	12,2
				dcb.w	19,1
				dcb.w	11,2
				dcb.w	20,0
				dc.w	3

GunData:		dc.l	0

				INCLUDE	gundata.s



Path:
; INCBIN "testpath"
endpath:
pathpt:			dc.l	Path


PLR1KEYS:		dc.b	0
PLR1PATH:		dc.b	0
PLR1MOUSE:		dc.b	-1
PLR1JOY:		dc.b	0
PLR2KEYS:		dc.b	0
PLR2PATH:		dc.b	0
PLR2MOUSE:		dc.b	-1
PLR2JOY:		dc.b	0

				EVEN

PLR1_bobble:	dc.w	0
PLR2_bobble:	dc.w	0
xwobble:		dc.l	0
xwobxoff:		dc.w	0

xwobzoff:		dc.w	0


DRAWNGRAPHTOP

tstzone:		dc.l	0
CollId:			dc.w	0


fillscrnwater:
				dc.w	0
DONTDOGUN:		dc.w	0

;----------------------------------------------------------------------------

DrawDisplay:	move.l	drawpt,a0
				move.w	#2560-1,d0
				moveq	#0,d1
.clrloop:		move.l	d1,(a0)+
				dbf		d0,.clrloop

				clr.b	fillscrnwater

				move.l	#SineTable,a0
				move.w	angpos,d0
				move.w	(a0,d0.w),d6
				adda.w	#2048,a0
				move.w	(a0,d0.w),d7
				move.w	d6,sinval
				move.w	d7,cosval

				move.l	#KeyMap,a5
				moveq	#0,d5
				move.b	look_behind_key,d5
				tst.b	(a5,d5.w)
				sne		DONTDOGUN
				beq.s	.nolookback
				neg.w	cosval
				neg.w	sinval

.nolookback:	move.l	yoff,d0
				asr.l	#8,d0
				move.w	d0,d1
				add.w	#256-32,d1
				and.w	#255,d1
				move.w	d1,wallyoff
				asl.w	#2,d0
				move.w	d0,flooryoff

				move.w	xoff,d6
				move.w	d6,d3
				asr.w	#1,d3
				add.w	d3,d6
				asr.w	#1,d6
				move.w	d6,xoff34

				move.w	zoff,d6
				move.w	d6,d3
				asr.w	#1,d3
				add.w	d3,d6
				asr.w	#1,d6
				move.w	d6,zoff34

				bsr		RotateLevelPts
				bsr		RotateObjectPts
				bsr		CalcPLR1InLine

				cmp.b	#'n',mors
				bne.s	doplr2too
				move.l	PLR2_Obj,a0
				move.w	#-1,12(a0)
				move.w	#-1,GraphicRoom(a0)
				bra		noplr2either

doplr2too:		bsr		CalcPLR2InLine
noplr2either:

				move.l	endoflist,a0
subroomloop:	move.w	-(a0),d7
				blt		jumpoutofrooms

; bsr setlrclip
; move.w leftclip,d0
; cmp.w rightclip,d0
; bge subroomloop
				move.l	a0,-(a7)

				move.l	ZoneAdds,a0
				move.l	(a0,d7.w*4),a0
				add.l	LevelDataPtr,a0
				move.l	ToZoneRoof(a0),SplitHeight
				move.l	a0,ROOMBACK

				move.l	ZoneGraphAdds,a0
				move.l	4(a0,d7.w*8),a2
				move.l	(a0,d7.w*8),a0

				add.l	LevelGfxPtr,a0
				add.l	LevelGfxPtr,a2
				move.l	a2,ThisRoomToDraw+4
				move.l	a0,ThisRoomToDraw

				move.l	ListOfGraphRooms,a1

finditit:		tst.w	(a1)
				blt		nomoretodoatall
				cmp.w	(a1),d7
				beq		outoffind
				adda.w	#8,a1
				bra		finditit

outoffind:		move.l	a1,-(a7)


				move.w	#0,leftclip
				move.w	#96,rightclip
				moveq	#0,d7
				move.w	2(a1),d7
				blt.s	outofrcliplop
				move.l	LevelClipsPtr,a0
				lea		(a0,d7.l*2),a0

				tst.w	(a0)
				blt		outoflcliplop

				bsr		NEWsetlclip

intolcliplop:
	; clips
				tst.w	(a0)
				blt		outoflcliplop

				bsr		NEWsetlclip
				bra		intolcliplop

outoflcliplop:

				addq	#2,a0

				tst.w	(a0)
				blt		outofrcliplop

				bsr		NEWsetrclip

intorcliplop:
	; clips
				tst.w	(a0)
				blt		outofrcliplop

				bsr		NEWsetrclip
				bra		intorcliplop

outofrcliplop:


				move.w	leftclip,d0
				cmp.w	#96,d0
				bge		dontbothercantseeit
				move.w	rightclip,d1
				blt		dontbothercantseeit
				cmp.w	d1,d0
				bge		dontbothercantseeit

				move.l	yoff,d0
				cmp.l	SplitHeight,d0
				blt		botfirst

				move.l	ThisRoomToDraw+4,a0
				cmp.l	LevelGfxPtr,a0
				beq.s	noupperroom
				st		DOUPPER

				move.l	ROOMBACK,a1
				move.l	ToUpperRoof(a1),TOPOFROOM
				move.l	ToUpperFloor(a1),BOTOFROOM

				move.l	#CurrentPointBrights+2,PointBrightsPtr
				bsr		dothisroom
noupperroom:	move.l	ThisRoomToDraw,a0
				clr.b	DOUPPER
				move.l	#CurrentPointBrights,PointBrightsPtr

				move.l	ROOMBACK,a1
				move.l	ToZoneRoof(a1),d0
				move.l	d0,TOPOFROOM
				move.l	ToZoneFloor(a1),d1
				move.l	d1,BOTOFROOM

				move.l	ToZoneWater(a1),d2
				cmp.l	yoff,d2
				blt.s	.abovefirst
				move.l	d2,BEFOREWATTOP
				move.l	d1,BEFOREWATBOT
				move.l	d2,AFTERWATBOT
				move.l	d0,AFTERWATTOP
				bra.s	.belowfirst
.abovefirst:	move.l	d0,BEFOREWATTOP
				move.l	d2,BEFOREWATBOT
				move.l	d1,AFTERWATBOT
				move.l	d2,AFTERWATTOP
.belowfirst:	bsr		dothisroom

				bra		dontbothercantseeit
botfirst:		move.l	ThisRoomToDraw,a0
				clr.b	DOUPPER
				move.l	#CurrentPointBrights,PointBrightsPtr

				move.l	ROOMBACK,a1
				move.l	ToZoneRoof(a1),d0
				move.l	d0,TOPOFROOM
				move.l	ToZoneFloor(a1),d1
				move.l	d1,BOTOFROOM

				move.l	ToZoneWater(a1),d2
				cmp.l	yoff,d2
				blt.s	.abovefirst
				move.l	d2,BEFOREWATTOP
				move.l	d1,BEFOREWATBOT
				move.l	d2,AFTERWATBOT
				move.l	d0,AFTERWATTOP
				bra.s	.belowfirst
.abovefirst:	move.l	d0,BEFOREWATTOP
				move.l	d2,BEFOREWATBOT
				move.l	d1,AFTERWATBOT
				move.l	d2,AFTERWATTOP
.belowfirst:	bsr		dothisroom
				move.l	ThisRoomToDraw+4,a0
				cmp.l	LevelGfxPtr,a0
				beq.s	noupperroom2
				move.l	#CurrentPointBrights+2,PointBrightsPtr

				move.l	ROOMBACK,a1
				move.l	ToUpperRoof(a1),TOPOFROOM
				move.l	ToUpperFloor(a1),BOTOFROOM

				st		DOUPPER
				bsr		dothisroom
noupperroom2:

dontbothercantseeit:
pastemp:		move.l	(a7)+,a1
				move.l	ThisRoomToDraw,a0
				move.w	(a0),d7

				adda.w	#8,a1
				bra		finditit

nomoretodoatall:

				move.l	(a7)+,a0

				bra		subroomloop

jumpoutofrooms:
				tst.b	DONTDOGUN
				bne		NOGUNLOOK

				cmp.b	#'s',mors
				beq.s	drawslavegun

				moveq	#0,d0
				move.b	PLR1_GunSelected,d0
				moveq	#0,d1
				move.b	PLR1_GunFrame,d1
;	bsr          DRAWINGUN
				bra		drawngun

drawslavegun	moveq	#0,d0
				move.b	PLR2_GunSelected,d0
				moveq	#0,d1
				move.b	PLR2_GunFrame,d1
;	bsr          DRAWINGUN

drawngun:
NOGUNLOOK:		rts

				moveq	#0,d1
				move.b	PLR1_GunFrame,d1
				sub.w	TempFrames,d1
				bgt.s	.nn
				moveq	#0,d1
.nn				move.b	d1,PLR1_GunFrame

				ble.s	.donefire
				sub.b	#1,PLR1_GunFrame
.donefire:		moveq	#0,d1
				move.b	PLR2_GunFrame,d1
				sub.w	TempFrames,d1
				bgt.s	.nn2
				moveq	#0,d1
.nn2			move.b	d2,PLR2_GunFrame

				ble.s	.donefire2
				sub.b	#1,PLR2_GunFrame
.donefire2:		move.w	#3,d5
				tst.b	fillscrnwater
				beq		nowaterfull
				bgt		oknothalf
				moveq	#1,d5
oknothalf:		bclr.b	#1,$bfe001

				move.l	#brightentab,a2
				moveq	#0,d2
				move.l	frompt,a0
				add.l	#96*60,a0

				move.w	#31,d0
fw:				move.w	d5,d1
				move.l	a0,a1
fwd:
val				SET		96*19
				REPT	20
				and.w	#$ff,val(a1)
val				SET		val-96
				ENDR
				sub.l	#96*20,a1
				dbra	d1,fwd
				addq	#4,a0
				dbra	d0,fw

				addq	#4,a0

				move.w	#31,d0
sw:				move.w	d5,d1
				move.l	a0,a1
swd:
val				SET		96*19
				REPT	20
				and.w	#$ff,val(a1)
val				SET		val-96
				ENDR
				sub.l	#96*20,a1
				dbra	d1,swd
				addq	#4,a0
				dbra	d0,sw

				addq	#4,a0

				move.w	#31,d0
tw:				move.w	d5,d1
				move.l	a0,a1
twd:
val				SET		96*19
				REPT	20
				and.w	#$ff,val(a1)
val				SET		val-96
				ENDR
				sub.l	#96*20,a1
				dbra	d1,twd
				addq	#4,a0
				dbra	d0,tw

				rts

nowaterfull:	bset.b	#1,$bfe001
				rts

TempBuffer:		ds.l	100

ClipTable:		ds.l	30
EndOfClipPt:	dc.l	0
DOUPPER:		dc.w	0

dothisroom		move.w	(a0)+,d0
				move.w	d0,currzone
				move.l	#ZoneBrightTable,a1
				move.l	(a1,d0.w*4),d1
				tst.b	DOUPPER
				bne.s	.okbot
				swap	d1
.okbot:			move.w	d1,ZoneBright

polyloop:		move.w	(a0)+,d0
				blt		jumpoutofloop
				beq		itsawall
				cmp.w	#3,d0
				beq		itsasetclip
				blt		itsafloor
				cmp.w	#4,d0
				beq		itsanobject
				cmp.w	#5,d0
				beq.w	itsanarc
				cmp.w	#6,d0
				beq		itsalightbeam
				cmp.w	#7,d0
				beq.s	itswater
				cmp.w	#9,d0
				ble		itsachunkyfloor
				cmp.w	#11,d0
				ble.w	itsabumpyfloor
				cmp.w	#12,d0
				beq.s	itsbackdrop
				cmp.w	#13,d0
				beq.s	itsaseewall

				bra		polyloop

itsaseewall:	st		seethru
				jsr		itsawalldraw
				bra		polyloop

itsbackdrop:
;	jsr          putinbackdrop
				bra		polyloop

itswater:		move.w	#3,d0
				clr.b	gourfloor
				move.l	#FloorLine,LineToUse
				st		usewater
				clr.b	usebumps
				jsr		itsafloordraw
				bra		polyloop

itsanarc:
;	jsr          CurveDraw
				bra		polyloop

itsanobject:
;	jsr          ObjDraw
				bra		polyloop

itsalightbeam:
;	jsr          LightDraw
				bra		polyloop

itsabumpyfloor:
				sub.w	#9,d0
				st		usebumps
				st		smoothbumps
				clr.b	usewater
				move.l	#BumpLine,LineToUse
				jsr		itsafloordraw
				bra		polyloop

itsachunkyfloor:
				subq.w	#7,d0
				st		usebumps
				sub.w	#12,topclip
; add.w #10,botclip
				clr.b	smoothbumps
				clr.b	usewater
				move.l	#BumpLine,LineToUse
				jsr		itsafloordraw
				add.w	#12,topclip
; sub.w #10,botclip
				bra		polyloop

itsafloor:		move.l	THEFLOORLINE,LineToUse
	; 1,2 = floor/roof
				clr.b	usewater
				clr.b	usebumps
				move.b	GOURSEL,gourfloor
				jsr		itsafloordraw
				bra		polyloop

itsasetclip:	bra		polyloop

itsawall:		clr.b	seethru
;	move.l #stripbuffer,a1
				jsr		itsawalldraw
				bra		polyloop

jumpoutofloop:
				rts

GOURSEL:		dc.w	0
ThisRoomToDraw:
				dc.l	0,0
SplitHeight:	dc.l	0

				INCLUDE	orderzones.s

ReadMouse:		move.l	#$dff000,a6
				clr.l	d0
				clr.l	d1
				move.w	$a(a6),d0
				lsr.w	#8,d0
				ext.l	d0
				move.w	d0,d3
				move.w	oldmy,d2
				sub.w	d2,d0

				cmp.w	#127,d0
				blt		nonegy
				move.w	#255,d1
				sub.w	d0,d1
				move.w	d1,d0
				neg.w	d0
nonegy:			cmp.w	#-127,d0
				bge		nonegy2
				move.w	#255,d1
				add.w	d0,d1
				move.w	d1,d0
nonegy2:		add.b	d0,d2
				add.w	d0,oldy2
				move.w	d2,oldmy
				move.w	d2,d0

				move.w	oldy2,d0
				move.w	d0,ymouse

				clr.l	d0
				clr.l	d1
				move.w	$a(a6),d0
				ext.w	d0
				ext.l	d0
				move.w	d0,d3
				move.w	oldmx,d2
				sub.w	d2,d0

				cmp.w	#127,d0
				blt		nonegx
				move.w	#255,d1
				sub.w	d0,d1
				move.w	d1,d0
				neg.w	d0
nonegx:			cmp.w	#-127,d0
				bge		nonegx2
				move.w	#255,d1
				add.w	d0,d1
				move.w	d1,d0
nonegx2:		add.b	d0,d2
				move.w	d0,d1
				move.w	d2,oldmx

				move.w	#$0,$dff034
				btst	#2,$dff016
				beq.w	noturn

				add.w	d0,oldx2
				move.w	oldx2,d0
				and.w	#2047,d0
				move.w	d0,oldx2

				asl.w	#2,d0
				sub.w	prevx,d0
				add.w	d0,prevx
				add.w	d0,angpos
				move.w	#0,lrs
				rts

noturn:
; got to move lr instead.

; d1 = speed moved l/r

				move.w	d1,lrs

				rts

lrs:			dc.w	0
prevx:			dc.w	0

angpos:			dc.w	0
mang:			dc.w	0
oldymouse:		dc.w	0
xmouse:			dc.w	0
ymouse:			dc.w	0
oldx2:			dc.w	0
oldmx:			dc.w	0
oldmy:			dc.w	0
oldy2:			dc.w	0

RotateLevelPts:

				move.w	sinval,d6
				swap	d6
				move.w	cosval,d6

				move.l	PointsToRotatePtr,a0
				move.l	Points,a3
				move.l	#Rotated,a1
				move.l	#OnScreen,a2
				move.w	xoff,d4
				move.w	zoff,d5

; move.w #$c40,$dff106
; move.w #$f00,$dff180

pointrotlop:	move.w	(a0)+,d7
				blt.w	outofpointrot

				move.w	(a3,d7*4),d0
				sub.w	d4,d0
				move.w	d0,d2
				move.w	2(a3,d7*4),d1
				sub.w	d5,d1
				muls	d6,d2
				swap	d6
				move.w	d1,d3
				muls	d6,d3
				sub.l	d3,d2
				add.l	d2,d2
				swap	d2
				ext.l	d2
				asl.l	#7,d2
				add.l	xwobble,d2
				move.l	d2,(a1,d7*8)

				muls	d6,d0
				swap	d6
				muls	d6,d1
				add.l	d0,d1
				asl.l	#2,d1
				swap	d1
				move.l	d1,4(a1,d7*8)

				tst.w	d1
				bgt.s	ptnotbehind
				tst.w	d2
				bgt.s	onrightsomewhere
				move.w	#0,d2
				bra		putin
onrightsomewhere:
				move.w	#96,d2
				bra		putin
ptnotbehind:	divs	d1,d2
				add.w	#47,d2
putin:			move.w	d2,(a2,d7*2)

				bra		pointrotlop
outofpointrot:

; move.w #$c40,$dff106
; move.w #$ff0,$dff180

				rts

PLR1_ObjDists
				ds.w	250
PLR2_ObjDists
				ds.w	250

CalcPLR1InLine:

				move.w	PLR1_sinval,d5
				move.w	PLR1_cosval,d6
				move.l	ObjectData,a4
				move.l	ObjectPoints,a0
				move.w	NumObjectPoints,d7
				move.l	#PLR1_ObsInLine,a2
				move.l	#PLR1_ObjDists,a3

.objpointrotlop:

				move.w	(a0),d0
				sub.w	PLR1_xoff,d0
				move.w	4(a0),d1
				addq	#8,a0

				tst.w	12(a4)
				blt		.noworkout

				moveq	#0,d2
				move.b	16(a4),d2
				move.l	#ColBoxTable,a6
				lea		(a6,d2.w*8),a6

				sub.w	PLR1_zoff,d1
				move.w	d0,d2
				muls	d6,d2
				move.w	d1,d3
				muls	d5,d3
				sub.l	d3,d2
				add.l	d2,d2

				bgt.s	.okh
				neg.l	d2
.okh:			swap	d2

				muls	d5,d0
				muls	d6,d1
				add.l	d0,d1
				asl.l	#2,d1
				swap	d1
				moveq	#0,d3

				tst.w	d1
				ble.s	.notinline
				asr.w	#1,d2
				cmp.w	(a6),d2
				bgt.s	.notinline

				st		d3
.notinline		move.b	d3,(a2)+

				move.w	d1,(a3)+

				add.w	#64,a4
				dbra	d7,.objpointrotlop

				rts

.noworkout:		move.b	#0,(a2)+
				move.w	#0,(a3)+
				add.w	#64,a4
				dbra	d7,.objpointrotlop
				rts


CalcPLR2InLine:

				move.w	PLR2_sinval,d5
				move.w	PLR2_cosval,d6
				move.l	ObjectData,a4
				move.l	ObjectPoints,a0
				move.w	NumObjectPoints,d7
				move.l	#PLR2_ObsInLine,a2
				move.l	#PLR2_ObjDists,a3

.objpointrotlop:

				move.w	(a0),d0
				sub.w	PLR2_xoff,d0
				move.w	4(a0),d1
				addq	#8,a0

				tst.w	12(a4)
				blt		.noworkout

				moveq	#0,d2
				move.b	16(a4),d2
				move.l	#ColBoxTable,a6
				lea		(a6,d2.w*8),a6

				sub.w	PLR2_zoff,d1
				move.w	d0,d2
				muls	d6,d2
				move.w	d1,d3
				muls	d5,d3
				sub.l	d3,d2
				add.l	d2,d2

				bgt.s	.okh
				neg.l	d2
.okh:			swap	d2

				muls	d5,d0
				muls	d6,d1
				add.l	d0,d1
				asl.l	#2,d1
				swap	d1
				moveq	#0,d3

				tst.w	d1
				ble.s	.notinline
				asr.w	#1,d2
				cmp.w	(a6),d2
				bgt.s	.notinline

				st		d3
.notinline		move.b	d3,(a2)+

				move.w	d1,(a3)+

				add.w	#64,a4
				dbra	d7,.objpointrotlop

				rts

.noworkout:		move.w	#0,(a3)+
				move.b	#0,(a2)+
				add.w	#64,a4
				dbra	d7,.objpointrotlop
				rts


RotateObjectPts:

				move.w	sinval,d5
				move.w	cosval,d6

				move.l	ObjectData,a4
				move.l	ObjectPoints,a0
				move.w	NumObjectPoints,d7
				move.l	#ObjRotated,a1

.objpointrotlop:

				move.w	(a0),d0
				sub.w	xoff,d0
				move.w	4(a0),d1
				addq	#8,a0

				tst.w	12(a4)
				blt		.noworkout

				sub.w	zoff,d1
				move.w	d0,d2
				muls	d6,d2
				move.w	d1,d3
				muls	d5,d3
				sub.l	d3,d2


				add.l	d2,d2
				swap	d2
				move.w	d2,(a1)+

				muls	d5,d0
				muls	d6,d1
				add.l	d0,d1
				asl.l	#2,d1
				swap	d1
				moveq	#0,d3

				move.w	d1,(a1)+
				ext.l	d2
				asl.l	#7,d2
				add.l	xwobble,d2
				move.l	d2,(a1)+
				sub.l	xwobble,d2

				add.w	#64,a4
				dbra	d7,.objpointrotlop

				rts

.noworkout:		move.l	#0,(a1)+
				move.l	#0,(a1)+
				add.w	#64,a4
				dbra	d7,.objpointrotlop
				rts

LightDraw:		move.w	(a0)+,d0
				move.w	(a0)+,d1
				move.l	#Rotated,a1
				move.w	6(a1,d0.w*8),d2
				ble.s	oneendbehind
				move.w	6(a1,d1.w*8),d3
				bgt.s	bothendsinfront

oneendbehind:
				rts
bothendsinfront:

				move.l	#OnScreen,a2
				move.w	(a2,d0.w*2),d0
				bge.s	okleftend
				moveq	#0,d0
okleftend:		move.w	(a2,d1.w*2),d1
				bgt.s	somevis
				rts
somevis:		cmp.w	#95,d0
				ble.s	somevis2
				rts
somevis2:		cmp.w	#95,d1
				ble.s	okrightend
				move.w	#95,d1
okrightend:		sub.w	d0,d1
				blt.w	wrongbloodywayround
				move.l	#brightentab,a4
				move.l	#objintocop,a1
				lea		(a1,d0.w*2),a1

				move.l	frompt,a3
				move.w	#96*2,d6
				move.w	#79,d2
lacross:		move.w	d2,d3
				move.l	a3,a2
				adda.w	(a1)+,a2
ldown:			add.w	d6,a2
				move.w	(a2),d7
				move.w	(a4,d7.w*2),(a2)
				dbra	d3,ldown
				dbra	d1,lacross

wrongbloodywayround:

				rts

FaceToPlace:	dc.w	0

Cheese:			dc.w	4,15

FacesList:		dc.w	0,4*4
				dc.w	1,2*4
				dc.w	0,2*4
				dc.w	2,2*4
				dc.w	0,2*4
				dc.w	1,3*4
				dc.w	0,2*4
				dc.w	2,3*4
				dc.w	0,5*4
				dc.w	1,2*4
				dc.w	0,2*4
				dc.w	2,2*4
				dc.w	0,2*4
				dc.w	1,2*4
				dc.w	0,2*4
				dc.w	2,3*4
				dc.w	0,1*4
				dc.w	1,3*4
				dc.w	0,1*4
				dc.w	2,3*4
				dc.w	0,1*4

EndOfFacesList:

FacesPtr:		dc.l	FacesList
FacesCounter:
				dc.w	0
Expression:		dc.w	0

PlaceFace:		move.w	FacesCounter,d0
				subq	#1,d0
				bgt.w	NoNewFace

				move.l	FacesPtr,a0

				move.w	2(a0),d0
				move.w	(a0),Expression
				addq	#4,a0
				cmp.l	#EndOfFacesList,a0
				blt.s	NotFirstFace

				move.l	#FacesList,a0

NotFirstFace	move.l	a0,FacesPtr

NoNewFace:		move.w	d0,FacesCounter

				Move.w	FaceToPlace,d0
				muls	#5,d0
				add.w	Expression,d0
				move.l	#FacePlace+10,a0
				move.l	#Faces,a1
				muls	#(4*32*5),d0
				adda.w	d0,a1
				move.w	#4,d0
				move.w	#24,d1

				move.w	#4,d3
bitplaneloop:
				move.w	#31,d2
PlaceFaceToPlaceInFacePlaceLoop:
				move.l	(a1),(a0)
				adda.w	d0,a1
				adda.w	d1,a0
				dbra	d2,PlaceFaceToPlaceInFacePlaceLoop
				dbra	d3,bitplaneloop

				rts

Energy:			dc.w	191
OldEnergy:		dc.w	191
Ammo:			dc.w	63
OldAmmo:		dc.w	63

FullEnergy:		move.w	#127,Energy
				move.w	#127,OldEnergy
				move.l	#health,a0
				move.l	#borders,a1
				add.l	#25*8*2+6,a1
				lea		2592(a1),a2
				move.w	#127,d0
PutInFull:		move.b	(a0)+,(a1)
				move.b	(a0)+,8(a1)
				add.w	#16,a1
				move.b	(a0)+,(a2)
				move.b	(a0)+,8(a2)
				add.w	#16,a2
				dbra	d0,PutInFull

				rts

EnergyBar:		move.w	Energy,d0
				bgt.s	.noeneg
				move.w	#0,d0
.noeneg:		move.w	d0,Energy

				cmp.w	OldEnergy,d0
				bne.s	gottochange

NoChange		rts

gottochange:	blt		LessEnergy
				cmp.w	#127,Energy
				blt.s	NotMax
				move.w	#127,Energy
NotMax:			move.w	Energy,d0
				move.w	OldEnergy,d2
				sub.w	d0,d2
				beq.s	NoChange
				neg.w	d2

				move.w	#127,d3
				sub.w	d0,d3

				move.l	#health,a0
				lea		(a0,d3.w*4),a0
				move.l	#borders+25*16+6,a1
				lsl.w	#4,d3
				add.w	d3,a1
				lea		2592(a1),a2

EnergyRise:		move.b	(a0)+,(a1)
				move.b	(a0)+,8(a1)
				add.w	#16,a1
				move.b	(a0)+,(a2)
				move.b	(a0)+,8(a2)
				add.w	#16,a2
				subq	#1,d2
				bgt.s	EnergyRise

				move.w	Energy,OldEnergy

				rts

LessEnergy:		move.w	OldEnergy,d2
				sub.w	d0,d2

				move.w	#127,d3
				sub.w	OldEnergy,d3

				move.l	#borders+25*16+6,a1
				asl.w	#4,d3
				add.w	d3,a1
				lea		2592(a1),a2

EnergyDrain:	move.b	#0,(a1)
				move.b	#0,8(a1)
				move.b	#0,(a2)
				move.b	#0,8(a2)
				add.w	#16,a1
				add.w	#16,a2
				subq	#1,d2
				bgt.s	EnergyDrain

				move.w	Energy,OldEnergy

				rts

AmmoBar:		move.w	Ammo,d0
				cmp.w	OldAmmo,d0
				bne.s	.gottochange

.NoChange		rts

.gottochange:

				blt		LessAmmo
				cmp.w	#63,Ammo
				blt.s	.NotMax
				move.w	#63,Ammo
.NotMax:		move.w	Ammo,d0
				move.w	OldAmmo,d2
				sub.w	d0,d2
				beq.s	.NoChange
				neg.w	d2

				move.w	#63,d3
				sub.w	d0,d3

				move.l	#Ammunition,a0
				lea		(a0,d3.w*8),a0
				move.l	#borders+5184+25*16+1,a1
				lsl.w	#5,d3
				add.w	d3,a1
				lea		2592(a1),a2

AmmoRise:		move.b	(a0)+,(a1)
				move.b	(a0)+,8(a1)
				add.w	#16,a1
				move.b	(a0)+,(a2)
				move.b	(a0)+,8(a2)
				add.w	#16,a2
				move.b	(a0)+,(a1)
				move.b	(a0)+,8(a1)
				add.w	#16,a1
				move.b	(a0)+,(a2)
				move.b	(a0)+,8(a2)
				add.w	#16,a2
				subq	#1,d2
				bgt.s	AmmoRise

				move.w	Ammo,OldAmmo

				rts


LessAmmo:		move.w	OldAmmo,d2
				sub.w	d0,d2

				move.w	#63,d3
				sub.w	OldAmmo,d3

				move.l	#borders++5184+25*16+1,a1
				asl.w	#5,d3
				add.w	d3,a1
				lea		2592(a1),a2

AmmoDrain:		move.b	#0,(a1)
				move.b	#0,8(a1)
				move.b	#0,(a2)
				move.b	#0,8(a2)
				add.w	#16,a1
				add.w	#16,a2
				move.b	#0,(a1)
				move.b	#0,8(a1)
				move.b	#0,(a2)
				move.b	#0,8(a2)
				add.w	#16,a1
				add.w	#16,a2
				subq	#1,d2
				bgt.s	AmmoDrain

				move.w	Ammo,OldAmmo

				rts

nulop:			move.w	#$0010,$dff000+intreq
				rte

doanything:		dc.w	0

end:			clr.b	doanything

				move.w	PLR1_energy,Energy
				cmp.b	#'s',mors
				bne.s	.notsl
				move.w	PLR2_energy,Energy
.notsl:			bsr		EnergyBar

				move.l	drawpt,d0
				move.l	olddrawpt,drawpt
				move.l	d0,olddrawpt
				move.l	d0,$dff084


				cmp.b	#'b',Prefsfile+3
				bne.s	.noback
				jsr		mt_end
.noback			tst.w	Energy
				bgt.w	wevewon

				move.l	#gameover,mt_data
				st		UseAllChannels
				clr.b	reachedend
				jsr		mt_init
playgameover:
				move.l	#$dff000,a6
waitfortop2:	btst.b	#0,intreqr+1(a6)
				beq		waitfortop2
				move.w	#$1,intreq(a6)

				jsr		mt_music

				tst.b	reachedend
				beq.s	playgameover

				bra		wevelost


wevewon:		cmp.b	#'n',mors
				bne.s	.nonextlev
				add.w	#1,MaxLevel
				st		FinishedLevel
.nonextlev:		move.l	#welldone,mt_data
				st		UseAllChannels
				clr.b	reachedend
				jsr		mt_init
playwelldone:
				move.l	#$dff000,a6
waitfortop3:	btst.b	#0,intreqr+1(a6)
				beq		waitfortop3
				move.w	#$1,intreq(a6)

				jsr		mt_music

				tst.b	reachedend
				beq.s	playwelldone

				cmp.w	#16,MaxLevel
				bne		.noendgame
				jsr		ENDGAMESCROLL
.noendgame:
wevelost:		jmp		closeeverything

endnomusic		clr.b	doanything
				cmp.b	#'b',Prefsfile+3
				bne.s	.noback
				jsr		mt_end
.noback
*******************************
; cmp.b #'n',mors
; bne.s .nonextlev
; cmp.w #15,MaxLevel
; bge.s .nonextlev
; add.w #1,MaxLevel
; st FinishedLevel
;.nonextlev:
******************************

				jmp		closeeverything

do32:			move.w	#31,d7
				move.w	#$180,d1
across:			move.w	d1,(a1)+
				move.w	d1,(a3)+
				move.w	#0,(a1)+
				move.w	#0,(a3)+
				add.w	#2,d1
				dbra	d7,across
				rts

ENDGAMESCROLL:
				INCLUDE	endscroll.s

				INCLUDE	cd32joy.s

*************************************
* Set left and right clip values
*************************************



NEWsetlclip:	move.l	#OnScreen,a1
				move.l	#Rotated,a2
				move.l	CONNECT_TABLE,a3

				move.w	(a0),d0
				bge.s	.notignoreleft

; move.l #0,(a6)

				bra		.leftnotoktoclip
.notignoreleft:

				move.w	6(a2,d0*8),d3			; left z val
				bgt		.leftclipinfront
				addq	#2,a0
				rts

				tst.w	6(a2,d0*8)
				bgt		.leftnotoktoclip
.ignoreboth:
; move.l #0,(a6)
; move.l #96*65536,4(a6)
				move.w	#0,leftclip
				move.w	#96,rightclip
				addq	#8,a6
				addq	#2,a0
				rts

.leftclipinfront:
				move.w	(a1,d0*2),d1			; left x on screen
				move.w	(a0),d2
				move.w	2(a3,d2.w*4),d2
				move.w	(a1,d2.w*2),d2
				cmp.w	d1,d2
				bgt		.leftnotoktoclip

; move.w d1,(a6)
; move.w d3,2(a6)
				cmp.w	leftclip,d1
				ble.s	.leftnotoktoclip
				move.w	d1,leftclip
.leftnotoktoclip:

				addq	#2,a0

				rts

NEWsetrclip		move.l	#OnScreen,a1
				move.l	#Rotated,a2
				move.l	CONNECT_TABLE,a3
				move.w	(a0),d0
				bge.s	.notignoreright
; move.w #96,4(a6)
; move.w #0,6(a6)
				move.w	#0,d4
				bra		.rightnotoktoclip
.notignoreright:
				move.w	6(a2,d0*8),d4			; right z val
				bgt.s	.rightclipinfront
; move.w #96,4(a6)
; move.w #0,6(a6)
				bra.s	.rightnotoktoclip

.rightclipinfront:
				move.w	(a1,d0*2),d1			; right x on screen
				move.w	(a0),d2
				move.w	(a3,d2.w*4),d2
				move.w	(a1,d2.w*2),d2
				cmp.w	d1,d2
				blt.s	.rightnotoktoclip
; move.w d1,4(a6)
; move.w d4,6(a6)

				cmp.w	rightclip,d1
				bge.s	.rightnotoktoclip
				addq	#1,d1
				move.w	d1,rightclip
.rightnotoktoclip:
				addq	#8,a6
				addq	#2,a0
				rts

FIRSTsetlrclip:
				move.l	#OnScreen,a1
				move.l	#Rotated,a2

				move.w	(a0)+,d0
				bge.s	.notignoreleft
				bra		.leftnotoktoclip
.notignoreleft:

				move.w	6(a2,d0*8),d3			; left z val
				bgt.s	.leftclipinfront

				move.w	(a0),d0
				blt.s	.ignoreboth
				tst.w	6(a2,d0*8)
				bgt.s	.leftnotoktoclip
.ignoreboth		move.w	#96,rightclip
				move.w	#0,leftclip
				addq	#2,a0
				rts

.leftclipinfront:
				move.w	(a1,d0*2),d1			; left x on screen
				cmp.w	leftclip,d1
				ble.s	.leftnotoktoclip
				move.w	d1,leftclip
.leftnotoktoclip:

				move.w	(a0)+,d0
				bge.s	.notignoreright
				move.w	#0,d4
				bra		.rightnotoktoclip
.notignoreright:
				move.w	6(a2,d0*8),d4			; right z val
				ble.s	.rightnotoktoclip

.rightclipinfront:
				move.w	(a1,d0*2),d1			; right x on screen
				addq	#1,d1
				cmp.w	rightclip,d1
				bge.s	.rightnotoktoclip
				move.w	d1,rightclip
.rightnotoktoclip:

; move.w leftclip,d0
; move.w rightclip,d1
; cmp.w d0,d1
; bge.s .noswap
; move.w #96,rightclip
; move.w #0,leftclip
;.noswap:

				rts


leftclip2:		dc.w	0
rightclip2:		dc.w	0
ZoneBright:		dc.w	0

npolys:			dc.w	0

PLR1_fire:		dc.b	0
PLR2_fire:		dc.b	0

*****************************************************


pastdata:
***********************************
* This routine animates brightnesses.


liftpt:			dc.l	liftanimtab

brightpt:		dc.l	brightanimtab


liftanim:		rts

******************************
				INCLUDE	objectmove.s
				INCLUDE	anims.s
******************************
startpass:
; INCLUDE "source/password_reloc.s"
endpass:
rotanimpt:		dc.w	0
xradd:			dc.w	5
yradd:			dc.w	8
xrpos:			dc.w	320
yrpos:			dc.w	320

rotanim:		rts

option:			dc.l	0,0

********** WALL STUFF *******************************

				INCLUDE	wallroutine.s

*****************************************************

******************************************
* floor polygon

numsidestd:		dc.w	0
bottomline:		dc.w	0

checkforwater:
				tst.b	usewater
				beq.s	.notwater

				move.l	Roompt,a1
				move.w	(a1),d7
				cmp.w	currzone,d7
				bne.s	.notwater

				move.b	#$f,fillscrnwater

.notwater:		move.w	(a0)+,d6				; sides-1
				add.w	d6,d6
				add.w	d6,a0
				add.w	#4+6,a0
				rts

				rts

NewCornerBuff:
				ds.l	100
CLRNOFLOOR:		dc.w	0

;---------------------------------------------------------------------------------

itsafloordraw:
	; If D0 =1 then its a floor otherwise (=2) it's
	; a roof.

				move.w	#0,above
				move.w	(a0)+,d6				; ypos of poly

				move.w	d6,d7
				ext.l	d7
				asl.l	#6,d7
				cmp.l	TOPOFROOM,d7
				blt		checkforwater
				cmp.l	BOTOFROOM,d7
				bgt.s	dontdrawreturn

				move.w	leftclip(pc),d7
				cmp.w	rightclip(pc),d7
				bge.s	dontdrawreturn

				move.w	botclip,d7
				sub.w	#40,d7
				ble.s	dontdrawreturn
				sub.w	flooryoff,d6
				bgt.s	below
				blt.s	aboveplayer

				tst.b	usewater
				beq.s	.notwater

				move.l	Roompt,a1
				move.w	(a1),d7
				cmp.w	currzone,d7

				bne.s	.notwater

				st		fillscrnwater

.notwater:
dontdrawreturn:
				move.w	(a0)+,d6				; sides-1
				add.w	d6,d6
				add.w	d6,a0
				add.w	#4+6,a0
				rts

aboveplayer:	tst.b	usewater
				beq.s	.notwater

				move.l	Roompt,a1
				move.w	(a1),d7
				cmp.w	currzone,d7
				bne.s	.notwater

				move.b	#$f,fillscrnwater

.notwater:		btst	#1,d0
				beq.s	dontdrawreturn
				move.w	#40,d7
				sub.w	topclip,d7
				ble.s	dontdrawreturn
				move.w	#1,d0
				move.w	d0,above
				neg.w	d6
below:			btst	#0,d0
				beq.s	dontdrawreturn
				move.w	d6,distaddr
				muls	#64,d6
				move.l	d6,ypos
				divs	d7,d6					; zpos of bottom
	; visible line
				move.w	d6,minz
				move.w	d7,bottomline

; Go round each point finding out
; if it should be visible or not.

				move.l	a0,-(a7)

				move.w	(a0)+,d7				; number of sides
				lea		Rotated,a1
				lea		OnScreen,a2
				lea		NewCornerBuff,a3
				moveq	#0,d4
				moveq	#0,d5
				moveq	#0,d6
				clr.b	anyclipping

cornerprocessloop:
				move.w	(a0)+,d0
				move.w	6(a1,d0.w*8),d1
				ble		.canttell

				move.w	(a2,d0.w*2),d3
				cmp.w	leftclip,d3
				bgt.s	.nol
				st		d4
				st		anyclipping
				bra.s	.nos
.nol:			cmp.w	rightclip,d3
				blt.s	.nor
				st		d6
				st		anyclipping
				bra.s	.nos
.nor:			st		d5
.nos:			bra		.cantell

.canttell:		st		d5
				st		anyclipping

.cantell:		dbra	d7,cornerprocessloop

				move.l	(a7)+,a0
				tst.b	d5
				bne.s	somefloortodraw
				eor.b	d4,d6
				bne		dontdrawreturn

somefloortodraw:
				tst.b	gourfloor
				bne		goursides

				move.w	#80,top
				move.w	#-1,bottom
				move.w	#0,drawit
				lea		Rotated,a1
				lea		OnScreen,a2
				move.w	(a0)+,d7				; no of sides
sideloop:		move.w	minz,d6
				move.w	(a0)+,d1
				move.w	(a0),d3
				move.w	6(a1,d1*8),d4			;first z
				cmp.w	d6,d4
				bgt		firstinfront
				move.w	6(a1,d3*8),d5			; sec z
				cmp.w	d6,d5
				ble		bothbehind

	;line must be on left and partially behind.

				sub.w	d5,d4
				move.l	(a1,d1*8),d0
				sub.l	(a1,d3*8),d0
				asr.l	#7,d0
				sub.w	d5,d6
				muls	d6,d0					; new x coord
				divs	d4,d0
				ext.l	d0
				asl.l	#7,d0

				add.l	(a1,d3*8),d0
				move.w	minz,d4
				move.w	(a2,d3*2),d2
				divs	d4,d0
				add.w	#47,d0
				move.l	ypos,d3
				divs	d5,d3
				move.w	bottomline,d1
				bra		lineclipped

firstinfront:
				move.w	6(a1,d3*8),d5			; sec z
				cmp.w	d6,d5
				bgt		bothinfront

	; line must be on right and partially behind.

				sub.w	d4,d5					; dz
				move.l	(a1,d3*8),d2
				sub.l	(a1,d1*8),d2			; dx
				sub.w	d4,d6
				asr.l	#7,d2
				muls	d6,d2					; new x coord
				divs	d5,d2
				ext.l	d2
				asl.l	#7,d2
				add.l	(a1,d1*8),d2
				move.w	minz,d5
				move.w	(a2,d1*2),d0
				divs	d5,d2
				add.w	#47,d2
				move.l	ypos,d1
				divs	d4,d1
				move.w	bottomline,d3
				bra		lineclipped

bothinfront:
	;Also, usefully enough, both are on-screen
	;so no bottom clipping is needed.

				move.w	(a2,d1*2),d0			; first x
				move.w	(a2,d3*2),d2			; second x
				move.l	ypos,d1
				move.l	d1,d3
				divs	d4,d1					; first y
				divs	d5,d3					; second y
lineclipped:	lea		rightsidetab,a3
				cmp.w	d1,d3
				beq		lineflat
				st		drawit
				bgt		lineonright

				lea		leftsidetab,a3
				exg		d1,d3
				exg		d0,d2
				lea		0(a3,d1*2),a3

				cmp.w	top(pc),d1
				bge.s	.nonewtop
				move.w	d1,top
.nonewtop:		cmp.w	bottom(pc),d3
				ble.s	.nonewbot
				move.w	d3,bottom
.nonewbot:		sub.w	d1,d3					; dy
				sub.w	d0,d2					; dx

				blt		.linegoingleft

				sub.w	#1,d0
				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2

; moveq #0,d6
; sub.w d3,d2
; blt.s .noco
;.makeco
; addq #1,d6
; sub.w d3,d2
; bge.s .makeco
;.noco
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1

.pixlopright:
				move.w	d0,(a3)+
				sub.w	d2,d4
				bge.s	.nobigstep
				add.w	d1,d0
				add.w	d3,d4
				dbra	d5,.pixlopright
				bra		lineflat
.nobigstep		add.w	d6,d0
				dbra	d5,.pixlopright
				bra		lineflat

.linegoingleft:
				subq.w	#1,d0

				neg.w	d2

				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2


; moveq #0,d6
; sub.w d3,d2
; blt.s .nocol
;.makecol
; addq #1,d6
; sub.w d3,d2
; bge.s .makecol
;.nocol
; add.w d3,d2



				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5

				move.w	d6,d1
				addq	#1,d1

.pixlopleft:	sub.w	d2,d4
				bge.s	.nobigstepl
				sub.w	d1,d0
				add.w	d3,d4
				move.w	d0,(a3)+
				dbra	d5,.pixlopleft
				bra		lineflat

.nobigstepl		sub.w	d6,d0
				move.w	d0,(a3)+
				dbra	d5,.pixlopleft
				bra		lineflat

lineonright:	lea		(a3,d1*2),a3

				cmp.w	top(pc),d1
				bge.s	.nonewtop
				move.w	d1,top
.nonewtop:		cmp.w	bottom(pc),d3
				ble.s	.nonewbot
				move.w	d3,bottom
.nonewbot:		sub.w	d1,d3					; dy
				sub.w	d0,d2					; dx
				blt		.linegoingleft
; addq #1,d0
				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2

; moveq #0,d6
; sub.w d3,d2
; blt.s .noco
;.makeco
; addq #1,d6
; sub.w d3,d2
; bge.s .makeco
;.noco
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1

.pixlopright:
				sub.w	d2,d4
				bge.s	.nobigstep
				add.w	d1,d0
				add.w	d3,d4
				move.w	d0,(a3)+
				dbra	d5,.pixlopright
				bra		lineflat

.nobigstep		add.w	d6,d0
				move.w	d0,(a3)+
				dbra	d5,.pixlopright
				bra		lineflat

.linegoingleft:
; addq #1,d0
				neg.w	d2

				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2


; moveq #0,d6
; sub.w d3,d2
; blt.s .nocol
;.makecol
; addq #1,d6
; sub.w d3,d2
; bge.s .makecol
;.nocol
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1

.pixlopleft:	move.w	d0,(a3)+
				sub.w	d2,d4
				bge.s	.nobigstepl
				sub.w	d1,d0
				add.w	d3,d4
				dbra	d5,.pixlopleft
				bra		lineflat

.nobigstepl		sub.w	d6,d0
				dbra	d5,.pixlopleft

lineflat:
bothbehind:		dbra	d7,sideloop
				bra		pastsides

fbr:			dc.w	0
sbr:			dc.w	0

goursides:		move.w	#80,top
				move.w	#-1,bottom
				move.w	#0,drawit
				move.l	#Rotated,a1
				move.l	#OnScreen,a2
				move.w	(a0)+,d7				; no of sides
sideloopGOUR:
				move.w	minz,d6
				move.w	(a0)+,d1
				move.w	(a0),d3

				move.l	PointBrightsPtr,a4
				move.w	(a4,d1.w*4),fbr
				move.w	(a4,d3.w*4),sbr

				move.w	6(a1,d1*8),d4			;first z
				cmp.w	d6,d4
				bgt		firstinfrontGOUR
				move.w	6(a1,d3*8),d5			; sec z
				cmp.w	d6,d5
				ble		bothbehindGOUR
** line must be on left and partially behind.
				sub.w	d5,d4

				move.w	fbr,d0
				sub.w	sbr,d0
				sub.w	d5,d6
				muls	d6,d0
				divs	d4,d0
				add.w	sbr,d0
				move.w	d0,fbr

				move.l	(a1,d1*8),d0
				sub.l	(a1,d3*8),d0
				asr.l	#7,d0
				muls	d6,d0					; new x coord
				divs	d4,d0
				ext.l	d0
				asl.l	#7,d0

				add.l	(a1,d3*8),d0
				move.w	minz,d4
				move.w	(a2,d3*2),d2
				divs	d4,d0
				add.w	#47,d0
				move.l	ypos,d3
				divs	d5,d3

				move.w	bottomline,d1
				bra		lineclippedGOUR

firstinfrontGOUR:
				move.w	6(a1,d3*8),d5			; sec z
				cmp.w	d6,d5
				bgt		bothinfrontGOUR
** line must be on right and partially behind.
				sub.w	d4,d5					; dz

				move.w	sbr,d2
				sub.w	fbr,d2
				sub.w	d4,d6
				muls	d6,d2
				divs	d5,d2
				add.w	fbr,d2
				move.w	d2,sbr

				move.l	(a1,d3*8),d2
				sub.l	(a1,d1*8),d2			; dx
				asr.l	#7,d2
				muls	d6,d2					; new x coord
				divs	d5,d2
				ext.l	d2
				asl.l	#7,d2
				add.l	(a1,d1*8),d2
				move.w	minz,d5
				move.w	(a2,d1*2),d0
				divs	d5,d2
				add.w	#47,d2
				move.l	ypos,d1
				divs	d4,d1
				move.w	bottomline,d3
				bra		lineclippedGOUR

bothinfrontGOUR:

* Also, usefully enough, both are on-screen
* so no bottom clipping is needed.

				move.w	(a2,d1*2),d0			; first x
				move.w	(a2,d3*2),d2			; second x
				move.l	ypos,d1
				move.l	d1,d3
				divs	d4,d1					; first y
				divs	d5,d3					; second y
lineclippedGOUR:
				lea		rightsidetab,a3
				cmp.w	d1,d3
				bne		linenotflatGOUR

; move.w fbr,d4
; move.w sbr,d5
; cmp.w d0,d2
; bgt.s .nsw
; exg d4,d5
;.nsw:

; move.l #leftbrighttab,a3
; move.w d4,(a3,d3.w)
; move.l #rightbrighttab,a3
; move.w d5,(a3,d3.w)
				bra		lineflatGOUR

linenotflatGOUR
				st		drawit
				bgt		lineonrightGOUR
				lea		leftsidetab,a3
				exg		d1,d3
				exg		d0,d2

				lea		(a3,d1*2),a3
				lea		leftbrighttab-leftsidetab(a3),a4

				cmp.w	top(pc),d1
				bge.s	.nonewtop
				move.w	d1,top
.nonewtop:		cmp.w	bottom(pc),d3
				ble.s	.nonewbot
				move.w	d3,bottom
.nonewbot:		sub.w	d1,d3					; dy
				sub.w	d0,d2					; dx

				blt		.linegoingleft
				sub.w	#1,d0

				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2
				move.w	d2,a5

; moveq #0,d6
; sub.w d3,d2
; blt.s .noco
;.makeco
; addq #1,d6
; sub.w d3,d2
; bge.s .makeco
;.noco
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1
				move.w	d1,a6

				moveq	#0,d1
				move.w	sbr,d1
				move.w	fbr,d2
				sub.w	d1,d2
				ext.l	d2
				asl.w	#8,d2
				asl.w	#3,d2
				divs	d3,d2
				ext.l	d2
				asl.l	#5,d2
				swap	d1

.pixlopright:
				move.w	d0,(a3)+
				swap	d1
				move.w	d1,(a4)+
				swap	d1
				add.l	d2,d1

				sub.w	a5,d4
				bge.s	.nobigstep
				add.w	a6,d0
				add.w	d3,d4
				dbra	d5,.pixlopright
				bra		lineflatGOUR
.nobigstep		add.w	d6,d0
				dbra	d5,.pixlopright
				bra		lineflatGOUR

.linegoingleft:

				sub.w	#1,d0

				neg.w	d2

				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2


; moveq #0,d6
; sub.w d3,d2
; blt.s .nocol
;.makecol
; addq #1,d6
; sub.w d3,d2
; bge.s .makecol
;.nocol
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5

				move.w	d6,d1
				addq	#1,d1
				move.w	d1,a6
				move.w	d2,a5

				moveq	#0,d1
				move.w	sbr,d1
				move.w	fbr,d2
				sub.w	d1,d2
				ext.l	d2
				asl.w	#8,d2
				asl.w	#3,d2
				divs	d3,d2
				ext.l	d2
				asl.l	#5,d2
				swap	d1

.pixlopleft:	swap	d1
				move.w	d1,(a4)+
				swap	d1
				add.l	d2,d1

				sub.w	a5,d4
				bge.s	.nobigstepl
				sub.w	a6,d0
				add.w	d3,d4
				move.w	d0,(a3)+
				dbra	d5,.pixlopleft
				bra		lineflatGOUR

.nobigstepl		sub.w	d6,d0
				move.w	d0,(a3)+
				dbra	d5,.pixlopleft
				bra		lineflatGOUR

lineonrightGOUR:

				lea		(a3,d1*2),a3

				lea		rightbrighttab-rightsidetab(a3),a4

				cmp.w	top(pc),d1
				bge.s	.nonewtop
				move.w	d1,top
.nonewtop:		cmp.w	bottom(pc),d3
				ble.s	.nonewbot
				move.w	d3,bottom
.nonewbot:		sub.w	d1,d3					; dy
				sub.w	d0,d2					; dx
				blt		.linegoingleft
; addq #1,d0
				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2

; moveq #0,d6
; sub.w d3,d2
; blt.s .noco
;.makeco
; addq #1,d6
; sub.w d3,d2
; bge.s .makeco
;.noco
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1

				move.w	d1,a6
				move.w	d2,a5

				moveq	#0,d1
				move.w	fbr,d1
				move.w	sbr,d2
				sub.w	d1,d2
				ext.l	d2
				asl.w	#8,d2
				asl.w	#3,d2
				divs	d3,d2
				ext.l	d2
				asl.l	#5,d2
				swap	d1

.pixlopright:

				swap	d1
				move.w	d1,(a4)+
				swap	d1
				add.l	d2,d1

				sub.w	a5,d4
				bge.s	.nobigstep
				add.w	a6,d0
				add.w	d3,d4
				move.w	d0,(a3)+
				dbra	d5,.pixlopright
				bra		lineflatGOUR

.nobigstep		add.w	d6,d0
				move.w	d0,(a3)+
				dbra	d5,.pixlopright
				bra		lineflatGOUR

.linegoingleft:
; addq #1,d0
				neg.w	d2

				ext.l	d2
				divs	d3,d2
				move.w	d2,d6
				swap	d2


; moveq #0,d6
; sub.w d3,d2
; blt.s .nocol
;.makecol
; addq #1,d6
; sub.w d3,d2
; bge.s .makecol
;.nocol
; add.w d3,d2

				move.w	d3,d4
				move.w	d3,d5
				subq	#1,d5
				move.w	d6,d1
				addq	#1,d1
				move.w	d1,a6
				move.w	d2,a5

				moveq	#0,d1
				move.w	fbr,d1
				move.w	sbr,d2
				sub.w	d1,d2
				ext.l	d2
				asl.w	#8,d2
				asl.w	#3,d2
				divs	d3,d2
				ext.l	d2
				asl.l	#5,d2
				swap	d1

.pixlopleft:	swap	d1
				move.w	d1,(a4)+
				swap	d1
				add.l	d2,d1

				move.w	d0,(a3)+
				sub.w	a5,d4
				bge.s	.nobigstepl
				sub.w	a6,d0
				add.w	d3,d4
				dbra	d5,.pixlopleft
				bra		lineflatGOUR

.nobigstepl		sub.w	d6,d0
				dbra	d5,.pixlopleft

lineflatGOUR:

bothbehindGOUR:
				dbra	d7,sideloopGOUR

pastsides:		addq	#2,a0

				move.w	#96*2,linedir
				move.l	frompt,a6
				add.l	#96*2*41,a6
				move.w	(a0)+,scaleval
				move.w	(a0)+,whichtile
				move.w	(a0)+,d6
				add.w	ZoneBright,d6
				move.w	d6,lighttype
				move.w	above(pc),d6
				beq		groundfloor

	; on ceiling

				move.w	#-96*2,linedir
				suba.w	#96*2,a6

groundfloor:	move.w	xoff,d6
				move.w	zoff,d7
				add.w	xwobxoff,d7
				add.w	xwobzoff,d6
				swap	d6
				swap	d7
				clr.w	d6
				clr.w	d7
				move.w	scaleval(pc),d3
				beq.s	.samescale
				bgt.s	.scaledown
				neg.w	d3
				asr.l	d3,d7
				asr.l	d3,d6
				bra.s	.samescale

.scaledown:		asl.l	d3,d6
				asl.l	d3,d7

.samescale		move.l	d6,sxoff
				move.l	d7,szoff
				bra		pastscale

;	asr.l        #3,d1
;	asr.l        #3,d2
;	asr.l        #2,d1
;	asr.l        #2,d2
;	asr.l        #1,d1
;	asr.l        #1,d2
;scaleprogfrom
;	nop
;	nop
;	asl.l        #1,d1
;	asl.l        #1,d2
;	asl.l        #2,d1
;	asl.l        #2,d2
;	asl.l        #3,d1
;	asl.l        #3,d2

top:			dc.w	0
bottom:			dc.w	0
ypos:			dc.l	0
nfloors:		dc.w	0
lighttype:		dc.w	0
above:			dc.w	0
linedir:		dc.w	0
distaddr:		dc.w	0

minz:			dc.w	0
leftsidetab:	ds.w	180
rightsidetab:
				ds.w	180
leftbrighttab:
				ds.w	180
rightbrighttab:
				ds.w	180

PointBrights:
				dc.l	0
CurrentPointBrights:
				ds.l	1000

movespd:		dc.w	0
largespd:		dc.l	0
disttobot:		dc.w	0

pastscale:		tst.b	drawit(pc)
				beq		dontdrawfloor

				move.l	a0,-(a7)

				lea		leftsidetab(pc),a4
				move.w	top(pc),d1

				move.w	#39,d7
				sub.w	d1,d7
				move.w	d7,disttobot

				move.w	bottom(pc),d7
				tst.w	above
				beq.s	clipfloor

				move.w	#40,d3
				move.w	d3,d4
				sub.w	topclip,d3
				sub.w	botclip,d4
				cmp.w	d3,d1
				bge		predontdrawfloor
				cmp.w	d4,d7
				blt		predontdrawfloor
				cmp.w	d4,d1
				bge.s	.nocliptoproof
				move.w	d4,d1
.nocliptoproof
				cmp.w	d3,d7
				blt		doneclip
				move.w	d3,d7
				bra		doneclip

clipfloor:		move.w	botclip,d4
				sub.w	#40,d4
				cmp.w	d4,d1
				bge		predontdrawfloor
				move.w	topclip,d3
				sub.w	#40,d3
				cmp.w	d3,d1
				bge.s	.nocliptopfloor
				move.w	d3,d1
.nocliptopfloor
				cmp.w	d3,d7
				ble		predontdrawfloor
				cmp.w	d4,d7
				blt.s	.noclipbotfloor
				move.w	d4,d7
.noclipbotfloor:

doneclip:		lea		(a4,d1*2),a4
; move.l #dists,a2
				move.w	distaddr,d0
				muls	#64,d0
				move.l	d0,a2
; muls #25,d0
; adda.w d0,a2
; lea (a2,d1*2),a2
				sub.w	d1,d7
				ble		predontdrawfloor
				move.w	d1,d0
				bne.s	.notzero
				moveq	#1,d0
.notzero		muls	linedir,d1
				add.l	d1,a6
				lea		floorscalecols,a1
				move.l	LineToUse,a5

				tst.b	gourfloor
				bne		dogourfloor

				tst.b	anyclipping
				beq		dofloornoclip

dofloor:
; move.w (a2)+,d0
				move.w	leftclip(pc),d3
				move.w	rightclip(pc),d4
				move.w	rightsidetab-leftsidetab(a4),d2

				addq	#1,d2
				cmp.w	d3,d2
				ble.s	nodrawline
				cmp.w	d4,d2
				ble.s	noclipright
				move.w	d4,d2
noclipright:	move.w	(a4),d1
				cmp.w	d4,d1
				bge.s	nodrawline
				cmp.w	d3,d1
				bge.s	noclipleft
				move.w	d3,d1
noclipleft:		cmp.w	d1,d2
				ble.s	nodrawline

				move.w	d1,leftedge
				move.w	d2,rightedge

; moveq #0,d1
; moveq #0,d3
; move.w leftbrighttab-leftsidetab(a4),d1
; bge.s .okbl
; moveq #0,d1
;.okbl:

; move.w rightbrighttab-leftsidetab(a4),d3
; bge.s .okbr
; moveq #0,d3
;.okbr:

; sub.w d1,d3
; asl.w #8,d1
; move.l d1,leftbright
; swap d3
; asr.l #5,d3
; divs d5,d3
; move.w d3,d5
; muls.w d6,d5
; asr.l #3,d5
; clr.b d5
; add.w d5,leftbright+2

; ext.l d3
; asl.l #5,d3
; swap d3
; asl.w #8,d3
; move.l d3,brightspd

				move.l	a6,a3
				movem.l	d0/d7/a2/a4/a5/a6,-(a7)
				move.l	a2,d7
				divs	d0,d7
				move.w	d7,d0
				jsr		(a5)
				movem.l	(a7)+,d0/d7/a2/a4/a5/a6
nodrawline		sub.w	#1,disttobot
				adda.w	linedir(pc),a6
				addq	#2,a4
				addq	#1,d0
				subq	#1,d7
				bgt		dofloor

predontdrawfloor
				move.l	(a7)+,a0

dontdrawfloor:

				rts

anyclipping:	dc.w	0

dofloornoclip:
; move.w (a2)+,d0
				move.w	rightsidetab-leftsidetab(a4),d2
				addq	#1,d2
				move.w	(a4)+,d1
				move.w	d1,leftedge
				move.w	d2,rightedge

; sub.w d1,d2

; moveq #0,d1
; moveq #0,d3
; move.w leftbrighttab-leftsidetab(a4),d1
; bge.s .okbl
; moveq #0,d1
;.okbl:

; move.w rightbrighttab-leftsidetab(a4),d3
; bge.s .okbr
; moveq #0,d3
;.okbr:

; sub.w d1,d3
; asl.w #8,d1
; move.l d1,leftbright
; swap d3
; asr.l #5,d3
; divs d2,d3
; ext.l d3
; asl.l #5,d3
; swap d3
; asl.w #8,d3
; move.l d3,brightspd

				move.l	a6,a3
				movem.l	d0/d7/a2/a4/a5/a6,-(a7)
				move.l	a2,d7
				divs	d0,d7
				move.w	d7,d0
				jsr		(a5)
				movem.l	(a7)+,d0/d7/a2/a4/a5/a6
				sub.w	#1,disttobot
				adda.w	linedir(pc),a6
				addq	#1,d0
				subq	#1,d7
				bgt		dofloornoclip

				bra		predontdrawfloor

dogourfloor:	tst.b	anyclipping
				beq		dofloornoclipGOUR

dofloorGOUR:
; move.w (a2)+,d0
				move.w	leftclip(pc),d3
				move.w	rightclip(pc),d4
				move.w	rightsidetab-leftsidetab(a4),d2

				move.w	d2,d5
				sub.w	(a4),d5
				addq	#1,d5
				moveq	#0,d6

				addq	#1,d2
				cmp.w	d3,d2
				ble		nodrawlineGOUR
				cmp.w	d4,d2
				ble.s	nocliprightGOUR
				move.w	d4,d2
nocliprightGOUR:
				move.w	(a4),d1
				cmp.w	d4,d1
				bge		nodrawlineGOUR
				cmp.w	d3,d1
				bge.s	noclipleftGOUR
				move.w	d3,d6
				subq	#1,d6
				sub.w	d1,d6
				move.w	d3,d1
noclipleftGOUR:
				cmp.w	d1,d2
				ble		nodrawlineGOUR

				move.w	d1,leftedge
				move.w	d2,rightedge

				move.l	a2,d2
				divs	d0,d2
				move.w	d2,dst
				asr.w	#7,d2
; addq #5,d2
; add.w lighttype,d2

				moveq	#0,d1
				moveq	#0,d3
				move.w	leftbrighttab-leftsidetab(a4),d1
				add.w	d2,d1
				bge.s	.okbl
				moveq	#0,d1
.okbl:			asr.w	#1,d1
				cmp.w	#14,d1
				ble.s	.okdl
				move.w	#14,d1
.okdl:			move.w	rightbrighttab-leftsidetab(a4),d3
				add.w	d2,d3
				bge.s	.okbr
				moveq	#0,d3
.okbr:			asr.w	#1,d3
				cmp.w	#14,d3
				ble.s	.okdr
				move.w	#14,d3
.okdr:			sub.w	d1,d3
				asl.w	#8,d1
				move.l	d1,leftbright
				swap	d3
				tst.l	d3
				bgt.s	.OKITSPOSALREADY
				neg.l	d3
				asr.l	#5,d3
				divs	d5,d3
				neg.w	d3
				bra.s	.OKNOWITSNEG

.OKITSPOSALREADY
				asr.l	#5,d3
				divs	d5,d3
.OKNOWITSNEG	muls	d3,d6
				add.w	#256*8,d6
				asr.w	#3,d6
				clr.b	d6
				add.w	d6,leftbright+2

				ext.l	d3
				asl.l	#5,d3
				swap	d3
				asl.w	#8,d3
				move.l	d3,brightspd

				move.l	a6,a3
				movem.l	d0/d7/a2/a4/a5/a6,-(a7)
				move.w	dst,d0
				lea		floorscalecols,a1
				move.l	FloorTilePtr,a0
				adda.w	whichtile,a0
				jsr		pastfloorbright
				movem.l	(a7)+,d0/d7/a2/a4/a5/a6
nodrawlineGOUR

				sub.w	#1,disttobot

				adda.w	linedir(pc),a6
				addq	#2,a4
				addq	#1,d0
				subq	#1,d7
				bgt		dofloorGOUR

predontdrawfloorGOUR
				move.l	(a7)+,a0

dontdrawfloorGOUR:

				rts

dofloornoclipGOUR:
; move.w (a2)+,d0
				move.w	rightsidetab-leftsidetab(a4),d2
				addq	#1,d2
				move.w	(a4),d1
				move.w	d1,leftedge
				move.w	d2,rightedge

				sub.w	d1,d2

				move.l	a2,d6
				divs	d0,d6
				move.w	d6,d5
				asr.w	#7,d5
; addq #5,d5
; add.w lighttype,d5

				moveq	#0,d1
				moveq	#0,d3
				move.w	leftbrighttab-leftsidetab(a4),d1
				add.w	d5,d1
				bge.s	.okbl
				moveq	#0,d1
.okbl:			asr.w	#1,d1
				cmp.w	#14,d1
				ble.s	.okdl
				move.w	#14,d1
.okdl:			move.w	rightbrighttab-leftsidetab(a4),d3
				add.w	d5,d3
				bge.s	.okbr
				moveq	#0,d3
.okbr:			asr.w	#1,d3
				cmp.w	#14,d3
				ble.s	.okdr
				move.w	#14,d3
.okdr:			sub.w	d1,d3
				asl.w	#8,d1
				move.l	d1,leftbright
				swap	d3
				asr.l	#5,d3
				divs	d2,d3
				ext.l	d3
				asl.l	#5,d3
				swap	d3
				asl.w	#8,d3
				move.l	d3,brightspd


				move.l	a6,a3
				movem.l	d0/d7/a2/a4/a5/a6,-(a7)
				move.w	d6,d0
				move.w	d0,dst
				lea		floorscalecols,a1
				move.l	FloorTilePtr,a0
				adda.w	whichtile,a0
				jsr		pastfloorbright
				movem.l	(a7)+,d0/d7/a2/a4/a5/a6
				sub.w	#1,disttobot
				adda.w	linedir(pc),a6
				addq	#2,a4
				addq	#1,d0
				subq	#1,d7
				bgt		dofloornoclipGOUR

				bra		predontdrawfloorGOUR



dists:
; INCBIN "floordists"
drawit:			dc.w	0

LineToUse:		dc.l	0

***************************
* Right then, time for the floor
* routine...
* For test purposes, give it
* a3 = point to screen
* d0= z distance away
* and sinval+cosval must be set up.
***************************

tstwhich:		dc.w	0
whichtile:		dc.w	0
PLAINSCALE:		INCBIN	plainscale
storeit:		dc.l	0
leftedge:		dc.w	0
rightedge:		dc.w	0
dst:			dc.w	0

SimpleFloorLine:
				tst.b	CLRNOFLOOR
				beq.s	.notblackfloor

				moveq	#0,d0
				bra.s	.dofloor

.notblackfloor:
				lea		PLAINSCALE,a2

				move.w	d0,d2
				move.w	lighttype,d1
				asr.w	#8,d2
				addq.w	#5,d1
				add.w	d2,d1
				bge.s	.fixedbright
				moveq	#0,d1
.fixedbright:
				cmp.w	#28,d1
				ble.s	.smallbright

				move.w	#28,d1
.smallbright:
				lea		(a2,d1.w*2),a2

				move.w	whichtile,d0
				move.w	d0,d1
				and.w	#$3,d1
				and.w	#$300,d0
				lsl.b	#6,d1
				move.b	d1,d0
				move.w	d0,tstwhich
				move.w	(a2,d0.w),d0

.dofloor:		move.w	leftedge(pc),d1
				move.w	rightedge(pc),d3
				sub.w	d1,d3
				lea		0(a3,d1.w*2),a2
				addq.w	#1,d3
.df_loop:		move.w	d0,(a2)+
				dbf		d3,.df_loop
				rts

;-----

FloorLine:		move.l	FloorTilePtr,a0
				adda.w	whichtile,a0
				move.w	lighttype,d1
				move.w	d0,dst
				move.w	d0,d2
*********************
* Old version
				asr.w	#8,d2
				add.w	#5,d1
*********************
; asr.w #3,d2
; sub.w #4,d2
; cmp.w #6,d2
; blt.s flbrbr
; move.w #6,d2
;flbrbr:
*********************
				add.w	d2,d1
				bge.s	.fixedbright
				moveq	#0,d1
.fixedbright:
				cmp.w	#28,d1
				ble.s	.smallbright
				move.w	#28,d1
.smallbright:
				lea		floorscalecols,a1
				add.l	floorbright(pc,d1.w*4),a1
				bra		pastfloorbright

ConstCol:		dc.w	0

BumpLine:		tst.b	smoothbumps
				beq.s	Chunky

				move.l	#SmoothTile,a0
				lea		Smoothscalecols,a1
				bra		pastast

Chunky:			moveq	#0,d2
				move.l	#Bumptile,a0
				move.w	whichtile,d2
				adda.w	d2,a0
				ror.l	#2,d2
				lsr.w	#6,d2
				rol.l	#2,d2
				and.w	#15,d2
				move.l	#ConstCols,a1
				move.w	(a1,d2.w*2),ConstCol
				lea		Bumpscalecols,a1

pastast:		move.w	lighttype,d1

				move.w	d0,dst

				move.w	d0,d2
*********************
* Old version
				asr.w	#8,d2
				add.w	#5,d1
*********************
; asr.w #3,d2
; sub.w #4,d2
; cmp.w #6,d2
; blt.s flbrbr
; move.w #6,d2
;flbrbr:
*********************
				add.w	d2,d1
				bge.s	.fixedbright
				moveq	#0,d1
.fixedbright:
				cmp.w	#28,d1
				ble.s	.smallbright
				move.w	#28,d1
.smallbright:
				add.l	floorbright(pc,d1.w*4),a1
				bra		pastfloorbright


floorbright:	dc.l	512*0
				dc.l	512*1
				dc.l	512*1
				dc.l	512*2
				dc.l	512*2

				dc.l	512*3
				dc.l	512*3
				dc.l	512*4
				dc.l	512*4
				dc.l	512*5

				dc.l	512*5
				dc.l	512*6
				dc.l	512*6
				dc.l	512*7
				dc.l	512*7

				dc.l	512*8
				dc.l	512*8
				dc.l	512*9
				dc.l	512*9
				dc.l	512*10

				dc.l	512*10
				dc.l	512*11
				dc.l	512*11
				dc.l	512*12
				dc.l	512*12

				dc.l	512*13
				dc.l	512*13
				dc.l	512*14
				dc.l	512*14

widthleft:		dc.w	0
scaleval:		dc.w	0
sxoff:			dc.l	0
szoff:			dc.l	0
xoff34:			dc.w	0
zoff34:			dc.w	0
scosval:		dc.w	0
ssinval:		dc.w	0


floorsetbright:
				move.l	#WallTilePtrs,a0

pastfloorbright

				move.w	d0,d1
				muls	cosval,d1				; change in x across whole width
				move.w	d0,d2
				muls	sinval,d2				; change in z across whole width
				neg.l	d2
scaleprog:		move.w	scaleval(pc),d3
				beq.s	.samescale
				bgt.s	.scaledown
				neg.w	d3
				asr.l	d3,d1
				asr.l	d3,d2
				bra.s	.samescale
.scaledown:		asl.l	d3,d1
				asl.l	d3,d2
.samescale		move.l	d1,d3					; z cos
				move.l	d3,d6
				move.l	d3,d5
				asr.l	#1,d6
				add.l	d6,d3
				asr.l	#1,d3

				move.l	d2,d4					; z sin
				move.l	d4,d6
				asr.l	#1,d6
				add.l	d4,d6
				add.l	d3,d4
				neg.l	d4						; start x

				asr.l	#1,d6					; zsin/2
				sub.l	d6,d5					; start z

				add.l	sxoff,d4
				add.l	szoff,d5

				moveq	#0,d6
				move.w	leftedge(pc),d6
				beq.s	nomultleft

				move.l	d1,a4
				move.l	d2,a5

				muls.l	d6,d3:d1
				asr.l	#6,d1
				add.l	d1,d4

				muls.l	d6,d3:d2
				asr.l	#6,d2
				add.l	d2,d5
				move.l	a4,d1
				move.l	a5,d2

nomultleft:		move.w	d4,startsmoothx
				move.w	d5,startsmoothz

				swap	d4
				asr.l	#8,d5
; add.w szoff,d5
; add.w sxoff,d4
				and.w	#63,d4
				and.w	#63*256,d5
				move.b	d4,d5

				asr.l	#6,d1
				asr.l	#6,d2
				move.w	d1,a4
				move.w	d2,a5
				asr.l	#8,d2
				and.w	#%0011111100000000,d2
				swap	d1
				add.w	d1,d2
				move.w	#%11111100111111,d1
				and.w	d1,d5
				swap	d5
				move.w	startsmoothz,d5
				swap	d5
				swap	d2
				move.w	a5,d2
				swap	d2

***********************************

				move.w	d6,a2
				move.l	d2,d6
				add.w	#256,d6

				moveq	#0,d0

				tst.w	a2
				beq		startatleftedge

				move.w	widthleft(pc),d4

				move.w	rightedge(pc),d3

				cmp.w	#31,a2
				bgt.s	notinfirststrip
				lea		(a3,a2.w*2),a3
				cmp.w	#32,d3
				ble.s	allinfirststrip
				move.w	#32,d7
				sub.w	d7,d3
				sub.w	a2,d7
				bra		intofirststrip

allinfirststrip
				sub.w	a2,d3
				move.w	d3,d7
				move.w	#0,d4
				bra		allintofirst

notinfirststrip:
				sub.w	#32,a2
				sub.w	#32,d3
				adda.w	#32*2,a3
				cmp.w	#31,a2
				bgt.s	notstartinsec
				lea		(a3,a2.w*2),a3
				cmp.w	#32,d3
				ble.s	allinsecstrip
				move.w	#32,d7
				sub.w	d7,d3
				sub.w	a2,d7
				move.w	d3,d4
				bra		allintofirst

allinsecstrip
				sub.w	a2,d3
				move.w	d3,d7
				move.w	#0,d4
				bra		allintofirst
				rts

notstartinsec:
				sub.w	#32,a2
				sub.w	#32,d3
				adda.w	#32*2,a3
				lea		(a3,a2.w*2),a3
				cmp.w	#32,d3
				ble.s	allinthirdstrip
				move.w	#32,d7
				sub.w	d7,d3
				sub.w	a2,d7
				move.w	d3,d4
				bra		allintofirst
				rts

allinthirdstrip
				sub.w	a2,d3
				move.w	d3,d7
				move.w	#0,d4
				bra		allintofirst

startatleftedge:

				move.w	rightedge(pc),d3
				sub.w	a2,d3

				move.w	d3,d7
				cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide:		sub.w	d7,d3
intofirststrip:

				move.w	d3,d4
allintofirst:

				move.w	startsmoothx,d3

tstwat:			tst.b	gourfloor
				bne		gouraudfloor

				tst.b	usewater
				bne		texturedwater


******************************
* BumpMap the floor/ceiling! *
				tst.b	usebumps
				bne.s	BumpMap
******************************

ordinary:		moveq	#0,d0

				dbra	d7,acrossscrn
				rts

usebumps:		dc.w	$0
smoothbumps:	dc.w	$0
gourfloor:		dc.w	0

				INCLUDE	bumpmap.s

				CNOP	0,4
backbefore:		and.w	d1,d5
				move.b	(a0,d5.w*4),d0
				add.w	a4,d3
				move.w	(a1,d0.w*2),(a3)+
;	addq         #4,a3
				addx.l	d6,d5
				dbcs	d7,acrossscrn
				dbcc	d7,backbefore
				bra.s	past1

acrossscrn:		and.w	d1,d5
				move.b	(a0,d5.w*4),d0
				add.w	a4,d3
				move.w	(a1,d0.w*2),(a3)+
;	addq         #4,a3
				addx.l	d2,d5
				dbcs	d7,acrossscrn
				dbcc	d7,backbefore
past1:			bcc.s	gotoacross

				move.w	d4,d7
				bne.s	.notdoneyet
				rts
.notdoneyet:	cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide		sub.w	d7,d4
	;addq.l	#2,a3

				dbra	d7,backbefore
				rts


gotoacross:		move.w	d4,d7
				bne.s	.notdoneyet
				rts
.notdoneyet:	cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide		sub.w	d7,d4
;	addq         #2,a3

				dbra	d7,acrossscrn
				rts

leftbright:		dc.l	0
brightspd:		dc.l	0

gouraudfloor:
				move.l	leftbright,d0
				move.l	brightspd,d1
				dbra	d7,acrossscrngour
				rts

				CNOP	0,4
backbeforegour:
				and.w	#63*256+63,d5
				move.b	(a0,d5.w*4),d0
				add.l	d1,d0
				bcc.s	.nomoreb
				add.w	#256,d0
.nomoreb:		add.w	a4,d3
				move.w	(a1,d0.w*2),(a3)+
;	addq         #4,a3
				addx.l	d6,d5
				dbcs	d7,acrossscrngour
				dbcc	d7,backbeforegour
				bra.s	past1gour

acrossscrngour:
				and.w	#63*256+63,d5
				move.b	(a0,d5.w*4),d0
				add.l	d1,d0
				bcc.s	.nomoreb
				add.w	#256,d0
.nomoreb:		add.w	a4,d3
				move.w	(a1,d0.w*2),(a3)+
;	addq         #4,a3
				addx.l	d2,d5
				dbcs	d7,acrossscrngour
				dbcc	d7,backbeforegour
past1gour:		bcc.s	gotoacrossgour

				move.w	d4,d7
				bne.s	.notdoneyet
				move.l	d0,leftbright

				rts
.notdoneyet:	cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide		sub.w	d7,d4
	;addq.l	#2,a3

				dbra	d7,backbeforegour
				rts


gotoacrossgour:

				move.w	d4,d7
				bne.s	.notdoneyet
				rts
.notdoneyet:	cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide		sub.w	d7,d4
;	add.l	#2,a3

				dbra	d7,acrossscrngour
				rts


waterpt:		dc.l	waterlist

waterlist:		dc.l	waterfile
				dc.l	waterfile+2
				dc.l	waterfile+256
				dc.l	waterfile+256+2
				dc.l	waterfile+512
				dc.l	waterfile+512+2
				dc.l	waterfile+768
				dc.l	waterfile+768+2
; dc.l waterfile+768
; dc.l waterfile+512+2
; dc.l waterfile+512
; dc.l waterfile+256+2
; dc.l waterfile+256
; dc.l waterfile+2
endwaterlist:

watertouse:		dc.l	waterfile

wtan:			dc.w	0
wateroff:		dc.w	0

texturedwater:

				add.w	wateroff,d5

				move.l	#brightentab,a1
				move.w	dst,d0
				clr.b	d0

				add.w	d0,d0
				cmp.w	#12*512,d0
				blt.s	.notoowater
				move.w	#12*512,d0


.notoowater:	adda.w	d0,a1

				move.w	dst,d0
				asl.w	#7,d0
				add.w	wtan,d0
				and.w	#8191,d0
				move.l	#SineTable,a0
				move.w	(a0,d0.w),d0
				ext.l	d0

				move.w	dst,d3
				add.w	#300,d3
				divs	d3,d0
				asr.w	#6,d0
				addq	#2,d0
				cmp.w	disttobot,d0
				blt.s	oknotoffbototot

				move.w	disttobot,d0
				subq	#1,d0

oknotoffbototot

; move.w dst,d3
; asr.w #7,d3
; add.w d3,d0

				muls	#96*2,d0
				tst.w	above
				beq.s	nonnnnneg
				neg.l	d0

nonnnnneg:		move.l	d0,a6

				move.l	watertouse,a0

				move.w	startsmoothx,d3
				dbra	d7,acrossscrnw
				rts

backbeforew:	and.w	d1,d5
				move.w	(a0,d5.w*4),d0
				move.b	1(a3,a6.w),d0
				move.w	(a1,d0.w*2),(a3)+
	;addq         #4,a3
				add.w	a4,d3
				addx.l	d6,d5
				dbcs	d7,acrossscrnw
				dbcc	d7,backbeforew
				bcc.s	past1w
				add.w	#256,d5
				bra.s	past1w

acrossscrnw:	and.w	d1,d5
				move.w	(a0,d5.w*4),d0
				move.b	1(a3,a6.w),d0
				move.w	(a1,d0.w*2),(a3)+
	;addq         #4,a3
				add.w	a4,d3
				addx.l	d2,d5
				dbcs	d7,acrossscrnw
				dbcc	d7,backbeforew
				bcc.s	past1w
				add.w	#256,d5
past1w:			move.w	d4,d7
				bne.s	.notdoneyet
				rts
.notdoneyet:	cmp.w	#32,d7
				ble.s	.notoowide
				move.w	#32,d7
.notoowide		sub.w	d7,d4
	;addq.l	#2,a3

				dbra	d7,acrossscrnw
				rts

usewater:		dc.w	0
				dc.w	0
startsmoothx:
				dc.w	0
				dc.w	0
startsmoothz:
				dc.w	0

********************************
*
				INCLUDE	objdraw3.s
*
********************************

numframes:		dc.w	0

alframe:		dc.l	0

alan:			dcb.l	8,0
				dcb.l	8,1
				dcb.l	8,2
				dcb.l	8,3
endalan:
alanptr:		dc.l	alan

Time2:			dc.l	0
dispco:			dc.w	0


OldSpace:		dc.b	0
SpaceTapped:	dc.b	0
PLR1_SPCTAP:	dc.b	0
PLR2_SPCTAP:	dc.b	0
PLR1_Ducked:	dc.b	0
PLR2_Ducked:	dc.b	0
				EVEN

				INCLUDE	plr1control.s
				INCLUDE	plr2control.s
				INCLUDE	fall.s

GOTTOSEND:		dc.w	0

				CNOP	0,4

;------------------------------------------------------------------------------

Chan0inter:		SAVEREGS
				jsr		.routine
				GETREGS
				moveq	#0,d0
				rts

.routine		FILTER

				tst.b	doanything
				bne.s	dosomething

				moveq	#0,d0
				rts

;-----

dosomething:	addq.w	#1,FramesToDraw
				movem.l	d0-d7/a0-a6,-(a7)

justshake:		cmp.b	#'b',Prefsfile+3
				bne.s	.noback
				jsr		mt_music
.noback:		bra		dontshowtime

				tst.b	oktodisplay
				beq		dontshowtime
				clr.b	oktodisplay
				subq.w	#1,dispco
				bgt		dontshowtime
				move.w	#10,dispco

				move.l	#TimerScr+10,a0
				move.l	TimeCount,d0
				bge.s	timenotneg
				move.l	#1111*256,d0
timenotneg:		asr.l	#8,d0
				move.l	#digits,a1
				move.w	#7,d2
digitlop		divs	#10,d0
				swap	d0
				lea		(a1,d0.w*8),a2
				move.b	(a2)+,(a0)
				move.b	(a2)+,24(a0)
				move.b	(a2)+,24*2(a0)
				move.b	(a2)+,24*3(a0)
				move.b	(a2)+,24*4(a0)
				move.b	(a2)+,24*5(a0)
				move.b	(a2)+,24*6(a0)
				move.b	(a2)+,24*7(a0)
				subq	#1,a0
				swap	d0
				ext.l	d0
				dbra	d2,digitlop

				move.l	#TimerScr+10+24*10,a0
				move.l	NumTimes,d0
				move.l	#digits,a1
				move.w	#3,d2
digitlop2		divs	#10,d0
				swap	d0
				lea		(a1,d0.w*8),a2
				move.b	(a2)+,(a0)
				move.b	(a2)+,24(a0)
				move.b	(a2)+,24*2(a0)
				move.b	(a2)+,24*3(a0)
				move.b	(a2)+,24*4(a0)
				move.b	(a2)+,24*5(a0)
				move.b	(a2)+,24*6(a0)
				move.b	(a2)+,24*7(a0)
				subq	#1,a0
				swap	d0
				ext.l	d0
				dbra	d2,digitlop2

				move.l	#TimerScr+10+24*20,a0
				moveq	#0,d0
				move.w	FramesToDraw,d0
				move.l	#digits,a1
				move.w	#2,d2
digitlop3		divs	#10,d0
				swap	d0
				lea		(a1,d0.w*8),a2
				move.b	(a2)+,(a0)
				move.b	(a2)+,24(a0)
				move.b	(a2)+,24*2(a0)
				move.b	(a2)+,24*3(a0)
				move.b	(a2)+,24*4(a0)
				move.b	(a2)+,24*5(a0)
				move.b	(a2)+,24*6(a0)
				move.b	(a2)+,24*7(a0)
				subq	#1,a0
				swap	d0
				ext.l	d0
				dbra	d2,digitlop3

dontshowtime:
				move.l	alanptr,a0
				move.l	(a0)+,alframe
				cmp.l	#endalan,a0
				blt.s	nostartalan
				move.l	#alan,a0
nostartalan:	move.l	a0,alanptr

				jsr		ProcGameIntuiMsg		;Process messages waiting for us

				tst.b	READCONTROLS
				beq.s	nocontrols

				cmp.b	#'s',mors
				beq.s	control2

				tst.b	PLR1MOUSE
				beq.s	PLR1_nomouse
				bsr		PLR1_mouse_control
PLR1_nomouse:
				tst.b	PLR1KEYS
				beq.s	PLR1_nokeys
				bsr		PLR1_keyboard_control
PLR1_nokeys:
; tst.b PLR1PATH
; beq.s PLR1_nopath
; bsr PLR1_follow_path
;PLR1_nopath:
				tst.b	PLR1JOY
				beq.s	PLR1_nojoy
				bsr		PLR1_JoyStick_control
PLR1_nojoy:		bra.s	nocontrols

control2:		tst.b	PLR2MOUSE
				beq.s	PLR2_nomouse
				bsr		PLR2_mouse_control
PLR2_nomouse:
				tst.b	PLR2KEYS
				beq.s	PLR2_nokeys
				bsr		PLR2_keyboard_control
PLR2_nokeys:
; tst.b PLR2PATH
; beq.s PLR2_nopath
; bsr PLR1_follow_path
;PLR2_nopath:
				tst.b	PLR2JOY
				beq.s	PLR2_nojoy
				bsr		PLR2_JoyStick_control
PLR2_nojoy:

nocontrols:		movem.l	(a7)+,d0-d7/a0-a6
				moveq	#0,d0
				rts




				move.l	#$dff000,a6

				cmp.b	#'4',Prefsfile+1
				bne.s	nomuckabout

				move.w	#$0,d0
				tst.b	NoiseMade0LEFT
				beq.s	noturnoff0
				move.w	#1,d0
noturnoff0:		tst.b	NoiseMade0RIGHT
				beq.s	noturnoff1
				or.w	#2,d0
noturnoff1:		tst.b	NoiseMade1RIGHT
				beq.s	noturnoff2
				or.w	#4,d0
noturnoff2:		tst.b	NoiseMade1LEFT
				beq.s	noturnoff3
				or.w	#8,d0
noturnoff3:		move.w	d0,dmacon(a6)

nomuckabout:
; tst.b PLR2_fire
; beq.s firenotpressed2
; fire was pressed last time.
; btst #7,$bfe001
; bne.s firenownotpressed2
; fire is still pressed this time.
; st PLR2_fire
; bra dointer

firenownotpressed2:
; fire has been released.
; clr.b PLR2_fire
; bra dointer

firenotpressed2

; fire was not pressed last frame...

; btst #7,$bfe001
; if it has still not been pressed, go back above
; bne.s firenownotpressed2
; fire was not pressed last time, and was this time, so has
; been clicked.
; st PLR2_clicked
; st PLR2_fire

dointer			cmp.b	#'4',Prefsfile+1
				beq		fourchannel

				btst	#1,$dff000+intreqr
				bne.s	newsampbitl

				movem.l	(a7)+,d0-d7/a0-a6
				moveq	#0,d0
				rts

;------------------------------------------------------------------------------


swappedem:		dc.w	0

newsampbitl:	move.w	#$820f,$dff000+dmacon

				move.w	#$200,$dff000+intreq

; tst.b CHANNELDATA
; bne nochannel0

				move.l	pos0LEFT,a0
				move.l	pos2LEFT,a1

				move.l	#tab,a2

				moveq	#0,d0
				moveq	#0,d1
				move.b	vol0left,d0
				move.b	vol2left,d1
				cmp.b	d1,d0
				slt		swappedem
				bge.s	fbig0

; d1 is bigger so scale d0 and use d1
; as audiochannel volume.

				exg		a0,a1
				asl.w	#6,d0
				divs	d1,d0
				lsl.w	#8,d0
				adda.w	d0,a2
				move.w	d1,$dff0a8
				bra.s	donechan0

fbig0:			tst.w	d0
				beq.s	donechan0
				asl.w	#6,d1
				divs	d0,d1
				lsl.w	#8,d1
				adda.w	d1,a2
				move.w	d0,$dff0a8

donechan0:		move.l	Aupt0,a3
				move.l	a3,$dff0a0
				move.l	Auback0,Aupt0
				move.l	a3,Auback0

				move.l	Auback0,a3

				moveq	#0,d0
				moveq	#0,d1
				moveq	#0,d2
				moveq	#0,d3
				moveq	#0,d4
				moveq	#0,d5
				move.w	#49,d7
loop:			move.l	(a0)+,d0
				move.b	(a1)+,d1
				move.b	(a1)+,d2
				move.b	(a1)+,d3
				move.b	(a1)+,d4
				move.b	(a2,d3.w),d5
				swap	d5
				move.b	(a2,d1.w),d5
				asl.l	#8,d5
				move.b	(a2,d2.w),d5
				swap	d5
				move.b	(a2,d4.w),d5
				add.l	d5,d0
				move.l	d0,(a3)+
				dbra	d7,loop

				tst.b	swappedem
				beq.s	.ok23
				exg		a0,a1
.ok23:			cmp.l	Samp0endLEFT,a0
				blt.s	.notoffendsamp1
				move.l	SampleList+6*8,a0
				move.l	SampleList+6*8+4,Samp0endLEFT
				move.b	#63,vol0left
				st		LEFTCHANDATA+1
				move.w	#0,LEFTCHANDATA+2
.notoffendsamp1:

				cmp.l	Samp2endLEFT,a1
				blt.s	.notoffendsamp2
				move.l	#empty,a1
				move.l	#emptyend,Samp2endLEFT
				move.b	#0,vol2left
				st		LEFTCHANDATA+1+8
				move.w	#0,LEFTCHANDATA+2+8
.notoffendsamp2:

				move.l	a0,pos0LEFT
				move.l	a1,pos2LEFT

nochannel0:		tst.b	CHANNELDATA+16
				bne		nochannel1


				move.l	pos0RIGHT,a0
				move.l	pos2RIGHT,a1

				move.l	Aupt1,a3
				move.l	a3,$dff0b0
				move.l	Auback1,Aupt1
				move.l	a3,Auback1

				move.l	#tab,a2

				moveq	#0,d0
				moveq	#0,d1
				move.b	vol0right,d0
				move.b	vol2right,d1
				cmp.b	d1,d0
				slt		swappedem
				bge.s	fbig1

; d1 is bigger so scale d0 and use d1
; as audiochannel volume.

				exg		a0,a1
				asl.w	#6,d0
				divs	d1,d0
				lsl.w	#8,d0
				adda.w	d0,a2
				move.w	d1,$dff0b8
				bra.s	donechan1

fbig1:			tst.w	d0
				beq.s	donechan1
				asl.w	#6,d1
				divs	d0,d1
				lsl.w	#8,d1
				adda.w	d1,a2
				move.w	d0,$dff0b8

donechan1:		moveq	#0,d0
				moveq	#0,d1
				moveq	#0,d2
				moveq	#0,d3
				moveq	#0,d4
				moveq	#0,d5
				move.w	#49,d7
loop2:			move.l	(a0)+,d0
				move.b	(a1)+,d1
				move.b	(a1)+,d2
				move.b	(a1)+,d3
				move.b	(a1)+,d4
				move.b	(a2,d3.w),d5
				swap	d5
				move.b	(a2,d1.w),d5
				asl.l	#8,d5
				move.b	(a2,d2.w),d5
				swap	d5
				move.b	(a2,d4.w),d5
				add.l	d5,d0
				move.l	d0,(a3)+
				dbra	d7,loop2

				tst.b	swappedem
				beq.s	ok01
				exg		a0,a1
ok01:			cmp.l	Samp0endRIGHT,a0
				blt.s	.notoffendsamp1
				move.l	#empty,a0
				move.l	#emptyend,Samp0endRIGHT
				move.b	#0,vol0right
				st		RIGHTCHANDATA+1
				move.w	#0,RIGHTCHANDATA+2
.notoffendsamp1:

				cmp.l	Samp2endRIGHT,a1
				blt.s	.notoffendsamp2
				move.l	#empty,a1
				move.l	#emptyend,Samp2endRIGHT
				move.b	#0,vol2right
				st		RIGHTCHANDATA+1+8
				move.w	#0,RIGHTCHANDATA+2+8
.notoffendsamp2:

				move.l	a0,pos0RIGHT
				move.l	a1,pos2RIGHT

nochannel1:
******************* Other two channels

				move.l	pos1LEFT,a0
				move.l	pos3LEFT,a1

				move.l	#tab,a2

				moveq	#0,d0
				moveq	#0,d1
				move.b	vol1left,d0
				move.b	vol3left,d1
				cmp.b	d1,d0
				slt		swappedem
				bge.s	fbig2

; d1 is bigger so scale d0 and use d1
; as audiochannel volume.

				exg		a0,a1
				asl.w	#6,d0
				divs	d1,d0
				lsl.w	#8,d0
				adda.w	d0,a2
				move.w	d1,$dff0d8
				bra.s	donechan2

fbig2:			tst.w	d0
				beq.s	donechan2
				asl.w	#6,d1
				divs	d0,d1
				lsl.w	#8,d1
				adda.w	d1,a2
				move.w	d0,$dff0d8

donechan2:		move.l	Aupt2,a3
				move.l	a3,$dff0d0
				move.l	Auback2,Aupt2
				move.l	a3,Auback2

				moveq	#0,d0
				moveq	#0,d1
				moveq	#0,d2
				moveq	#0,d3
				moveq	#0,d4
				moveq	#0,d5
				move.w	#49,d7
loop3:			move.l	(a0)+,d0
				move.b	(a1)+,d1
				move.b	(a1)+,d2
				move.b	(a1)+,d3
				move.b	(a1)+,d4
				move.b	(a2,d3.w),d5
				swap	d5
				move.b	(a2,d1.w),d5
				asl.l	#8,d5
				move.b	(a2,d2.w),d5
				swap	d5
				move.b	(a2,d4.w),d5
				add.l	d5,d0
				move.l	d0,(a3)+
				dbra	d7,loop3

				tst.b	swappedem
				beq.s	.ok23
				exg		a0,a1
.ok23:			cmp.l	Samp1endLEFT,a0
				blt.s	.notoffendsamp3
				move.l	#empty,a0
				move.l	#emptyend,Samp1endLEFT
				move.b	#0,vol1left
				st		LEFTCHANDATA+1+4
				move.w	#0,LEFTCHANDATA+2+4
.notoffendsamp3:

				cmp.l	Samp3endLEFT,a1
				blt.s	.notoffendsamp4
				move.l	#empty,a1
				move.l	#emptyend,Samp3endLEFT
				move.b	#0,vol3left
				st		LEFTCHANDATA+1+12
				move.w	#0,LEFTCHANDATA+2+12
.notoffendsamp4:

				move.l	a0,pos1LEFT
				move.l	a1,pos3LEFT

				move.l	pos1RIGHT,a0
				move.l	pos3RIGHT,a1

				move.l	Aupt3,a3
				move.l	a3,$dff0c0
				move.l	Auback3,Aupt3
				move.l	a3,Auback3

				move.l	#tab,a2

				moveq	#0,d0
				moveq	#0,d1
				move.b	vol1right,d0
				move.b	vol3right,d1
				cmp.b	d1,d0
				slt		swappedem
				bge.s	fbig3

				exg		a0,a1
				asl.w	#6,d0
				divs	d1,d0
				lsl.w	#8,d0
				adda.w	d0,a2
				move.w	d1,$dff0c8
				bra.s	donechan3

fbig3:			tst.w	d0
				beq.s	donechan3
				asl.w	#6,d1
				divs	d0,d1
				lsl.w	#8,d1
				adda.w	d1,a2
				move.w	d0,$dff0c8
donechan3:		moveq	#0,d0
				moveq	#0,d1
				moveq	#0,d2
				moveq	#0,d3
				moveq	#0,d4
				moveq	#0,d5
				move.w	#49,d7
loop4:			move.l	(a0)+,d0
				move.b	(a1)+,d1
				move.b	(a1)+,d2
				move.b	(a1)+,d3
				move.b	(a1)+,d4
				move.b	(a2,d3.w),d5
				swap	d5
				move.b	(a2,d1.w),d5
				asl.l	#8,d5
				move.b	(a2,d2.w),d5
				swap	d5
				move.b	(a2,d4.w),d5
				add.l	d5,d0
				move.l	d0,(a3)+
				dbra	d7,loop4

				tst.b	swappedem
				beq.s	.ok23
				exg		a0,a1
.ok23:			cmp.l	Samp1endRIGHT,a0
				blt.s	notoffendsamp3
				move.l	#empty,a0
				move.l	#emptyend,Samp1endRIGHT
				move.b	#0,vol1right
				st		RIGHTCHANDATA+1+4
				move.w	#0,RIGHTCHANDATA+2+4
notoffendsamp3:

				cmp.l	Samp3endRIGHT,a1
				blt.s	notoffendsamp4
				move.l	#empty,a1
				move.l	#emptyend,Samp3endRIGHT
				move.b	#0,vol3right
				st		RIGHTCHANDATA+1+12
				move.w	#0,RIGHTCHANDATA+2+12
notoffendsamp4:

				move.l	a0,pos1RIGHT
				move.l	a1,pos3RIGHT

				movem.l	(a7)+,d0-d7/a0-a6
				tst.b	counting
				beq		.nostartcounter
				JSR		STARTCOUNT
.nostartcounter:

				moveq	#0,d0
				rts

***********************************
* 4 channel sound routine
***********************************

fourchannel:	move.l	#$dff000,a6

				btst	#7,intreqr+1(a6)
				beq.s	nofinish0
; move.w #0,LEFTCHANDATA+2
; st LEFTCHANDATA+1
				move.l	#null,$a0(a6)
				move.w	#100,$a4(a6)
				move.w	#$0080,intreq(a6)
nofinish0:		tst.b	NoiseMade0pLEFT
				beq.s	NoChan0sound

				move.l	Samp0endLEFT,d0
				move.l	pos0LEFT,d1
				sub.l	d1,d0
				lsr.l	#1,d0
				move.w	d0,$a4(a6)
				move.l	d1,$a0(a6)
				move.w	#$8201,dmacon(a6)
				moveq	#0,d0
				move.b	vol0left,d0
				move.w	d0,$a8(a6)

NoChan0sound:

*****************************************
*****************************************

				btst	#0,intreqr(a6)
				beq.s	nofinish1
				move.l	#null,$b0(a6)
				move.w	#100,$b4(a6)
				move.w	#$0100,intreq(a6)
nofinish1:		tst.b	NoiseMade0pRIGHT
				beq.s	NoChan1sound

				move.l	Samp0endRIGHT,d0
				move.l	pos0RIGHT,d1
				sub.l	d1,d0
				lsr.l	#1,d0
				move.w	d0,$b4(a6)
				move.l	d1,$b0(a6)
				move.w	d0,playnull1
				move.w	#$8202,dmacon(a6)
				moveq	#0,d0
				move.b	vol0right,d0
				move.w	d0,$b8(a6)

NoChan1sound:

*****************************************
*****************************************

				btst	#1,intreqr(a6)
				beq.s	nofinish2
				move.l	#null,$c0(a6)
				move.w	#100,$c4(a6)
				move.w	#$0200,intreq(a6)
nofinish2:		tst.b	NoiseMade1pRIGHT
				beq.s	NoChan2sound

				move.l	Samp1endRIGHT,d0
				move.l	pos1RIGHT,d1
				sub.l	d1,d0
				lsr.l	#1,d0
				move.w	d0,$c4(a6)
				move.w	d0,playnull2

				move.l	d1,$c0(a6)
				move.w	#$8204,dmacon(a6)
				moveq	#0,d0
				move.b	vol1right,d0
				move.w	d0,$c8(a6)

NoChan2sound:

*****************************************
*****************************************

				btst	#2,intreqr(a6)
				beq.s	nofinish3
				move.l	#null,$d0(a6)
				move.w	#100,$d4(a6)
				move.w	#$0400,intreq(a6)
nofinish3:		tst.b	NoiseMade1pLEFT
				beq.s	NoChan3sound

				move.l	Samp1endLEFT,d0
				move.l	pos1LEFT,d1
				sub.l	d1,d0
				lsr.l	#1,d0
				move.w	d0,$d4(a6)
				move.w	d0,playnull3
				move.l	d1,$d0(a6)
				move.w	#$8208,dmacon(a6)
				moveq	#0,d0
				move.b	vol1left,d0
				move.w	d0,$d8(a6)

NoChan3sound:

nomorechannels:

				move.l	NoiseMade0LEFT,NoiseMade0pLEFT
				move.l	#0,NoiseMade0LEFT
				move.l	NoiseMade0RIGHT,NoiseMade0pRIGHT
				move.l	#0,NoiseMade0RIGHT

; tst.b playnull0
; beq.s .nnul
; sub.b #1,playnull0
; bra.s chan0still
;.nnul:
;
;chan0still:

				tst.b	NoiseMade0pLEFT
				bne.s	chan0still
				tst.w	playnull0
				beq.s	nnul0
				sub.w	#100,playnull0
				bra.s	chan0still
nnul0:			move.w	#0,LEFTCHANDATA+2
				st		LEFTCHANDATA+1
chan0still:		tst.b	NoiseMade0pRIGHT
				bne.s	chan1still
				tst.w	playnull1
				beq.s	nnul1
				sub.w	#100,playnull1
				bra.s	chan1still
nnul1:			move.w	#0,RIGHTCHANDATA+2
				st		RIGHTCHANDATA+1
chan1still:		tst.b	NoiseMade1pRIGHT
				bne.s	chan2still
				tst.w	playnull2
				beq.s	nnul2
				sub.w	#100,playnull2
				bra.s	chan2still
nnul2:			move.w	#0,RIGHTCHANDATA+2+4
				st		RIGHTCHANDATA+1+4
chan2still:		tst.b	NoiseMade1pLEFT
				bne.s	chan3still
				tst.w	playnull3
				beq.s	nnul3
				sub.w	#100,playnull3
				bra.s	chan3still
nnul3:			move.w	#0,LEFTCHANDATA+2+4
				st		LEFTCHANDATA+1+4

chan3still:		movem.l	(a7)+,d0-d7/a0-a6

				moveq	#0,d0
				rts

backbeat:		dc.w	0

playnull0:		dc.w	0
playnull1:		dc.w	0
playnull2:		dc.w	0
playnull3:		dc.w	0

Samp0endRIGHT:
				dc.l	emptyend
Samp1endRIGHT:
				dc.l	emptyend
Samp2endRIGHT:
				dc.l	emptyend
Samp3endRIGHT:
				dc.l	emptyend
Samp0endLEFT:
				dc.l	emptyend
Samp1endLEFT:
				dc.l	emptyend
Samp2endLEFT:
				dc.l	emptyend
Samp3endLEFT:
				dc.l	emptyend

Aupt0:			dc.l	null
Auback0:		dc.l	null+500
Aupt2:			dc.l	null3
Auback2:		dc.l	null3+500
Aupt3:			dc.l	null4
Auback3:		dc.l	null4+500
Aupt1:			dc.l	null2
Auback1:		dc.l	null2+500

NoiseMade0LEFT:
				dc.b	0
NoiseMade1LEFT:
				dc.b	0
NoiseMade2LEFT:
				dc.b	0
NoiseMade3LEFT:
				dc.b	0
NoiseMade0pLEFT:
				dc.b	0
NoiseMade1pLEFT:
				dc.b	0
NoiseMade2pLEFT:
				dc.b	0
NoiseMade3pLEFT:
				dc.b	0
NoiseMade0RIGHT:
				dc.b	0
NoiseMade1RIGHT:
				dc.b	0
NoiseMade2RIGHT:
				dc.b	0
NoiseMade3RIGHT:
				dc.b	0
NoiseMade0pRIGHT:
				dc.b	0
NoiseMade1pRIGHT:
				dc.b	0
NoiseMade2pRIGHT:
				dc.b	0
NoiseMade3pRIGHT:
				dc.b	0

empty:			ds.l	100
emptyend:
**************************************
* I want a routine to calculate all the
* info needed for the sound player to
* work, given say position of noise, volume
* and sample number.

Samplenum:		dc.w	0
Noisex:			dc.w	0
Noisez:			dc.w	0
Noisevol:		dc.w	0
chanpick:		dc.w	0
IDNUM:			dc.w	0
needleft:		dc.b	0
needright:		dc.b	0
STEREO:			dc.b	$0
EVEN
prot6:			dc.w	0

				EVEN

CHANNELDATA:
LEFTCHANDATA:
				dc.l	$00000000
				dc.l	$00000000
				dc.l	$FF000000
				dc.l	$FF000000
RIGHTCHANDATA:
				dc.l	$00000000
				dc.l	$00000000
				dc.l	$FF000000
				dc.l	$FF000000

RIGHTPLAYEDTAB:
				ds.l	20
LEFTPLAYEDTAB:
				ds.l	20

MakeSomeNoise:

; Plan for new sound handler:
; It is sent a sample number,
; a position relative to the
; player, an id number and a volume.
; Also notifplaying.

; indirect inputs are the available
; channel flags and whether or not
; stereo sound is selected.

; the algorithm must decide
; whether the new sound is more
; important than the ones already
; playing. Thus an 'importance'
; must be calculated, probably
; using volume.

; The output needs to be:

; Write the pointers and volumes of
; the sound channels


				tst.b	notifplaying
				beq.s	dontworry

; find if we are already playing

				move.b	IDNUM,d0
				move.w	#7,d1
				lea		CHANNELDATA,a3
findsameasme	tst.b	(a3)
				bne.s	notavail
				cmp.b	1(a3),d0
				beq		SameAsMe
notavail:		add.w	#4,a3
				dbra	d1,findsameasme
				bra		dontworry
SameAsMe		rts

noiseloud:		dc.w	0

dontworry:
; Ok its fine for us to play a sound.
; So calculate left/right volume.

				move.w	Noisex,d1
				muls	d1,d1
				move.w	Noisez,d2
				muls	d2,d2
				move.w	#64,d3
				move.w	#32767,noiseloud
				moveq	#1,d0
				add.l	d1,d2
				beq		pastcalc

				move.w	#31,d0
.findhigh		btst	d0,d2
				bne		.foundhigh
				dbra	d0,.findhigh
.foundhigh		asr.w	#1,d0
				clr.l	d3
				bset	d0,d3
				move.l	d3,d0

				move.w	d0,d3
				muls	d3,d3					; x*x
				sub.l	d2,d3					; x*x-a
				asr.l	#1,d3					; (x*x-a)/2
				divs	d0,d3					; (x*x-a)/2x
				sub.w	d3,d0					; second approx
				bgt		.stillnot0
				move.w	#1,d0
.stillnot0		move.w	d0,d3
				muls	d3,d3
				sub.l	d2,d3
				asr.l	#1,d3
				divs	d0,d3
				sub.w	d3,d0					; second approx
				bgt		.stillnot02
				move.w	#1,d0
.stillnot02		move.w	Noisevol,d3
				ext.l	d3
				asl.l	#6,d3
				cmp.l	#32767,d3
				ble.s	.nnnn
				move.l	#32767,d3
.nnnn			asr.w	#2,d0
				addq	#1,d0
				divs	d0,d3

				move.w	d3,noiseloud

				cmp.w	#64,d3
				ble.s	notooloud
				move.w	#64,d3
notooloud:
pastcalc:		;		d3						contains volume of noise.

				move.w	d3,d4

				move.w	d3,d2
				muls	Noisex,d2
				asl.w	#3,d0
				divs	d0,d2

				bgt.s	quietleft
				add.w	d2,d4
				bge.s	donequiet
				move.w	#0,d4
				bra.s	donequiet
quietleft:		sub.w	d2,d3
				bge.s	donequiet
				move.w	#0,d3
donequiet:
; d3=leftvol?
; d4=rightvol?

				clr.w	needleft

				cmp.b	d3,d4
				bgt.s	RightLouder

; Left is louder; is it MUCH louder?

				st		needleft
				move.w	d3,d2
				sub.w	d4,d2
				cmp.w	#32,d2
				slt		needright
				bra		aboutsame

RightLouder:	st		needright
				move.w	d4,d2
				sub.w	d3,d2
				cmp.w	#32,d2
				slt		needleft

aboutsame:		tst.b	STEREO
				beq		NOSTEREO

; Find least important sound on left

				move.l	#0,a2
				move.l	#0,d5
				move.w	#32767,d2
				move.b	IDNUM,d0
				lea		LEFTCHANDATA,a3
				move.w	#3,d1
FindLeftChannel
				tst.b	(a3)
				bne.s	.notactive
				cmp.b	1(a3),d0
				beq.s	FOUNDLEFT
				cmp.w	2(a3),d2
				blt.s	.notactive
				move.w	2(a3),d2
				move.l	a3,a2
				move.w	d5,d6

.notactive:		add.w	#4,a3
				add.w	#1,d5
				dbra	d1,FindLeftChannel
				move.l	a2,a3
				bra.s	gopastleft
FOUNDLEFT:		move.w	d5,d6
gopastleft:		tst.l	a3
				bne.s	FOUNDALEFT
				rts
FOUNDALEFT:
; d6 = channel number
				move.b	d0,1(a3)
				move.w	d3,2(a3)

				move.w	Samplenum,d5
				move.l	#SampleList,a3
				move.l	(a3,d5.w*8),a1
				move.l	4(a3,d5.w*8),a2

				tst.b	d6
				seq		NoiseMade0LEFT
				beq.s	.chan0
				cmp.b	#2,d6
				slt		NoiseMade1LEFT
				blt		.chan1
				seq		NoiseMade2LEFT
				beq		.chan2
				st		NoiseMade3LEFT

				move.b	d5,LEFTPLAYEDTAB+9
				move.b	d3,LEFTPLAYEDTAB+1+9
				move.b	d4,LEFTPLAYEDTAB+2+9
				move.b	d3,vol3left
				move.l	a1,pos3LEFT
				move.l	a2,Samp3endLEFT
				bra		dorightchan

.chan0:			move.b	d5,LEFTPLAYEDTAB
				move.b	d3,LEFTPLAYEDTAB+1
				move.b	d4,LEFTPLAYEDTAB+2
				move.l	a1,pos0LEFT
				move.l	a2,Samp0endLEFT
				move.b	d3,vol0left
				bra		dorightchan

.chan1:			move.b	d5,LEFTPLAYEDTAB+3
				move.b	d3,LEFTPLAYEDTAB+1+3
				move.b	d4,LEFTPLAYEDTAB+2+3
				move.b	d3,vol1left
				move.l	a1,pos1LEFT
				move.l	a2,Samp1endLEFT
				bra		dorightchan

.chan2:			move.b	d5,LEFTPLAYEDTAB+6
				move.b	d3,LEFTPLAYEDTAB+1+6
				move.b	d4,LEFTPLAYEDTAB+2+6
				move.l	a1,pos2LEFT
				move.l	a2,Samp2endLEFT
				move.b	d3,vol2left

dorightchan:
; Find least important sound on right

				move.l	#0,a2
				move.l	#0,d5
				move.w	#10000,d2
				move.b	IDNUM,d0
				lea		RIGHTCHANDATA,a3
				move.w	#3,d1
FindRightChannel
				tst.b	(a3)
				bne.s	.notactive
				cmp.b	1(a3),d0
				beq.s	FOUNDRIGHT
				cmp.w	2(a3),d2
				blt.s	.notactive
				move.w	2(a3),d2
				move.l	a3,a2
				move.w	d5,d6

.notactive:		add.w	#4,a3
				add.w	#1,d5
				dbra	d1,FindRightChannel
				move.l	a2,a3
				bra.s	gopastright
FOUNDRIGHT:		move.w	d5,d6
gopastright:	tst.l	a3
				bne.s	FOUNDARIGHT
				rts
FOUNDARIGHT:
; d6 = channel number
				move.b	d0,1(a3)
				move.w	d3,2(a3)

				move.w	Samplenum,d5
				move.l	#SampleList,a3
				move.l	(a3,d5.w*8),a1
				move.l	4(a3,d5.w*8),a2

				tst.b	d6
				seq		NoiseMade0RIGHT
				beq.s	.chan0
				cmp.b	#2,d6
				slt		NoiseMade1RIGHT
				blt		.chan1
				seq		NoiseMade2RIGHT
				beq		.chan2
				st		NoiseMade3RIGHT

				move.b	d5,RIGHTPLAYEDTAB+9
				move.b	d3,RIGHTPLAYEDTAB+1+9
				move.b	d4,RIGHTPLAYEDTAB+2+9
				move.b	d4,vol3right
				move.l	a1,pos3RIGHT
				move.l	a2,Samp3endRIGHT
				rts

.chan0:			move.b	d5,RIGHTPLAYEDTAB
				move.b	d3,RIGHTPLAYEDTAB+1
				move.b	d4,RIGHTPLAYEDTAB+2
				move.l	a1,pos0RIGHT
				move.l	a2,Samp0endRIGHT
				move.b	d4,vol0right
				rts

.chan1:			move.b	d5,RIGHTPLAYEDTAB+3
				move.b	d3,RIGHTPLAYEDTAB+1+3
				move.b	d4,RIGHTPLAYEDTAB+2+3
				move.b	d3,vol1right
				move.l	a1,pos1RIGHT
				move.l	a2,Samp1endRIGHT
				rts

.chan2:			move.b	d5,RIGHTPLAYEDTAB+6
				move.b	d3,RIGHTPLAYEDTAB+1+6
				move.b	d4,RIGHTPLAYEDTAB+2+6
				move.l	a1,pos2RIGHT
				move.l	a2,Samp2endRIGHT
				move.b	d3,vol2right
				rts

NOSTEREO:		move.l	#0,a2
				move.l	#-1,d5
				move.w	#32767,d2
				move.b	IDNUM,d0
				lea		CHANNELDATA,a3
				move.w	#7,d1
FindChannel		tst.b	(a3)
				bne.s	.notactive
				cmp.b	1(a3),d0
				beq.s	FOUNDCHAN
				cmp.w	2(a3),d2
				blt.s	.notactive
				move.w	2(a3),d2
				move.l	a3,a2
				move.w	d5,d6
				add.w	#1,d6

.notactive:		add.w	#4,a3
				add.w	#1,d5
				dbra	d1,FindChannel

				move.l	a2,a3
				bra.s	gopastchan
FOUNDCHAN:		move.w	d5,d6
				add.w	#1,d6
gopastchan:		tst.w	d6
				bge.s	FOUNDACHAN
tooquiet:		rts
FOUNDACHAN:
; d6 = channel number

				cmp.w	noiseloud,d2
				bgt.s	tooquiet

				move.b	d0,1(a3)
				move.w	noiseloud,2(a3)

				move.w	Samplenum,d5
				move.l	#SampleList,a3
				move.l	(a3,d5.w*8),a1
				move.l	4(a3,d5.w*8),a2

				tst.b	d6
				beq		.chan0
				cmp.b	#2,d6
				blt		.chan1
				beq		.chan2
				cmp.b	#4,d6
				blt		.chan3
				beq		.chan4
				cmp.b	#6,d6
				blt		.chan5
				beq		.chan6
				st		NoiseMade3RIGHT

				move.b	d5,RIGHTPLAYEDTAB+9
				move.b	d3,RIGHTPLAYEDTAB+1+9
				move.b	d4,RIGHTPLAYEDTAB+2+9
				move.b	d4,vol3right
				move.l	a1,pos3RIGHT
				move.l	a2,Samp3endRIGHT
				rts

.chan3:			st		NoiseMade3LEFT
				move.b	d5,LEFTPLAYEDTAB+9
				move.b	d3,LEFTPLAYEDTAB+1+9
				move.b	d4,LEFTPLAYEDTAB+2+9
				move.b	d3,vol3left
				move.l	a1,pos3LEFT
				move.l	a2,Samp3endLEFT
				bra		dorightchan

.chan0:			st		NoiseMade0LEFT
				move.b	d5,LEFTPLAYEDTAB
				move.b	d3,LEFTPLAYEDTAB+1
				move.b	d4,LEFTPLAYEDTAB+2
				move.l	a1,pos0LEFT
				move.l	a2,Samp0endLEFT
				move.b	d3,vol0left
				rts

.chan1:			st		NoiseMade1LEFT
				move.b	d5,LEFTPLAYEDTAB+3
				move.b	d3,LEFTPLAYEDTAB+1+3
				move.b	d4,LEFTPLAYEDTAB+2+3
				move.b	d3,vol1left
				move.l	a1,pos1LEFT
				move.l	a2,Samp1endLEFT
				rts

.chan2:			st		NoiseMade2LEFT
				move.b	d5,LEFTPLAYEDTAB+6
				move.b	d3,LEFTPLAYEDTAB+1+6
				move.b	d4,LEFTPLAYEDTAB+2+6
				move.l	a1,pos2LEFT
				move.l	a2,Samp2endLEFT
				move.b	d3,vol2left
				rts

.chan4:			st		NoiseMade0RIGHT
				move.b	d5,RIGHTPLAYEDTAB
				move.b	d3,RIGHTPLAYEDTAB+1
				move.b	d4,RIGHTPLAYEDTAB+2
				move.l	a1,pos0RIGHT
				move.l	a2,Samp0endRIGHT
				move.b	d4,vol0right
				rts

.chan5:			st		NoiseMade1RIGHT
				move.b	d5,RIGHTPLAYEDTAB+3
				move.b	d3,RIGHTPLAYEDTAB+1+3
				move.b	d4,RIGHTPLAYEDTAB+2+3
				move.b	d3,vol1right
				move.l	a1,pos1RIGHT
				move.l	a2,Samp1endRIGHT
				rts

.chan6:			st		NoiseMade2RIGHT
				move.b	d5,RIGHTPLAYEDTAB+6
				move.b	d3,RIGHTPLAYEDTAB+1+6
				move.b	d4,RIGHTPLAYEDTAB+2+6
				move.l	a1,pos2RIGHT
				move.l	a2,Samp2endRIGHT
				move.b	d3,vol2right
				rts

SampleList:		dc.l	Scream,EndScream
				dc.l	Shoot,EndShoot
				dc.l	Munch,EndMunch
				dc.l	PooGun,EndPooGun
				dc.l	Collect,EndCollect
;5
				dc.l	DoorNoise,EndDoorNoise
				dc.l	0,0
				dc.l	Stomp,EndStomp
				dc.l	LowScream,EndLowScream
				dc.l	BaddieGun,EndBaddieGun
;10
				dc.l	SwitchNoise,EndSwitch
				dc.l	Reload,EndReload
				dc.l	NoAmmo,EndNoAmmo
				dc.l	Splotch,EndSplotch
				dc.l	SplatPop,EndSplatPop
;15
				dc.l	Boom,EndBoom
				dc.l	Hiss,EndHiss
				dc.l	Howl1,EndHowl1
				dc.l	Howl2,EndHowl2
				dc.l	Pant,EndPant
;20
				dc.l	Whoosh,EndWhoosh
				dc.l	ROAR,EndROAR
				dc.l	Whoosh,EndWhoosh
				dc.l	0,0
				dc.l	0,0
				dc.l	0,0
				dc.l	0,0
				dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

				dc.l	0

storeval:		dc.w	0

				INCLUDE	wallchunk.s
				INCLUDE	loadfromdisk.s

saveinters:		dc.w	0

z:				dc.w	10

notifplaying:
				dc.w	0

audpos1:		dc.w	0
audpos1b:		dc.w	0
audpos2:		dc.w	0
audpos2b:		dc.w	0
audpos3:		dc.w	0
audpos3b:		dc.w	0
audpos4:		dc.w	0
audpos4b:		dc.w	0

vol0left:		dc.w	0
vol0right:		dc.w	0
vol1left:		dc.w	0
vol1right:		dc.w	0
vol2left:		dc.w	0
vol2right:		dc.w	0
vol3left:		dc.w	0
vol3right:		dc.w	0

pos:			dc.l	0

pos0LEFT:		dc.l	empty
pos1LEFT:		dc.l	empty
pos2LEFT:		dc.l	empty
pos3LEFT:		dc.l	empty
pos0RIGHT:		dc.l	empty
pos1RIGHT:		dc.l	empty
pos2RIGHT:		dc.l	empty
pos3RIGHT:		dc.l	empty

numtodo			dc.w	0

npt:			dc.w	0

pretab:
val				SET		0
				REPT	128
				dc.b	val
val				SET		val+1
				ENDR
val				SET		-128
				REPT	128
				dc.b	val
val				SET		val+1
				ENDR

tab:			ds.b	256*65


test:			dc.l	0
				ds.l	30

				EVEN
ConstCols:
; INCBIN "constcols"
				EVEN
Smoothscalecols:
; INCBIN "smoothbumppalscaled"
				EVEN
SmoothTile:
; INCBIN "smoothbumptile"
				EVEN
Bumpscalecols:
; INCBIN "bumppalscaled"
				EVEN
Bumptile:
; INCBIN "bumptile"
				EVEN
scalecols:		;INCBIN	"bytepixpalscaled"
				EVEN
floorscalecols:
				INCBIN	floorpalscaled
				ds.w	256*4

				EVEN
PaletteAddr:	dc.l	0
ChunkAddr:		dc.l	0

FloorTilePtr:	dc.l	0

wallrouts:

				CNOP	0,64
BackPicture:	INCBIN	backfile
EndBackPicture:

basedrawpt:		dc.l	0
drawpt:			dc.l	0
olddrawpt:		dc.l	0
frompt:			dc.l	0

SineTable:		INCBIN	bigsine

angspd:			dc.w	0
flooryoff:		dc.w	0
xoff:			dc.l	0
yoff:			dc.l	0
yvel:			dc.l	0
zoff:			dc.l	0
tyoff:			dc.l	0
xspdval:		dc.l	0
zspdval:		dc.l	0
Zone:			dc.w	0

PLR1:			dc.b	$ff
				EVEN
PLR1_energy:	dc.w	191
PLR1_GunSelected:
				dc.w	0
PLR1_cosval:	dc.w	0
PLR1_sinval:	dc.w	0
PLR1_angpos:	dc.w	0
PLR1_angspd:	dc.w	0
PLR1_xoff:		dc.l	0
PLR1_yoff:		dc.l	0
PLR1_yvel:		dc.l	0
PLR1_zoff:		dc.l	0
PLR1_tyoff:		dc.l	0
PLR1_xspdval:
				dc.l	0
PLR1_zspdval:
				dc.l	0
PLR1_Zone:		dc.w	0
PLR1_Roompt:	dc.l	0
PLR1_OldRoompt:
				dc.l	0
PLR1_PointsToRotatePtr:
				dc.l	0
PLR1_ListOfGraphRooms:
				dc.l	0
PLR1_oldxoff:
				dc.l	0
PLR1_oldzoff:
				dc.l	0
PLR1_StoodInTop:
				dc.b	0
				EVEN
PLR1_height:	dc.l	0

				ds.w	4

OLDX1:			dc.l	0
OLDX2:			dc.l	0
OLDZ1:			dc.l	0
OLDZ2:			dc.l	0

XDIFF1:			dc.l	0
ZDIFF1:			dc.l	0
XDIFF2:			dc.l	0
ZDIFF2:			dc.l	0

PLR1s_cosval:
				dc.w	0
PLR1s_sinval:
				dc.w	0
PLR1s_angpos:
				dc.w	0
PLR1s_angspd:
				dc.w	0
PLR1s_xoff:		dc.l	0
PLR1s_yoff:		dc.l	0
PLR1s_yvel:		dc.l	0
PLR1s_zoff:		dc.l	0
PLR1s_tyoff:	dc.l	0
PLR1s_xspdval:
				dc.l	0
PLR1s_zspdval:
				dc.l	0
PLR1s_Zone:		dc.w	0
PLR1s_Roompt:
				dc.l	0
PLR1s_OldRoompt:
				dc.l	0
PLR1s_PointsToRotatePtr:
				dc.l	0
PLR1s_ListOfGraphRooms:
				dc.l	0
PLR1s_oldxoff:
				dc.l	0
PLR1s_oldzoff:
				dc.l	0
PLR1s_height:
				dc.l	0
PLR1s_targheight:
				dc.l	0

p1_xoff:		dc.l	0
p1_zoff:		dc.l	0
p1_yoff:		dc.l	0
p1_height:		dc.l	0
p1_angpos:		dc.w	0
p1_bobble:		dc.w	0
p1_clicked:		dc.b	0
p1_spctap:		dc.b	0
p1_ducked:		dc.b	0
p1_gunselected:
				dc.b	0
p1_fire:		dc.b	0
				EVEN
p1_holddown:	dc.w	0

				ds.w	4

PLR2:			dc.b	$ff
				EVEN
PLR2_GunSelected:
				dc.w	0
PLR2_energy:	dc.w	191
PLR2_cosval:	dc.w	0
PLR2_sinval:	dc.w	0
PLR2_angpos:	dc.w	0
PLR2_angspd:	dc.w	0
PLR2_xoff:		dc.l	0
PLR2_yoff:		dc.l	0
PLR2_yvel:		dc.l	0
PLR2_zoff:		dc.l	0
PLR2_tyoff:		dc.l	0
PLR2_xspdval:
				dc.l	0
PLR2_zspdval:
				dc.l	0
PLR2_Zone:		dc.w	0
PLR2_Roompt:	dc.l	0
PLR2_OldRoompt:
				dc.l	0
PLR2_PointsToRotatePtr:
				dc.l	0
PLR2_ListOfGraphRooms:
				dc.l	0
PLR2_oldxoff:
				dc.l	0
PLR2_oldzoff:
				dc.l	0
PLR2_StoodInTop:
				dc.b	0
				EVEN
PLR2_height:	dc.l	0

				ds.w	4

PLR2s_cosval:
				dc.w	0
PLR2s_sinval:
				dc.w	0
PLR2s_angpos:
				dc.w	0
PLR2s_angspd:
				dc.w	0
PLR2s_xoff:		dc.l	0
PLR2s_yoff:		dc.l	0
PLR2s_yvel:		dc.l	0
PLR2s_zoff:		dc.l	0
PLR2s_tyoff:	dc.l	0
PLR2s_xspdval:
				dc.l	0
PLR2s_zspdval:
				dc.l	0
PLR2s_Zone:		dc.w	0
PLR2s_Roompt:
				dc.l	0
PLR2s_OldRoompt:
				dc.l	0
PLR2s_PointsToRotatePtr:
				dc.l	0
PLR2s_ListOfGraphRooms:
				dc.l	0
PLR2s_oldxoff:
				dc.l	0
PLR2s_oldzoff:
				dc.l	0
PLR2s_height:
				dc.l	0
PLR2s_targheight:
				dc.l	0

				ds.w	4

p2_xoff:		dc.l	0
p2_zoff:		dc.l	0
p2_yoff:		dc.l	0
p2_height:		dc.l	0
p2_angpos:		dc.w	0
p2_bobble:		dc.w	0
p2_clicked:		dc.b	0
p2_spctap:		dc.b	0
p2_ducked:		dc.b	0
p2_gunselected:
				dc.b	0
p2_fire:		dc.b	0
				EVEN
p2_holddown:	dc.w	0


liftanimtab:
endliftanimtab:

glassball:
; INCBIN "glassball.inc"
endglass
glassballpt:	dc.l	glassball

;rndtab:      ; INCBIN "randfile"
;endrnd:

brightanimtab:
				dcb.w	200,20
				dc.w	5
				dc.w	10,20
				dc.w	5
				dcb.w	30,20
				dc.w	7,10,10,5,10,0,5,6,5,6,5,6,5,6,0
				dcb.w	40,0
				dc.w	1,2,3,2,3,2,3,2,3,2,3,2,3,0
				dcb.w	300,0
				dc.w	1,0,1,0,2,2,2,5,5,5,5,5,5,5,5,5,6,10
				dc.w	-1

Roompt:			dc.l	0
OldRoompt:		dc.l	0

*****************************************************************
	*
				INCLUDE	leveldata2.s
	*
*****************************************************************


wallpt:			dc.l	0
floorpt:		dc.l	0

Rotated:		ds.l	2*800
ObjRotated:		ds.l	2*500

OnScreen:		ds.l	2*800

startwait:		dc.w	0
endwait:		dc.w	0

Faces:;			INCBIN	"faces2raw"

*******************************************************************

consttab:		INCBIN	constantfile

*******************************************************************



*********************************

; INCLUDE "source/loadmod.a"
; INCLUDE "source/proplayer.a"


darkentab:		INCBIN	darkenedcols
brightentab:	INCBIN	brightenfile
WorkSpace:		ds.l	8192
waterfile:		INCBIN	waterfile

				SECTION	ffff,CODE_C

nullspr:		dc.l	0

				CNOP	0,8
borders:		INCBIN	newleftbord
				INCBIN	newrightbord

health:			INCBIN	healthstrip
Ammunition:		INCBIN	ammostrip
healthpal:		INCBIN	healthpal
PanelKeys:		INCBIN	greenkey
				INCBIN	redkey
				INCBIN	yellowkey
				INCBIN	bluekey

null:			ds.w	500
null2:			ds.w	500
null3:			ds.w	500
null4:			ds.w	500


Blurbfield:		dc.w	bpl1ptl
bl1l:			dc.w	0
				dc.w	bpl1pth
bl1h:			dc.w	0

				dc.w	diwstrt,$2c81
				dc.w	diwstop,$1cc1
				dc.w	ddfstrt,$38
				dc.w	ddfstop,$b8
				dc.w	bplcon0,$9201
				dc.w	bplcon1,0
				dc.w	$106,$c40
blcols:			dc.w	color00,0
				dc.w	color01,$fff

				dc.w	$108,0
				dc.w	$10a,0

				dc.w	$ffff,$fffe
				dc.w	$ffff,$fffe

nullline:		ds.b	80

				INCLUDE	titlecop.s

bigfield:		;		Start					of our copper list.

				dc.w	dmacon,$8020
				dc.w	intreq,$8011
				dc.w	$1fc,$f
				dc.w	diwstrt
winstart:		dc.w	$2cb1
				dc.w	diwstop
winstop:		dc.w	$2c91
				dc.w	ddfstrt
fetchstart:		dc.w	$48
				dc.w	ddfstop
fetchstop:		dc.w	$88

bordercols:		INCBIN	borderpal

				dc.w	spr0ptl
s0l:			dc.w	0
				dc.w	spr0pth
s0h:			dc.w	0
				dc.w	spr1ptl
s1l:			dc.w	0
				dc.w	spr1pth
s1h:			dc.w	0
				dc.w	spr2ptl
s2l:			dc.w	0
				dc.w	spr2pth
s2h:			dc.w	0
				dc.w	spr3ptl
s3l:			dc.w	0
				dc.w	spr3pth
s3h:			dc.w	0
				dc.w	spr4ptl
s4l:			dc.w	0
				dc.w	spr4pth
s4h:			dc.w	0
				dc.w	spr5ptl
s5l:			dc.w	0
				dc.w	spr5pth
s5h:			dc.w	0
				dc.w	spr6ptl
s6l:			dc.w	0
				dc.w	spr6pth
s6h:			dc.w	0
				dc.w	spr7ptl
s7l:			dc.w	0
				dc.w	spr7pth
s7h:			dc.w	0


				dc.w	$106,$c42
				INCBIN	borderpal

				dc.w	$106,$8c42
				dc.w	color00
hitcol:			dc.w	$0
				dc.w	$106,$c42
				dc.w	color00
hitcol2:		dc.w	0

				dc.w	bplcon0,$7201
				dc.w	bplcon1
smoff:			dc.w	$0

				dc.w	$108
modulo:			dc.w	-24
				dc.w	$10a,-24

				dc.w	bpl1pth
pl1h			dc.w	0

				dc.w	bpl1ptl
pl1l			dc.w	0

				dc.w	bpl2pth
pl2h			dc.w	0

				dc.w	bpl2ptl
pl2l			dc.w	0

				dc.w	bpl3pth
pl3h			dc.w	0

				dc.w	bpl3ptl
pl3l			dc.w	0

				dc.w	bpl4pth
pl4h			dc.w	0

				dc.w	bpl4ptl
pl4l			dc.w	0

				dc.w	bpl5pth
pl5h			dc.w	0

				dc.w	bpl5ptl
pl5l			dc.w	0

				dc.w	bpl6pth
pl6h			dc.w	0

				dc.w	bpl6ptl
pl6l			dc.w	0

				dc.w	bpl7pth
pl7h			dc.w	0

				dc.w	bpl7ptl
pl7l			dc.w	0


				dc.w	$1001,$ff00
				dc.w	intreq,$11
yposcop:		dc.w	$2a11,$fffe
				dc.w	$8a,0

; ds.l 104*12

;colbars:
;val SET $2a
; dcb.l 104*80,$1fe0000
; dc.w $106,$c42
;
; dc.w $80
;pch1:
; dc.w 0
; dc.w $82
;pcl1:
; dc.w 0
;
; dc.w $88,0
;
; dc.w $ffff,$fffe       ; End copper list.

; ds.l 104*12

;colbars2:
;val SET $2a
; dcb.l 104*80,$1fe0000
;
; dc.w $106,$c42
;
; dc.w $80
;pch2:
; dc.w 0
; dc.w $82
;pcl2:
; dc.w 0
;
; dc.w $88,0
;
; dc.w $ffff,$fffe       ; End copper list.

; ds.l 104*10

NullCopper:		dc.w	$ffff,$fffe

old:			dc.l	0

PanelCop:		dc.w	$80
och:			dc.w	0
				dc.w	$82
ocl:			dc.w	0

statskip:		dc.w	$1fe,0
				dc.w	$1fe,0

				dc.w	$10c,0
				dc.w	bplcon0,$1201
				dc.w	bpl1ptl
n1l:			dc.w	0
				dc.w	bpl1pth
n1h:			dc.w	0
				dc.w	$108,-24
				INCBIN	panelpal

				dc.w	bpl2pth
p2h				dc.w	0

				dc.w	bpl2ptl
p2l				dc.w	0

				dc.w	bpl3pth
p3h				dc.w	0

				dc.w	bpl3ptl
p3l				dc.w	0

				dc.w	bpl4pth
p4h				dc.w	0
				dc.w	bpl4ptl
p4l				dc.w	0
				dc.w	bpl5pth
p5h				dc.w	0
				dc.w	bpl5ptl
p5l				dc.w	0
				dc.w	bpl6pth
p6h				dc.w	0
				dc.w	bpl6ptl
p6l				dc.w	0
				dc.w	bpl7pth
p7h				dc.w	0
				dc.w	bpl7ptl
p7l				dc.w	0
				dc.w	bpl8pth
p8h				dc.w	0
				dc.w	bpl8ptl
p8l				dc.w	0


				dc.w	ddfstrt,$38
				dc.w	ddfstop,$b8
				dc.w	diwstrt,$2c81
				dc.w	diwstop,$2cc1

				dc.w	bplcon0
Panelcon:		dc.w	$0211
				dc.w	bpl1pth
p1h				dc.w	0

				dc.w	bpl1ptl
p1l				dc.w	0


				dc.w	$108,40*7
				dc.w	$10a,40*7

				dc.w	$ffff,$fffe

				dc.w	$180,$fff


				dc.w	$f801,$ff00
				dc.w	color01,$50
				dc.w	$f901,$ff00
				dc.w	color01,$90
				dc.w	$fa01,$ff00
				dc.w	color01,$f0
				dc.w	$fb01,$ff00
				dc.w	color01,$f0
				dc.w	$fc01,$ff00
				dc.w	color01,$90
				dc.w	$fd01,$ff00
				dc.w	color01,$50

				dc.w	$fe01,$ff00
				dc.w	color01,$fff

				dc.w	$ffdf,$fffe
				dc.w	$a01,$ff00
				dc.w	bplcon0,$201

				INCBIN	faces2cols
				dc.w	bpl1pth
f1h				dc.w	0

				dc.w	bpl1ptl
f1l				dc.w	0

				dc.w	bpl2pth
f2h				dc.w	0

				dc.w	bpl2ptl
f2l				dc.w	0

				dc.w	bpl3pth
f3h				dc.w	0

				dc.w	bpl3ptl
f3l				dc.w	0

				dc.w	bpl4pth
f4h				dc.w	0
				dc.w	bpl4ptl
f4l				dc.w	0

				dc.w	bpl5pth
f5h				dc.w	0
				dc.w	bpl5ptl
f5l				dc.w	0

				dc.w	$0c01,$ff00
				dc.w	bplcon0,$5201

				dc.w	$ffff,$fffe

				CNOP	0,64
FacePlace:
; ds.l 6*32*5

TEXTSCRN:		dc.l	0

TEXTCOP:		dc.w	intreq,$8030

				dc.w	spr0ptl
txs0l:			dc.w	0
				dc.w	spr0pth
txs0h:			dc.w	0
				dc.w	spr1ptl
txs1l:			dc.w	0
				dc.w	spr1pth
txs1h:			dc.w	0
				dc.w	spr2ptl
txs2l:			dc.w	0
				dc.w	spr2pth
txs2h:			dc.w	0
				dc.w	spr3ptl
txs3l:			dc.w	0
				dc.w	spr3pth
txs3h:			dc.w	0
				dc.w	spr4ptl
txs4l:			dc.w	0
				dc.w	spr4pth
txs4h:			dc.w	0
				dc.w	spr5ptl
txs5l:			dc.w	0
				dc.w	spr5pth
txs5h:			dc.w	0
				dc.w	spr6ptl
txs6l:			dc.w	0
				dc.w	spr6pth
txs6h:			dc.w	0
				dc.w	spr7ptl
txs7l:			dc.w	0
				dc.w	spr7pth
txs7h:			dc.w	0


				dc.w	$10c,$0088

				dc.w	$1fc,$f
				dc.w	diwstrt,$2c81			; Top left corner of screen.
				dc.w	diwstop,$2cc1			; Bottom right corner of screen.
				dc.w	ddfstrt,$38				; Data fetch start.
				dc.w	ddfstop,$c8				; Data fetch stop.

				dc.w	bplcon0
TSCP:			dc.w	$9201

				dc.w	$106,$c40

				dc.w	$2a01,$ff00

				dc.w	color00,0
				dc.w	color01
TOPLET:
TXTCOLL:		dc.w	0
				dc.w	color02
BOTLET:			dc.w	0
				dc.w	color03
ALLTEXT:		dc.w	$fff
				dc.w	$106,$e40
				dc.w	color03
ALLTEXTLOW:		dc.w	$0


				dc.w	bpl1pth
TSPTh:			dc.w	0
				dc.w	bpl1ptl
TSPTl:			dc.w	0

				dc.w	bpl2pth
TSPTh2:			dc.w	0
				dc.w	bpl2ptl
TSPTl2:			dc.w	0


				dc.w	$108,0
				dc.w	$10a,0

				dc.w	$ffff,$fffe

********************************************
* Stuff you don't have to worry about yet. *
********************************************

closeeverything:

				jsr		mt_end

;	move.l       #nullcop,d0
; move.l old,d0

;	move.l       d0,$dff080	   ; Restore old copper list.
;	move.w       d0,ocl
;	swap         d0
;	move.w       d0,och

; move.l _DOSBase,a6
; move.l #4,d1
; jsr -198(a6)

; move.l _DOSBase,d0
; move.l d0,a1
; move.l 4.w,a6
; jsr CloseLib(a6)

;	move.l       #$dff000,a6
;	move.w       #$8020,dmacon(a6)
;	move.w       #$f,dmacon(a6)

; move.l 4.w,a6
; lea VBLANKInt,a1
; moveq #INTB_COPER,d0
; jsr _LVORemIntServer(a6)

; IFEQ CD32VER
; move.l OLDKINT,$68.w
; ENDC
; move.w saveinters,d0
; or.w #$c000,d0
; move.w d0,intena(a6)
				clr.w	$dff0a8
				clr.w	$dff0b8
				clr.w	$dff0c8
				clr.w	$dff0d8


; move.l oldview,a1
; move.l a1,d0
; move.l gfxbase,a6
; jsr -$de(a6)

; cmp.b #'s',mors
; beq.s leaveold
; move.w #$f8e,$dff1dc
;leaveold:

				jsr		RemVBTask
				jsr		UnLoadLevel
				jsr		ReleasePanel
				rts

				CNOP	0,64

Panel:			dc.l	0

TimerScr:
;ds.b 40*64

scrntab:		ds.b	16
val				SET		32
				REPT	96
				dc.b	val,val,val
val				SET		val+1
				ENDR
				ds.b	16

smallscrntab:
val				SET		32
				REPT	96
				dc.b	val,val
val				SET		val+1
				ENDR

				CNOP	0,64
scrn:			dcb.l	8,$33333333
				dc.l	0
				dc.l	0

				dcb.l	8,$0f0f0f0f
				dc.l	0
				dc.l	0

				dcb.l	8,$00ff00ff
				dc.l	0
				dc.l	0

				dcb.l	8,$0000ffff
				dc.l	0
				dc.l	0

				dc.l	0,-1,0,-1,0,-1,0,-1
				dc.l	0
				dc.l	0

				dc.l	-1,-1,0,0,-1,-1,0,0
				dc.l	0
				dc.l	0

				dc.l	0,0,-1,-1,-1,-1,-1,-1
				dc.l	0
				dc.l	0

NumTimes:		dc.l	0
TimeCount:		dc.l	0
oldtime:		dc.l	0
counting:		dc.b	0
oktodisplay:	dc.b	0

INITTIMER:		move.l	#0,TimeCount
				move.l	#0,NumTimes
				rts

STARTCOUNT:		move.l	d0,-(a7)
				move.l	$dff004,d0
				and.l	#$1ffff,d0
				move.l	d0,oldtime
				st		counting
				move.l	(a7)+,d0
				rts

STOPCOUNT:		move.l	d0,-(a7)
				move.l	$dff004,d0
				and.l	#$1ffff,d0

				sub.l	oldtime,d0
				cmp.l	#-256,d0
				bge.s	okcount
				add.l	#313*256,d0
okcount:		add.l	d0,TimeCount
				addq.l	#1,NumTimes
				clr.b	counting
				move.l	(a7)+,d0
				rts

STOPCOUNTNOADD:
				move.l	d0,-(a7)
				move.l	$dff004,d0
				and.l	#$1ffff,d0

				sub.l	oldtime,d0
				cmp.l	#-256,d0
				bge.s	okcount2
				add.l	#313*256,d0
okcount2:		add.l	d0,TimeCount
				clr.b	counting
				move.l	(a7)+,d0
				rts

maxbot:			dc.w	0
tstneg:			dc.l	0

STOPTIMER:		st		oktodisplay
				rts

digits:			INCBIN	numbers.inc


				Section	Sounds,CODE_C

nullcop:		dc.w	$106,$c40
				dc.w	$180,0
				dc.w	$100,$0
				dc.w	$ffff,$fffe

Scream:
; INCBIN "sounds/scream"
; ds.w 100
EndScream:
LowScream:
; INCBIN "sounds/lowscream"
; ds.w 100
EndLowScream:
BaddieGun:
; INCBIN "sounds/baddiegun"
EndBaddieGun:
bass:
; INCBIN "sounds/backbass+drum"
bassend:
Shoot:
; INCBIN "sounds/fire!"
EndShoot:
Munch:
; INCBIN "sounds/munch"
EndMunch:
PooGun:
; INCBIN "sounds/shoot.dm"
EndPooGun:
Collect:
; INCBIN "sounds/collect"
EndCollect:
DoorNoise:
; INCBIN "sounds/newdoor"
EndDoorNoise:
Stomp:
; INCBIN "sounds/footstep3"
EndStomp:
SwitchNoise:
; INCBIN "sounds/switch"
EndSwitch:
Reload:
; INCBIN "sounds/switch1.sfx"
EndReload:
NoAmmo:
; INCBIN "sounds/noammo"
EndNoAmmo:
Splotch:
; INCBIN "sounds/splotch"
EndSplotch:
SplatPop:
; INCBIN "sounds/splatpop"
EndSplatPop:
Boom:
; INCBIN "sounds/boom"
EndBoom:
Hiss:
; INCBIN "sounds/newhiss"
EndHiss:
Howl1:
; INCBIN "sounds/howl1"
EndHowl1:
Howl2:
; INCBIN "sounds/howl2"
EndHowl2:
Pant:
; INCBIN "sounds/pant"
EndPant:
Whoosh:
; INCBIN "sounds/whoosh"
EndWhoosh:
ROAR:
; INCBIN "sounds/bigscream"
EndROAR
whoosh:
; INCBIN "sounds/flame"
Endwhoosh:		SECTION	music,code_c

UseAllChannels:
				dc.w	0

mt_init:		move.l	mt_data,a0
				move.l	a0,a1
				add.l	#$3b8,a1
				moveq	#$7f,d0
				moveq	#0,d1
mt_loop:		move.l	d1,d2
				subq.w	#1,d0
mt_lop2:		move.b	(a1)+,d1
				cmp.b	d2,d1
				bgt.s	mt_loop
				dbf		d0,mt_lop2
				addq.b	#1,d2

				lea		mt_samplestarts(pc),a1
				asl.l	#8,d2
				asl.l	#2,d2
				add.l	#$43c,d2
				add.l	a0,d2
				move.l	d2,a2
				moveq	#$1e,d0
mt_lop3:		clr.l	(a2)
				move.l	a2,(a1)+
				moveq	#0,d1
				move.w	42(a0),d1
				asl.l	#1,d1
				add.l	d1,a2
				add.l	#$1e,a0
				dbf		d0,mt_lop3

				or.b	#$2,$bfe001
				move.b	#$6,mt_speed
				clr.w	$dff0a8
				clr.w	$dff0b8
				clr.w	$dff0c8
				clr.w	$dff0d8
				clr.b	mt_songpos
				clr.b	mt_counter
				clr.w	mt_pattpos
				rts

mt_end:			clr.w	$dff0a8
				clr.w	$dff0b8
				clr.w	$dff0c8
				clr.w	$dff0d8
				move.w	#$f,$dff096
				rts

mt_music:		movem.l	d0-d4/a0-a3/a5-a6,-(a7)
				move.l	mt_data,a0
				addq.b	#$1,mt_counter
				move.b	mt_counter,D0
				cmp.b	mt_speed,D0
				blt.s	mt_nonew
				clr.b	mt_counter
				bra		mt_getnew

mt_nonew:		lea		mt_voice1(pc),a6
				lea		$dff0a0,a5
				bsr		mt_checkcom
				lea		mt_voice2(pc),a6
				lea		$dff0b0,a5
				bsr		mt_checkcom
				tst.b	UseAllChannels
				beq		mt_endr
				lea		mt_voice3(pc),a6
				lea		$dff0c0,a5
				bsr		mt_checkcom
				lea		mt_voice4(pc),a6
				lea		$dff0d0,a5
				bsr		mt_checkcom
				bra		mt_endr

mt_arpeggio:	moveq	#0,d0
				move.b	mt_counter,d0
				divs	#$3,d0
				swap	d0
				cmp.w	#$0,d0
				beq.s	mt_arp2
				cmp.w	#$2,d0
				beq.s	mt_arp1

				moveq	#0,d0
				move.b	$3(a6),d0
				lsr.b	#4,d0
				bra.s	mt_arp3
mt_arp1:		moveq	#0,d0
				move.b	$3(a6),d0
				and.b	#$f,d0
				bra.s	mt_arp3
mt_arp2:		move.w	$10(a6),d2
				bra.s	mt_arp4
mt_arp3:		asl.w	#1,d0
				moveq	#0,d1
				move.w	$10(a6),d1
				lea		mt_periods(pc),a0
				moveq	#$24,d7
mt_arploop:		move.w	(a0,d0.w),d2
				cmp.w	(a0),d1
				bge.s	mt_arp4
				addq.l	#2,a0
				dbf		d7,mt_arploop
				rts
mt_arp4:		move.w	d2,$6(a5)
				rts

mt_getnew:		move.l	mt_data,a0
				move.l	a0,a3
				move.l	a0,a2
				add.l	#$c,a3
				add.l	#$3b8,a2
				add.l	#$43c,a0

				moveq	#0,d0
				move.l	d0,d1
				move.b	mt_songpos,d0
				move.b	(a2,d0.w),d1
				asl.l	#8,d1
				asl.l	#2,d1
				add.w	mt_pattpos,d1
				clr.w	mt_dmacon

				lea		$dff0a0,a5
				lea		mt_voice1(pc),a6
				bsr		mt_playvoice
				lea		$dff0b0,a5
				lea		mt_voice2(pc),a6
				bsr		mt_playvoice
				tst.b	UseAllChannels
				beq		mt_setdma
				lea		$dff0c0,a5
				lea		mt_voice3(pc),a6
				bsr		mt_playvoice
				lea		$dff0d0,a5
				lea		mt_voice4(pc),a6
				bsr		mt_playvoice
				bra		mt_setdma

PROTCALC:
ENDPROTCALC:
mt_playvoice:
				move.l	(a0,d1.l),(a6)
				addq.l	#4,d1
				moveq	#0,d2
				move.b	$2(a6),d2
				and.b	#$f0,d2
				lsr.b	#4,d2
				move.b	(a6),d0
				and.b	#$f0,d0
				or.b	d0,d2
				tst.b	d2
				beq.s	mt_setregs
				moveq	#0,d3
				lea		mt_samplestarts(pc),a1
				move.l	d2,d4
				subq.l	#$1,d2
				asl.l	#2,d2
				mulu	#$1e,d4
				move.l	(a1,d2.l),$4(a6)
				move.w	(a3,d4.l),$8(a6)
				move.w	$2(a3,d4.l),$12(a6)
				move.w	$4(a3,d4.l),d3
				tst.w	d3
				beq.s	mt_noloop
				move.l	$4(a6),d2
				asl.w	#1,d3
				add.l	d3,d2
				move.l	d2,$a(a6)
				move.w	$4(a3,d4.l),d0
				add.w	$6(a3,d4.l),d0
				move.w	d0,8(a6)
				move.w	$6(a3,d4.l),$e(a6)
				move.w	$12(a6),d0
				asr.w	#2,d0
				move.w	d0,$8(a5)
				bra.s	mt_setregs
mt_noloop:		move.l	$4(a6),d2
				add.l	d3,d2
				move.l	d2,$a(a6)
				move.w	$6(a3,d4.l),$e(a6)
				move.w	$12(a6),d0
				asr.w	#2,d0
				move.w	d0,$8(a5)
mt_setregs:		move.w	(a6),d0
				and.w	#$fff,d0
				beq		mt_checkcom2
				move.b	$2(a6),d0
				and.b	#$F,d0
				cmp.b	#$3,d0
				bne.s	mt_setperiod
				bsr		mt_setmyport
				bra		mt_checkcom2
mt_setperiod:
				move.w	(a6),$10(a6)
				and.w	#$fff,$10(a6)
				move.w	$14(a6),d0
				move.w	d0,$dff096
				clr.b	$1b(a6)

				move.l	$4(a6),(a5)
				move.w	$8(a6),$4(a5)
				move.w	$10(a6),d0
				and.w	#$fff,d0
				move.w	d0,$6(a5)
				move.w	$14(a6),d0
				or.w	d0,mt_dmacon
				bra		mt_checkcom2

mt_setdma:		move.w	#250,d0
mt_wait:		add.w	#1,testchip
				dbra	d0,mt_wait
				move.w	mt_dmacon,d0
				or.w	#$8000,d0
				and.w	#%1111111111110011,d0
				move.w	d0,$dff096
				move.w	#250,d0
mt_wait2:		add.w	#1,testchip
				dbra	d0,mt_wait2
				lea		$dff000,a5
				tst.b	UseAllChannels
				beq.s	noall
				lea		mt_voice4(pc),a6
				move.l	$a(a6),$d0(a5)
				move.w	$e(a6),$d4(a5)
				lea		mt_voice3(pc),a6
				move.l	$a(a6),$c0(a5)
				move.w	$e(a6),$c4(a5)
noall:			lea		mt_voice2(pc),a6
				move.l	$a(a6),$b0(a5)
				move.w	$e(a6),$b4(a5)
				lea		mt_voice1(pc),a6
				move.l	$a(a6),$a0(a5)
				move.w	$e(a6),$a4(a5)

				add.w	#$10,mt_pattpos
				cmp.w	#$400,mt_pattpos
				bne.s	mt_endr
mt_nex:			clr.w	mt_pattpos
				clr.b	mt_break
				addq.b	#1,mt_songpos
				and.b	#$7f,mt_songpos
				move.b	mt_songpos,d1
;       cmp.b   mt_data+$3b6,d1
;       bne.s   mt_endr
;       move.b  mt_data+$3b7,mt_songpos
mt_endr:		tst.b	mt_break
				bne.s	mt_nex
				movem.l	(a7)+,d0-d4/a0-a3/a5-a6
				rts

mt_setmyport:
				move.w	(a6),d2
				and.w	#$fff,d2
				move.w	d2,$18(a6)
				move.w	$10(a6),d0
				clr.b	$16(a6)
				cmp.w	d0,d2
				beq.s	mt_clrport
				bge.s	mt_rt
				move.b	#$1,$16(a6)
				rts
mt_clrport:		clr.w	$18(a6)
mt_rt:			rts

CODESTORE:		dc.l	0

mt_myport:		move.b	$3(a6),d0
				beq.s	mt_myslide
				move.b	d0,$17(a6)
				clr.b	$3(a6)
mt_myslide:		tst.w	$18(a6)
				beq.s	mt_rt
				moveq	#0,d0
				move.b	$17(a6),d0
				tst.b	$16(a6)
				bne.s	mt_mysub
				add.w	d0,$10(a6)
				move.w	$18(a6),d0
				cmp.w	$10(a6),d0
				bgt.s	mt_myok
				move.w	$18(a6),$10(a6)
				clr.w	$18(a6)
mt_myok:		move.w	$10(a6),$6(a5)
				rts
mt_mysub:		sub.w	d0,$10(a6)
				move.w	$18(a6),d0
				cmp.w	$10(a6),d0
				blt.s	mt_myok
				move.w	$18(a6),$10(a6)
				clr.w	$18(a6)
				move.w	$10(a6),$6(a5)
				rts

mt_vib:			move.b	$3(a6),d0
				beq.s	mt_vi
				move.b	d0,$1a(a6)

mt_vi:			move.b	$1b(a6),d0
				lea		mt_sin(pc),a4
				lsr.w	#$2,d0
				and.w	#$1f,d0
				moveq	#0,d2
				move.b	(a4,d0.w),d2
				move.b	$1a(a6),d0
				and.w	#$f,d0
				mulu	d0,d2
				lsr.w	#$6,d2
				move.w	$10(a6),d0
				tst.b	$1b(a6)
				bmi.s	mt_vibmin
				add.w	d2,d0
				bra.s	mt_vib2
mt_vibmin:		sub.w	d2,d0
mt_vib2:		move.w	d0,$6(a5)
				move.b	$1a(a6),d0
				lsr.w	#$2,d0
				and.w	#$3c,d0
				add.b	d0,$1b(a6)
				rts

mt_nop:			move.w	$10(a6),$6(a5)
				rts


mt_checkcom:	move.w	$2(a6),d0
				and.w	#$fff,d0
				beq.s	mt_nop
				move.b	$2(a6),d0
				and.b	#$f,d0
				tst.b	d0
				beq		mt_arpeggio
				cmp.b	#$1,d0
				beq.s	mt_portup
				cmp.b	#$2,d0
				beq		mt_portdown
				cmp.b	#$3,d0
				beq		mt_myport
				cmp.b	#$4,d0
				beq		mt_vib
				move.w	$10(a6),$6(a5)
				cmp.b	#$a,d0
				beq.s	mt_volslide
				rts

mt_volslide:	moveq	#0,d0
				move.b	$3(a6),d0
				lsr.b	#4,d0
				tst.b	d0
				beq.s	mt_voldown
				add.w	d0,$12(a6)
				cmp.w	#$40,$12(a6)
				bmi.s	mt_vol2
				move.w	#$40,$12(a6)
mt_vol2:		move.w	$12(a6),d0
				asr.w	#2,d0
				move.w	d0,$8(a5)
				rts

mt_voldown:		moveq	#0,d0
				move.b	$3(a6),d0
				and.b	#$f,d0
				sub.w	d0,$12(a6)
				bpl.s	mt_vol3
				clr.w	$12(a6)
mt_vol3:		move.w	$12(a6),d0
				asr.w	#2,d0
				move.w	d0,$8(a5)
				rts

mt_portup:		moveq	#0,d0
				move.b	$3(a6),d0
				sub.w	d0,$10(a6)
				move.w	$10(a6),d0
				and.w	#$fff,d0
				cmp.w	#$71,d0
				bpl.s	mt_por2
				and.w	#$f000,$10(a6)
				or.w	#$71,$10(a6)
mt_por2:		move.w	$10(a6),d0
				and.w	#$fff,d0
				move.w	d0,$6(a5)
				rts

mt_portdown:	clr.w	d0
				move.b	$3(a6),d0
				add.w	d0,$10(a6)
				move.w	$10(a6),d0
				and.w	#$fff,d0
				cmp.w	#$358,d0
				bmi.s	mt_por3
				and.w	#$f000,$10(a6)
				or.w	#$358,$10(a6)
mt_por3:		move.w	$10(a6),d0
				and.w	#$fff,d0
				move.w	d0,$6(a5)
				rts

mt_checkcom2:
				move.b	$2(a6),d0
				and.b	#$f,d0
				cmp.b	#$e,d0
				beq.s	mt_setfilt
				cmp.b	#$d,d0
				beq.s	mt_pattbreak
				cmp.b	#$b,d0
				beq.s	mt_posjmp
				cmp.b	#$c,d0
				beq.s	mt_setvol
				cmp.b	#$f,d0
				beq.s	mt_setspeed
				rts

mt_setfilt:		move.b	$3(a6),d0
				and.b	#$1,d0
				asl.b	#$1,d0
				and.b	#$fd,$bfe001
				or.b	d0,$bfe001
				rts
mt_pattbreak:
				not.b	mt_break
				rts
mt_posjmp:		st		reachedend
				move.b	$3(a6),d0
				subq.b	#$1,d0
				move.b	d0,mt_songpos
				not.b	mt_break
				rts
mt_setvol:		cmp.b	#$40,$3(a6)
				ble.s	mt_vol4
				move.b	#$40,$3(a6)
mt_vol4:		move.b	$3(a6),d0
				asr.w	#2,d0
				move.w	d0,$8(a5)
				rts
mt_setspeed:	cmp.b	#$1f,$3(a6)
				ble.s	mt_sets
				move.b	#$1f,$3(a6)
mt_sets:		move.b	$3(a6),d0
				beq.s	mt_rts2
				move.b	d0,mt_speed
				clr.b	mt_counter
mt_rts2:rts
mt_sin:			DC.b	$00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
				DC.b	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:		DC.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
				DC.w	$01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
				DC.w	$00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
				DC.w	$007f,$0078,$0071,$0000,$0000

reachedend:		dc.b	0
mt_speed:		DC.b	6
mt_songpos:		DC.b	0
mt_pattpos:		DC.w	0
mt_counter:		DC.b	0

mt_break:		DC.b	0
mt_dmacon:		DC.w	0
mt_samplestarts:
				DS.L	$1f
mt_voice1:		DS.w	10
				DC.w	1
				DS.w	3
mt_voice2:		DS.w	10
				DC.w	2
				DS.w	3
mt_voice3:		DS.w	10
				DC.w	4
				DS.w	3
mt_voice4:		DS.w	10
				DC.w	8
				DS.w	3

testchip:		dc.w	0

;/* End of File */
mt_data:		dc.l	0
tstchip:		dc.l	0
				INCLUDE	serial_nightmare.s

ingame:
; INCBIN "includes/ingame"
gameover:		INCBIN	gameover
welldone:		INCBIN	welldone
