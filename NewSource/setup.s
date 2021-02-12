;******************************************************************************
; Setup and cleanup stuff
;******************************************************************************

Setup:	move.l	4.w,_SysBase

	lea	custom,a6	  	;A6=CUSTOM BASE
	move.w	#13,serper(a6)	;19200 baud, 8 bits, no parity

	st           GOURSEL

	clr.b        PLR1KEYS
	clr.b        PLR1PATH
	clr.b        PLR1MOUSE
	st           PLR1JOY
	clr.b        PLR2KEYS
	clr.b        PLR2PATH
	clr.b        PLR2MOUSE
	st           PLR2JOY

	move.l       #10240*4,d0		;Alloc memory for tmapping
	move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
	EXECCALL	AllocMem
	move.l	d0,basedrawpt
	move.l	d0,drawpt
	add.l	#10240*2,d0
	move.l	d0,olddrawpt

	move.l       #320*256,d0
	move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
	CALLA6	AllocMem
	move.l	d0,ChunkyArray

	move.l       #$1000,d0		;Alloc memory for copper->screen pallete mapping
	move.l       #MEMF_PUBLIC|MEMF_CLEAR,d1
	CALLA6	AllocMem
	move.l       d0,Cop2PenTab

	move.l       #120000,d0		;Alloc memory for level data
	move.l       #MEMF_PUBLIC,d1
	CALLA6	AllocMem
	move.l       d0,LevelDataPtr

	move.l       #10240*8,d0		;Alloc memory for bg pictures
	move.l       #MEMF_PUBLIC|MEMF_CLEAR,d1
	CALLA6	AllocMem
	move.l       d0,BGPicMem

	bsr	Scr_Open		;Setup & open our screen

	moveq	#-1,d0		;Alloc signal for c2p
	EXECCALL	AllocSignal
	move.l	d0,c2p_signal

	;Open the fonts we need for the game

	move.l	Scr_Base,a0		;Menu & screen font
	lea	.i_menutextattr(pc),a1
	RTGCALL	RtgOpenFont
	move.l	d0,TitleFont

	move.l	Scr_Base,a0		;Tweentext font
	lea	.i_tweentextattr(pc),a1
	CALLA6	RtgOpenFont
	move.l	d0,TweenFont

;	lea	RKJON_tags(pc),a1	;Start creating rawkey codes for joystick
;	LOWCALL	SystemControlA

	move.w	_SysBase,RVAL1	;Init random generator. Fix this!
	move.w	_SysBase+2,RVAL2

	rts
;-----

.i_menutextattr:
	dc.l	.i_mnufontnam	;Name
	dc.w	8		;YSize
	dc.w	0		;Style
	dc.w	FPF_DESIGNED		;Flags

.i_tweentextattr:
	dc.l	.i_twnfontnam	;Name
	dc.w	8		;YSize
	dc.w	0		;Style
	dc.w	FPF_DESIGNED		;Flags

.i_mnufontnam:
	dc.b	"AB3DMenu.font",0
.i_twnfontnam:
	dc.b	"AB3DSlim.font",0
	EVEN

;------------------------------------------------------------------------------

AddVBTask:	SAVEREGS
	lea          VBLANKInt(pc),a1
	moveq        #INTB_VERTB,d0
	EXECCALL	AddIntServer
	GETREGS
	rts

;-----

RemVBTask:	SAVEREGS
	lea          VBLANKInt(pc),a1
	moveq        #INTB_VERTB,d0
	EXECCALL	RemIntServer
	GETREGS
	rts


;-----

	CNOP	0,4
VBName:	dc.b	"AB3D VBlank",0

	CNOP	0,4

VBLANKInt:	dc.l         0,0
	dc.b         NT_INTERRUPT,100
	dc.l         VBName
	dc.l         0
	dc.l         Chan0inter

;------------------------------------------------------------------------------

	CNOP	0,4
RKJON_tags:	dc.l	SCON_AddCreateKeys,1
	dc.l	TAG_END,TAG_END

RKJOFF_tags:	dc.l	SCON_RemCreateKeys,1
	dc.l	TAG_END,TAG_END

BGPicMem:	dc.l	0
BGPicBitMap:	dcb.b	bm_SIZEOF

TweenFont:	dc.l	0
TitleFont:	dc.l	0
ChunkyArray:	dc.l	0
Cop2PenTab:	dc.l	0

c2p_signal:	dc.l	-1

;------------------------------------------------------------------------------

Cleanup:
;	bsr	Rem_IHandler
;	bsr	Close_Keyboard

;	lea	RKJOFF_tags(pc),a1	;Stop creating rawkey codes for joystick
;	LOWCALL	SystemControlA

	lea	TweenFont(pc),a1	;Free game fonts
	bsr	parolefont
	lea	TitleFont(pc),a1
	bsr	parolefont

	move.l	c2p_signal(pc),d0	;Free c2p signal
	EXECCALL	FreeSignal

	bsr	Scr_Close

	lea	LevelDataPtr,a1
	move.l       #120000,d0
	bsr.s	parole

	lea	basedrawpt,a1
	move.l       #10240*4,d0
	bsr.s	parole

	lea	ChunkyArray(pc),a1
	move.l       #320*256,d0
	bsr.s	parole

	lea	Cop2PenTab(pc),a1
	move.l       #$1000,d0
	bsr.s	parole

	lea	BGPicMem(pc),a1
	move.l       #10240*8,d0
	bsr.s	parole

	rts

;------------------------------------------------------------------------------

parolefont:	SAVEREGS

	move.l	(a1),d0
	beq.s	.pf_nofont

	move.l	a1,-(a7)
	move.l	Scr_Base,a0
	move.l	d0,a1
	RTGCALL	RtgCloseFont
	move.l	(a7)+,a1
	clr.l	(a1)

.pf_nofont:	GETREGS
	rts

;-----

parole:	move.l	(a1),d1
	beq.s	.paroleout
	move.l	d1,a1
	EXECCALL	FreeMem
.paroleout:	rts

;------------------------------------------------------------------------------
