
	OPT O+,W-
	OUTPUT ram:wintest
	INCLUDE MYINC:custom_small.i
	INCLUDE INCLUDE:rawkeys.i

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

test:	move.l	a7,InitStack

	bsr	Scr_Open
	bsr	Win_Open

	moveq	#3,d7
	lea	xx(pc),a5

.mainloop:	bsr	ProcIntuiMessage

	tst.l	d0
	bmi.s	.nomsg

	move.w	#$f0,$dff180

	move.l	Msg_Code(pc),d0
	cmp.w	#RAWKEY_ESC,d0
	beq.s	.done
	bra.s	.mainloop	

.nomsg:	move.w	#$f00,$dff180
	bra.s	.mainloop	
	
.done:	bsr	Win_Close
	bsr	Scr_Close

.cu_noscr:	rts

;----------

Scr_Open:	lea	ONewScreen(pc),a0	;Open our screen
	lea	ONewScreenTags(pc),a1
	INTCALL	OpenScreenTagList
	move.l	d0,Scr_Base
	beq.s	.so_out

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

Win_Open:	;Open window on screen
	SAVEREGS

	moveq	#16,d0		;Alloc blank mouse pointer
	move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	EXECCALL	AllocMem
	move.l	d0,Win_Ptr

	lea	.NewWindow(pc),a0	;Open the window
	lea	.NewWindowTags(pc),a1
	move.l	Scr_Base(pc),.newwinscr
	INTCALL	OpenWindowTagList
	move.l	d0,Win_Base
	beq.s	.wo_out

	move.l	d0,a0		;Save rastport address
	move.l	wd_RPort(a0),Win_RP

	move.l	wd_UserPort(a0),Win_UP	;Save message port address
	
	move.l	d0,a0		;Set custom pointer for window
	move.l	Win_Ptr(pc),a1
	moveq	#1,d0
	moveq	#16,d1
	moveq	#0,d2
	moveq	#0,d3
	CALLA6	SetPointer

.wo_out:	GETREGS
	rts


.NewWindow:	dc.w 0,1			;LeftEdge, TopEdge
	dc.w 320,255			;Width, Height
	dc.b 0,0			;DetailPen, BlockPen
	dc.l 0			;IDCMPflags
	dc.l 0			;Flags
	dc.l 0			;FirstGadget
	dc.l 0			;CheckMark
	dc.l 0			;Title
.newwinscr:	dc.l 0			;Screen to open on
	dc.l 0			;Bitmap
	dc.w 320,255			;Min size
	dc.w 320,255			;Max size
	dc.w CUSTOMSCREEN		;Screen type

.NewWindowTags:
	dc.l WA_RMBTrap,-1
	dc.l WA_NoCareRefresh,-1
	dc.l WA_Borderless,-1
	dc.l WA_Activate,-1
	dc.l WA_IDCMP,IDCMP_RAWKEY|IDCMP_INTUITICKS|IDCMP_ACTIVEWINDOW|IDCMP_INACTIVEWINDOW
	dc.l TAG_END,TAG_END		;End of taglist

;----------

Win_Close:	;Close window safely

	SAVEREGS

	move.l	Win_Base(pc),d0	;Exit if window not open
	beq.s	.wc_nowin

	move.l	d0,a0		;Clear custom pointer
	INTCALL	ClearPointer

	move.l	(a7)+,a0		;Really close the window
	CALLA6	CloseWindow

.wc_nowin:	move.l	Win_Ptr(pc),d0	;Dealloc memory for custom pointer
	beq.s	.wc_nopointer
	move.l	d0,a1
	moveq	#16,d0
	EXECCALL	FreeMem

.wc_nopointer:
	GETREGS
	rts


;----------

Win_Base:	dc.l	0
Win_Ptr:	dc.l	0
Win_RP:	dc.l	0
Win_UP:	dc.l	0

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
	dc.l SA_Depth,1
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

;-------------------------------------------------------------------------------

ProcIntuiMessage:
	;Wait for an IDCMP message and store its class/code
	;Exit:	Msg_Class/d0 hold message class or -1
	;	Msg_Code/d1  hold message code

	movem.l	d2-7/a0-6,-(a7)

.wi_loop:	move.l	Win_UP,a0		;Get d0=message from userport
	EXECCALL	GetMsg

	tst.l	d0		;Any message?
	beq.s	.wi_nomsg		;Skip if not

	move.l	d0,a1		;Save message information
	move.l	im_Class(a1),Msg_Class
	clr.l	Msg_Code
	move.w	im_Code(a1),Msg_Code+2

	EXECCALL	ReplyMsg		;Reply to message

.wi_out:	movem.l	(a7)+,d2-7/a0-6
	move.l	Msg_Class(pc),d0
	move.l	Msg_Code(pc),d1
	rts

.wi_nomsg:	moveq	#-1,d0
	move.l	d0,Msg_Class
	move.l	d0,Msg_Code
	bra.s	.wi_out

Msg_Class:	dc.l	0
Msg_Code:	dc.l	0

;-------------------------------------------------------------------------------
