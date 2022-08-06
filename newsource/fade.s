;******************************************************************************
;Colour fading routines
;******************************************************************************

FadeMain:		;Main	fading					routine
	;Entry:	FadeVal, FadeAmount, FadeDir, FadePal set up

				SAVEREGS

				moveq	#0,d0
				move.w	FadeVal(pc),d0
				move.w	FadeAmount(pc),d1
				move.w	FadeDir(pc),d2

.fadeloop:		movem.l	d0-2/a0,-(a7)
				move.l	Scr_Base,a0
				RTGCALL	RtgWaitTOF
				movem.l	(a7)+,d0-2/a0
				bsr.s	setfadedpal
				add.w	d2,d0
				dbf		d1,.fadeloop

				subq	#4,d0
				move.w	d0,FadeVal

				GETREGS
				rts

;----------

ClearPal:		;Set	palette					to all black

				SAVEREGS
				moveq	#0,d0
				bsr.s	setfadedpal
				GETREGS
				rts

;----------

SetPal:			;Set	palette					to full intensity

				SAVEREGS
				move.l	#256,d0
				bsr.s	setfadedpal
				GETREGS
				rts

;----------

setfadedpal:	;Scale	palette					array according to d0
	;and load scaled palette into colour regs
	;Entry:	d0=scale value 0-256

				SAVEREGS

				move.l	FadePal(pc),a0			;a0=source colour vec
				lea		FadeTmpPal(pc),a1		;a1=RGB table

				move.w	Scr_Colours+2,d2		;No of. colours to process
				move.w	d2,(a1)+				;Set no. of colours
				clr.w	(a1)+					;Set start colour
				subq.w	#1,d2

.putloop:		movem.l	(a0)+,d3-5				;d3-5 = next RGB triplet

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

				dbf		d2,.putloop

				clr.w	(a1)					;Finish table

				move.l	Scr_Base,a0				;a0=screen base
				lea		FadeTmpPal(pc),a1		;a1=RGB table
				RTGCALL	LoadRGBRtg

				GETREGS
				rts

;----------------------------------------------------------------------------------

				CNOP	0,4
FadeVal:		dc.w	0
FadeAmount:		dc.w	0
FadeDir:		dc.w	0
				dc.w	0

FadePal:		dc.l	0

FadeTmpPal:		dc.w	0,0
				dcb.l	3*256
				dc.w	0

;----------------------------------------------------------------------------------
