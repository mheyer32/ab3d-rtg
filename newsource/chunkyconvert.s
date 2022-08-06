;***********************************************************************************
;Routines to convert 12-bit copper colour array to screen
;***********************************************************************************

GetPensForCopCol:
	;Calculate pen numbers in in-game palette to
	;map from 12-bit copper colours to screen palette

				SAVEREGS

				move.l	#256,d0					;First, alloc a ColorMap to hold the palette
				GRAFCALL GetColorMap
				tst.l	d0
				beq		.mc_nocmap
				move.l	d0,-(a7)

				move.l	d0,a0					;Fill in ColorMap with game palette
				lea		gs_pal_e,a1
				move.l	#255,d0
.mc_initcmap:
				move.l	-(a1),d3
				move.l	-(a1),d2
				move.l	-(a1),d1
				movem.l	d0/a0-1,-(a7)
				CALLA6	SetRGB32CM
				movem.l	(a7)+,d0/a0-1
				dbf		d0,.mc_initcmap

	;Build table of best pen to use for each 12bit copper colour

				move.l	Cop2PenTab,a2			;a2=*end* of translation table
				lea		$1000(a2),a2
				move.l	(a7),a3					;a3=our ColorMap (const)
				moveq	#15,d1					;Red max
.mc_redloop:
				moveq	#15,d2					;Green max
.mc_grnloop:
				moveq	#15,d3					;Blue max

.mc_bluloop:	movem.l	d1-3,-(a7)

				move.l	d1,d0					;Create 32 bit RGB in d1-3
				bsr		.mc_4to32
				move.l	d0,d1
				move.l	d2,d0
				bsr		.mc_4to32
				move.l	d0,d2
				move.l	d3,d0
				bsr		.mc_4to32
				move.l	d0,d3

				moveq	#-1,d4
				CALLA6	FindColor				;d0=best matching pen number

				move.b	d0,-(a2)				;Save pen number (no pen=>use 255)

				movem.l	(a7)+,d1-3				;Loop for next RGB triplet
				dbf		d3,.mc_bluloop
				dbf		d2,.mc_grnloop
				dbf		d1,.mc_redloop

				move.l	(a7)+,a0				;Free ColorMap structure
				CALLA6	FreeColorMap

.mc_nocmap:		GETREGS
				rts

;-----

.mc_4to32:		move.b	d0,d7
				REPT	7
				lsl.l	#4,d0
				or.b	d7,d0
				ENDR
				rts

;-----------------------------------------------------------------------------------

ChunkyConvert:
	;Convert 12-bit copper colour array to display format

				SAVEREGS

				move.l	frompt,a0				;a0=source
				move.l	ChunkyArray,a1			;a1=dest
				move.l	Cop2PenTab,a2
				move.l	#96*80-1,d0				;d0=number of pixels

.cc_loop:		move.w	(a0)+,d1				;d1=12bit colour
				move.b	0(a2,d1.w),d2
				move.b	d2,(a1)+
				move.b	d2,(a1)+
				subq.l	#1,d0
				bpl.s	.cc_loop

				move.l	Win_RP,a0
				moveq	#32,d0
				moveq	#0,d1
				move.l	d0,d2
				add.w	#191,d2
				move.l	d1,d3
				add.w	#79,d3
				lea		WPA8_TmpRP,a1
				move.l	ChunkyArray,a2
				GRAFCALL WritePixelArray8

				GETREGS
				rts

;	move.l	drawpt,a0
;	move.l	Scr_BM,a1
;	move.l	bm_Planes(a1),a1
;	jsr	c2p1x1_cpu5

;-----------------------------------------------------------------------------------
