
	OPT O+,W-
	OUTPUT ram:sctest
	INCLUDE MYINC:custom_small.i

;-----------

SAVEREGS     MACRO
             movem.l      d0-d7/a0-a6,-(a7)
             ENDM

GETREGS      MACRO
             movem.l      (a7)+,d0-d7/a0-a6
             ENDM

CALLA6:	MACRO
	jsr _LVO\1(a6)
	ENDM

EXECCALL:	MACRO
	move.l 4.w,a6
	jsr _LVO\1(a6)
	ENDM

DOSCALL:	MACRO
	move.l _DOSBase,a6
	jsr _LVO\1(a6)
	ENDM


INTCALL:	MACRO
	move.l _INTBase,a6
	jsr _LVO\1(a6)
	ENDM

GRAFCALL:	MACRO
	move.l _GFXBase,a6
	jsr _LVO\1(a6)
	ENDM

DISKFCALL:	MACRO
	move.l _DISKFBase,a6
	jsr _LVO\1(a6)
	ENDM

;-----------

entry:	lea _INTName(pc),a1	;Open INT library and save ptr
	moveq #36,d0
	move.l 4.w,a6
	jsr _LVOOpenLibrary(a6)
	move.l d0,_INTBase
	beq .ilibrary_error

	lea _DOSName(pc),a1	;Open DOS library and save ptr
	moveq #37,d0
	move.l 4.w,a6
	jsr _LVOOpenLibrary(a6)
	move.l d0,_DOSBase
	beq .dlibrary_error

	lea _GFXName(pc),a1	;Open GFX library and save ptr
	moveq #37,d0
	move.l 4.w,a6
	jsr _LVOOpenLibrary(a6)
	move.l d0,_GFXBase
	beq .glibrary_error

	lea _DISKFName(pc),a1	;Open diskfont library and save ptr
	moveq #37,d0
	move.l 4.w,a6
	jsr _LVOOpenLibrary(a6)
	move.l d0,_DISKFBase
	beq .dflibrary_error

	sub.l a1,a1
	move.l 4.w,a6
	jsr _LVOFindTask(a6)
	move.l d0,taskptr

	jsr test

	move.l _DISKFBase,a1
	move.l 4.w,a6
	jsr _LVOCloseLibrary(a6)

.dflibrary_error:
	move.l _GFXBase,a1
	move.l 4.w,a6
	jsr _LVOCloseLibrary(a6)

.glibrary_error:
	move.l _DOSBase,a1
	move.l 4.w,a6
	jsr _LVOCloseLibrary(a6)

.dlibrary_error:
	move.l _INTBase,a1
	move.l 4.w,a6
	jsr _LVOCloseLibrary(a6)

.ilibrary_error:
	move.l xx,d0
	rts

_INTName:	dc.b "intuition.library",0
_DOSName:	dc.b "dos.library",0
_GFXName:	dc.b "graphics.library",0
_DISKFName:	dc.b "diskfont.library",0
	EVEN

_INTBase:	dc.l 0
_DOSBase:	dc.l 0
_GFXBase:	dc.l 0
_DISKFBase:	dc.l 0

taskptr:	dc.l 0
InitStack:	dc.l 0
xx:	dc.l 0

;-----------------------------------------------------------------------------

FatalError:
;Fatal error handler
;Prints message at a0 (if it exists & printing is possible)
;then cleans up and exits the game.

	cmp.l #0,a0			;Do we have a message?
	beq.s .fe_nomsg		;Skip if not

	move.l a0,d1			;Print message
	move.l _DOSBase,a6
	jsr _LVOPutStr(a6)

.fe_nomsg:	move.l InitStack,a7
	rts

;-----------------------------------------------------------------------------

test:	move.l a7,InitStack

	bsr	Scr_Open

	lea	txtattr(pc),a0	;Set font for menu screens
	DISKFCALL	OpenDiskFont
	move.l	d0,TitleFont
	beq.s	.nofont

	move.l	d0,a0
	move.l	Scr_RP,a1
	GRAFCALL	SetFont
.nofont:
	bsr	LoadTitleScrn

	move.w	#255,FadeVal
	clr.w	FadeAmount
	bsr          FadeUpTitle

	move.l	Scr_VP,a0		;Set palette for menu options (colours 254 and 255)
	lea	menupal(pc),a1
	GRAFCALL	LoadRGB32

	move.l	Scr_RP,a1		;Set pens & drawmode
	move.l	#255,d0
	moveq	#0,d1
	move.l	#RP_JAM1,d2
	GRAFCALL	SetABPenDrMd

	move.l	Scr_RP,a1
	moveq	#0,d0
	moveq	#8,d1
	GRAFCALL	Move

	move.l	Scr_RP,a1
	lea	text,a0
	moveq	#10,d0
	GRAFCALL	Text

	move.l	Scr_RP,a0		;Set writemask
	move.l	#$1,d0
	GRAFCALL	SetWriteMask

	move.l	Scr_RP,a1		;Set pens & drawmode
	move.l	#255,d0
	moveq	#0,d1
	move.l	#RP_COMPLEMENT,d2
	GRAFCALL	SetABPenDrMd

	move.l	Scr_RP,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#100,d2
	moveq	#8,d3
	GRAFCALL	RectFill

	move.l	#100,d1
	DOSCALL	Delay

	move.l	Scr_RP,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#100,d2
	moveq	#8,d3
	GRAFCALL	RectFill

	move.l	#100,d1
	DOSCALL	Delay

	move.l	TitleFont(pc),d0	;Close font if open
	beq.s	.nofont2

	move.l	d0,a1
	GRAFCALL	CloseFont
	clr.l	TitleFont
.nofont2:
	bsr	Scr_Close

.cu_noscr:	rts

text:	dc.b	"0123456789",0
	EVEN

menupal:	dc.w	2,254
	dc.l	$ffffffff,$ffffffff,$00000000
	dc.l	$ffffffff,$ffffffff,$ffffffff
	dc.w 0

txtattr:	dc.l	fontnam		;Name
	dc.w	8		;YSize
	dc.w	0		;Style
	dc.w	FPF_DESIGNED		;Flags

fontnam:	dc.b	"garrison.font",0
	EVEN

TitleFont:	dc.l	0

;----------

Scr_Open:	lea	ONewScreen(pc),a0	;Open our screen
	lea	ONewScreenTags(pc),a1
	INTCALL	OpenScreenTagList
	move.l	d0,Scr_Base
	beq.s	.so_out

	move.l	d0,a0		;Save ViewPort address
	lea	sc_ViewPort(a0),a0
	move.l	a0,Scr_VP

	move.l	d0,a0		;Save bitplane start addresses
	lea	sc_RastPort(a0),a0
	move.l	a0,Scr_RP
	move.l	rp_BitMap(a0),a0
	move.l	a0,Scr_BP
	lea	bm_Planes(a0),a0
	lea	Scr_Planes(pc),a1
	moveq	#7,d1
.so_setplanes:
	move.l	(a0)+,(a1)+
	dbf	d1,.so_setplanes

.so_out:	rts

;----------

Scr_Close:	;Close our screen if open
	move.l Scr_Base,d0
	beq.s .sc_done
	move.l d0,a0
	INTCALL CloseScreen
	clr.l Scr_Base

.sc_done:	rts


;----------

LoadTitleScrn:
	;Load title screen directly to bitplanes

	move.l       #TITLESCRNNAME,d1	;Open file
	move.l       #MODE_OLDFILE,d2
	DOSCALL	Open
	move.l       d0,handle
	beq.s	.noload

	lea	Scr_Planes,a0	;a0=addresses of planes
	moveq	#7,d7		;8 planes

.loadtsloop:	move.l       handle,d1		;d1=filehandle
	move.l       (a0)+,d2		;d2=dest address
	movem.l	d7/a0,-(a7)
	move.l       #10240,d3		;d3=length of one plane
	DOSCALL	Read

	movem.l	(a7)+,d7/a0
	dbf	d7,.loadtsloop

	move.l       handle,d1
	DOSCALL	Close

.noload:	clr.l	handle
	rts

;------------

FadeUpTitle:	;Fade title screen palette up (brighten) from current

	SAVEREGS

	moveq	#0,d0
	move.w       FadeVal,d0
	move.w       FadeAmount,d1

.fadeuploop:	movem.l	d0-1,-(a7)
	GRAFCALL	WaitTOF
	movem.l	(a7)+,d0-1
	bsr.s	PUTIN256
	addq.w       #4,d0
	dbf	d1,.fadeuploop

	subq         #4,d0
	move.w       d0,FadeVal

	GETREGS
	rts

;----------

FadeDownTitle:
	;Fade title screen palette down (darken) from current

	SAVEREGS

	moveq	#0,d0
	move.w       FadeVal,d0
	move.w       FadeAmount,d1

.fadedownloop:
	movem.l	d0-1,-(a7)
	GRAFCALL	WaitTOF
	movem.l	(a7)+,d0-1
	bsr.s	PUTIN256
	subq.w       #4,d0
	dbf	d1,.fadedownloop

	subq         #4,d0
	move.w       d0,FadeVal

	GETREGS
	rts

;----------

PUTIN256:	;Scale title screen palette according to d0
	;and load scaled palette into colour regs
	;Entry:	d0=scale value 0-256

	SAVEREGS

	move.w	#255,d2		;256 colours to process
	lea	TITLEPAL,a0		;a0=source colour vec
	lea	FadeTmpPal+4(pc),a1	;a1=LoadRGB32 table

.putloop:	movem.l	(a0)+,d3-5		;d3-5 = next RGB triplet

	swap	d3
	swap	d4
	swap	d5
	mulu	d0,d3
	mulu	d0,d4
	mulu	d0,d5
	lsr.l	#8,d3
	lsr.l	#8,d4
	lsr.l	#8,d5
	swap	d3
	swap	d4
	swap	d5
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+

	dbf	d2,.putloop

	move.l	Scr_VP,a0		;a0=screen viewport
	lea	FadeTmpPal(pc),a1	;a1=RGB table
	GRAFCALL	LoadRGB32

	GETREGS
	rts


;------------

screen_error:
	lea .se_msg(pc),a0
	bra FatalError

.se_msg:	dc.b "Could not open screen!",0
	EVEN

;-----------------------------------------------------------------------------

	CNOP 0,4
ONewScreen:	;Most things are done in the taglist...
	dc.w 0,0			;LeftEdge, TopEdge
	dc.w 0,0,0			;Width, Height, Depth
	dc.b 0,0			;DetailPen, BlockPen
	dc.w 0			;PAL LORES
	dc.w 0			;Type
	dc.l 0			;Default font
	dc.l 0			;Title string
	dc.l 0			;Unused
	dc.l 0			;CustomBitmap

ONewScreenTitle:
	;The title of our screen
	dc.b "AB3D",0
	EVEN

ONewScreenTags:
	;Tags used to open our screen
	dc.l SA_Left,0		;Screen dimensions
	dc.l SA_Top,0
	dc.l SA_Width,320
	dc.l SA_Height,256
	dc.l SA_Depth,8
	dc.l SA_BlockPen,0		;Pens to use	
	dc.l SA_DetailPen,1
	dc.l SA_Title,ONewScreenTitle	;Ptr to title string
	dc.l SA_Font,0		;Default font

	dc.l SA_Type,CUSTOMSCREEN
	dc.l SA_DisplayID,PAL_MONITOR_ID|LORES_KEY
	dc.l SA_Interleaved,0
	dc.l SA_Draggable,-1
	dc.l SA_Exclusive,-1
	dc.l TAG_END,TAG_END		;End of taglist

;-------------------------------------------------------------------------------

TITLEPAL:	INCBIN	proj:ab3d/newstuff/Title.pal

TITLESCRNNAME:
	dc.b	"proj:ab3d/newstuff/title.raw",0
	EVEN

Scr_Base:	dc.l	0
Scr_VP:	dc.l	0
Scr_RP:	dc.l	0
Scr_BP:	dc.l	0
Scr_Planes:	dcb.l	8
handle:	dc.l 0

FadeAmount:  dc.w         0
FadeVal:     dc.w         0


FadeTmpPal:	dc.w	256,0
	dcb.l	3*256
	dc.w	0

;-------------------------------------------------------------------------------
