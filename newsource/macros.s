*---------------------------------------------------------------------------*
CACHE_ON:		MACRO
				Movec.l	CACR,\1
				Or.l	#1,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
CACHE_OFF:		MACRO
				Movec.l	CACR,\1
				And.l	#-2,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
DATA_CACHE_CLEAR: MACRO
				Movec.l	CACR,\1
				or.l	#%100000000000,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
CACHE_CLEAR:	MACRO
				Movec.l	CACR,\1
				or.l	#8,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
CACHE_FREEZE_ON: MACRO
				Movec.l	CACR,\1
				or.l	#2,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
DATA_CACHE_ON:	MACRO
				Movec.l	CACR,\1
				or.l	#$10,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
DATA_CACHE_OFF:	MACRO
				Movec.l	CACR,\1
				and.l	#%11111111111111111111111011111111,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
CACHE_FREEZE_OFF: MACRO
				Movec.l	CACR,\1
				and.l	#%11111111111111111111111111111101,\1
				Movec.l	\1,CACR
				ENDM
*---------------------------------------------------------------------------*
DUGDOS:			MACRO
				Move.l	DosBase,a6
				Jsr		_LVO\1(a6)				DosCall
				ENDM
*---------------------------------------------------------------------------*
DUGREQ:			MACRO
				Move.l	ReqBase,a6
				Jsr		_LVO\1(a6)				ReqCall
				ENDM
*---------------------------------------------------------------------------*
BLIT_NASTY:		MACRO
				Move.w	#$8400,Dmacon(a6)		Blitter Nasty On
				ENDM
*---------------------------------------------------------------------------*
BLIT_NICE:		MACRO
				Move.w	#$0400,Dmacon(a6)		Blitter Nasty Off
				ENDM
*---------------------------------------------------------------------------*
WAIT_BLIT:		MACRO
.\@:			Btst	#6,DMACONR(a6)			Wait for Blitter End
				Bne.s	.\@
				ENDM
*---------------------------------------------------------------------------*
SCROLL_WB:		MACRO
.\@:			Btst	#6,DMACONR-BLTSIZE(a3)	Wait for Blitter End
				Bne.s	.\@
				ENDM
*---------------------------------------------------------------------------*
PALETTE32COL	MACRO
				dc.l	$1800000,$1820000,$1840000,$1860000,$1880000,$18a0000
				dc.l	$18c0000,$18e0000,$1900000,$1920000,$1940000,$1960000
				dc.l	$1980000,$19a0000,$19c0000,$19e0000,$1a00000,$1a20000
				dc.l	$1a40000,$1a60000,$1a80000,$1aa0000,$1ac0000,$1ae0000
				dc.l	$1b00000,$1b20000,$1b40000,$1b60000,$1b80000,$1ba0000
				dc.l	$1bc0000,$1be0000
				ENDM
*---------------------------------------------------------------------------*

* QMOVE		 move a constant into a reg the quickest way (probbly)
* qmove.w 123,d0 NB:if word or byte, will still use moveq!!! if it can

QMOVE			MACRO
				IFGE	\1
				IFLE	\1-127
				Moveq	#\1,\2
				MEXIT
				ENDC
				IFLE	\1-255
				Moveq	#256-\1,\2
				Neg.b	\2
				MEXIT
				ENDC
				move.\0	#\1,\2
				MEXIT
				ELSEIF
				move.\0	#\1,\2
				ENDC
				ENDM

;---------------------------------------------------------------------------

CALLA6:			MACRO
				jsr		_LVO\1(a6)
				ENDM

EXECCALL:		MACRO
				move.l	_SysBase,a6
				CALLA6	\1
				ENDM

INTCALL:		MACRO
				LibBase	intuition
				CALLA6	\1
				ENDM

GRAFCALL:		MACRO
				LibBase	graphics
				CALLA6	\1
				ENDM

DOSCALL:		MACRO
				LibBase	dos
				CALLA6	\1
				ENDM

LOWCALL:		MACRO
				LibBase	lowlevel
				CALLA6	\1
				ENDM

DSKFCALL:		MACRO
				LibBase	diskfont
				CALLA6	\1
				ENDM

RTGCALL:		MACRO
				LibBase	rtgmaster
				CALLA6	\1
				ENDM

;---------------------------------------------------------------------------

FILTER			macro
;       move.l  d0,-(sp)
;       move.l  #65000,d0
;.loop\@
;       bchg    #1,$bfe001
;       dbra    d0,.loop\@
;       move.l  (sp)+,d0
				endm

BLACK			macro
				move.w	#0,$dff180
				endm

RED				macro
				move.w	#$f00,$dff180
				endm

GREEN			macro
				move.w	#$0f0,$dff180
				endm

BLUE			macro
				move.w	#$f,$dff180
				endm

FLASHER:		MACRO
				move.l	d0,-(a7)
				move.w	#$ffff,d0
.fl\@:			move.w	#\1,$dff180
				nop
				nop
				nop
				dbf		d0,.fl\@
				move.l	(a7)+,d0
				ENDM



DataCacheOff	macro
				movem.l	a0-a6/d0-d7,-(sp)
				move.l	4.w,a6
				moveq	#0,d0
				move.l	#%0000000100000000,d1
				jsr		_LVOCacheControl(a6)
				movem.l	(sp)+,a0-a6/d0-d7
				endm

DataCacheOn		macro
				movem.l	a0-a6/d0-d7,-(sp)
				move.l	4.w,a6
				moveq	#-1,d0
				move.l	#%0000000100000000,d1
				jsr		_LVOCacheControl(a6)
				movem.l	(sp)+,a0-a6/d0-d7
				endm

SAVEREGS		MACRO
				movem.l	d0-d7/a0-a6,-(a7)
				ENDM

GETREGS			MACRO
				movem.l	(a7)+,d0-d7/a0-a6
				ENDM


WB				MACRO
\@bf:			btst	#6,dmaconr(a6)
				bne.s	\@bf
				ENDM

WBa				MACRO
\@bf:			move.w	#\2,$dff180

				btst	#6,$bfe001
				bne.s	\@bf
\@bz:			move.w	#$f0f,$dff180

				btst	#6,$bfe001
				beq.s	\@bz

				ENDM

*Another version for when a6 <> dff000

WBSLOW			MACRO
\@bf:			btst	#6,$dff000+dmaconr
				bne.s	\@bf
				ENDM

WT				MACRO
\@bf:			btst	#6,(a3)
				bne.s	\@bd
				rts
\@bd:			btst	#4,(a0)
				beq.s	\@bf
				ENDM

WTNOT			MACRO
\@bf:			btst	#6,(a3)
				bne.s	\@bd
				rts
\@bd:			btst	#4,(a0)
				bne.s	\@bf
				ENDM



red				macro
				move.l	d0,-(sp)
				move.l	#60000,d0
.redloop\@:		move.w	#$f00,$dff180
				dbra	d0,.redloop\@
				move.l	(sp)+,d0
				endm

green			macro
				move.l	d0,-(sp)
				move.l	#60000,d0
.gedloop\@:		move.w	#$0f0,$dff180
				dbra	d0,.gedloop\@
				move.l	(sp)+,d0
				endm

blue			macro
				move.l	d0,-(sp)
				move.l	#60000,d0
.bedloop\@:		move.w	#$00f,$dff180
				dbra	d0,.bedloop\@
				move.l	(sp)+,d0
				endm
