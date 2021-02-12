
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

	sub.l a1,a1
	move.l 4.w,a6
	jsr _LVOFindTask(a6)
	move.l d0,taskptr

	jsr test

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
	EVEN

_INTBase:	dc.l 0
_DOSBase:	dc.l 0
_GFXBase:	dc.l 0

taskptr:	dc.l 0
xx:	dc.l 0

;-----------------------------------------------------------------------------

test:	bsr	Scr_Open

	bsr	GetPensForCopCol

	bsr	Scr_Close
	rts

;----------

Scr_Open:	lea	ONewScreen(pc),a0	;Open our screen
	lea	ONewScreenTags(pc),a1
	INTCALL	OpenScreenTagList
	move.l	d0,Scr_Base
	beq.s	.so_out

	move.l	d0,a0		;Save ViewPort address
	lea	sc_ViewPort(a0),a0
	move.l	a0,Scr_VP
	move.l	vp_ColorMap(a0),VP_ColorMap

	move.l	d0,a0		;Save bitplane start addresses
	lea	sc_RastPort(a0),a0
	move.l	rp_BitMap(a0),a0
	lea	bm_Planes(a0),a0
	lea	Scr_Planes(pc),a1
	moveq	#7,d1
.so_setplanes:
	move.l	(a0)+,(a1)+
	dbf	d1,.so_setplanes

	move.l	Scr_VP,a0
	lea	Pal(pc),a1
	GRAFCALL	LoadRGB32

.so_out:	rts

;----------

Scr_Close:	;Close our screen if open
	move.l Scr_Base,d0
	beq.s .sc_done
	move.l d0,a0
	INTCALL CloseScreen
	clr.l Scr_Base

.sc_done:	rts


;-----------------------------------------------------------------------------

GetPensForCopCol:
	;Allocate and remember pen numbers to map from 12-bit copper
	;colours to screen palette

	SAVEREGS

	move.l	Cop2PenTab,a2
	move.l	_GFXBase,a6
	moveq	#15,d1		;Red
.mc_redloop:
	moveq	#15,d2		;Green
.mc_grnloop:
	moveq	#15,d3		;Blue

.mc_bluloop:	movem.l	d1-3/a2,-(a7)

	move.w	d1,d4		;Get table index (0000RRRRGGGGBBBB)
	lsl.w	#4,d4		;for pen in d4
	or.w	d2,d4
	lsl.w	#4,d4
	or.w	d3,d4
	move.w	d4,-(a7)

	move.l	d1,d0		;Create 32 bit RGB in d1-3
	bsr	.mc_4to32
	move.l	d0,d1
	move.l	d2,d0
	bsr	.mc_4to32
	move.l	d0,d2
	move.l	d3,d0
	bsr	.mc_4to32
	move.l	d0,d3

	move.l	VP_ColorMap,a0
	lea	.mc_tags(pc),a1
	CALLA6	ObtainBestPenA	;d0=best matching pen number

	move.w	(a7)+,d4		;d4=table index for pen
	tst.b	d0		;Did we get a pen?
	bmi.s	.mc_nopen		;Skip if not

	move.b	d0,0(a2,d4.w)	;Save pen number

	move.l	VP_ColorMap,a0	;Release pen again
	CALLA6	ReleasePen
	bra.s	.mc_nextcol	

.mc_nopen:	move.w	#$f00,$dff180
	clr.b	0(a2,d4.w)

.mc_nextcol:	movem.l	(a7)+,d1-3/a2	;Loop for next RGB triplet
	dbf	d3,.mc_bluloop
	dbf	d2,.mc_grnloop
	dbf	d1,.mc_redloop

	GETREGS
	rts
;---

	CNOP	0,4
.mc_tags:	dc.l	OBP_Precision,PRECISION_IMAGE
	dc.l	OBP_FailIfBad,0
	dc.l	TAG_END,TAG_END

;-----

.mc_4to32:	movem.l	d1-2,-(a7)
	moveq	#6,d1
.mc4_loop:	move.b	d0,d2
	and.b	#$f,d2
	lsl.l	#4,d0
	or.b	d2,d0
	dbf	d1,.mc4_loop
	movem.l	(a7)+,d1-2
	rts

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
	dc.l SA_SharePens,-1
	dc.l SA_BlockPen,0		;Pens to use	
	dc.l SA_DetailPen,1
	dc.l SA_Title,ONewScreenTitle	;Ptr to title string
	dc.l SA_Font,0		;Default font

	dc.l SA_Type,CUSTOMSCREEN
	dc.l SA_DisplayID,PAL_MONITOR_ID|LORES_KEY
	dc.l SA_Interleaved,0
	dc.l TAG_END,TAG_END		;End of taglist

;-------------------------------------------------------------------------------

Scr_Base:	dc.l	0
Scr_VP:	dc.l	0
Scr_Planes:	dcb.l	8
VP_ColorMap:	dc.l	0

Pal:	dc.w	256,0
	INCBIN	proj:ab3d/newstuff/Border.pal
	dc.w	0

coptab:	dcb.b	$1000

Cop2PenTab:	dc.l	coptab

;-------------------------------------------------------------------------------
