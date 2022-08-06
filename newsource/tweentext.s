;***********************************************************************************
;Stuff to print the between-level text blurbs
;***********************************************************************************


RenderTweenText:
	; Draw between-level-text screen

				SAVEREGS

				clr.b	doanything				;!?!

				move.l	Scr_VP,a0				;Set palette for tweentext
				lea		dtt_pal(pc),a1
				clr.l	dtt_grn-dtt_pal(a1)
				GRAFCALL LoadRGB32

				move.l	Win_RP,a1				;Set drawmode etc.
				moveq	#255,d0
				moveq	#0,d1
				moveq	#RP_JAM1,d2
				CALLA6	SetABPenDrMd

				move.l	TweenFont,a0			;Set font
				move.l	Win_RP,a1
				CALLA6	SetFont

				lea		LEVELTEXT(pc),a2		;Get a2=start of text
				move.w	LevelSelected,d0
				mulu	#82*16,d0
				add.l	d0,a2

				moveq	#15,d7					;Number of lines
				moveq	#0,d0					;Start Y position
.dtt_printloop:
				bsr		.dtt_drawline
				addq.w	#1,d0
				lea		82(a2),a2
				dbf		d7,.dtt_printloop

				GETREGS
				rts

;-----

.dtt_drawline:
	;Draw a line of tweentext
	;Entry:	d0=Text Y coord to draw at
	;	a2=Text line

				SAVEREGS

				tst.b	(a2)+					;Print this line?
				bmi.s	.dl_noprint

				move.b	(a2)+,d1				;d1=center flag

				mulu	#10,d0					;Calc graphics Y coord
				add.w	#48,d0
				move.w	d0,d3

				moveq	#80,d2					;d2=max length of string

				LibBase	graphics

				tst.b	d1						;Do we center this line?
				beq.s	.dl_notcentered			;Skip if not

.dl_getstrlen:	;Get	length					of string excluding trailing spaces
				cmp.b	#" ",-1(a2,d2.w)
				dbne	d2,.dl_getstrlen

	;d2=char length of string to center
	;a0=start of string

				move.l	Win_RP,a1				;Get pixlength of string
				move.l	a2,a0
				move.w	d2,d0
				CALLA6	TextLength

				cmp.w	#320,d0					;Get X coord to center text
				bge.s	.dl_notcentered

				neg.w	d0
				add.w	#320,d0
				lsr.w	#1,d0
				bra.s	.dl_gotx

.dl_notcentered:
				moveq	#0,d0					;Not centered => X=0

.dl_gotx:		;d0=x	coord					to print at

				move.l	Win_RP,a1				;Move to text coords
				move.w	d3,d1					;d1=Y coord
				CALLA6	Move

				move.l	Win_RP,a1				;Print text
				move.l	a2,a0
				move.w	d2,d0
				CALLA6	Text

.dl_noprint:	GETREGS
				rts

.dl_strlen:		dc.w	0

;-----------------------------------------------------------------------------------

FadeInTweenText:
				SAVEREGS
				moveq	#0,d0
				moveq	#4,d1
				bra.s	dtt_fade

;---

FadeOutTweenText:
				SAVEREGS
				move.l	#255,d0
				moveq	#-4,d1

;---

dtt_fade:		;Fade	in/out					the tweentext
	;Entry:	d0=start fade value 0-255
	;	d1=fade step


				tst.l	d1						;If fading out (d1<0), set final colour to 0
				spl		d2						;otherwise set to $ffffffff
				extb	d2

				move.l	Scr_VP,a0				;Screen viewport
				lea		dtt_pal(pc),a1			;Palette array
				LibBase	graphics

.fd_loop:		movem.l	d0-1/a0-1,-(a7)
				CALLA6	WaitTOF

				movem.l	(a7),d0-1/a0-1
				lsl.w	#8,d0
				swap	d0
				or.l	#$00ffffff,d0
				move.l	d0,dtt_grn-dtt_pal(a1)
				CALLA6	LoadRGB32

				movem.l	(a7)+,d0-1/a0-1
				add.l	d1,d0
				bmi.s	.fd_done
				cmp.w	#255,d0
				ble.s	.fd_loop

.fd_done:		move.l	d2,dtt_grn-dtt_pal(a1)	;Set final value completely on/off
				CALLA6	LoadRGB32

				GETREGS
				rts

;-----

				CNOP	0,4
dtt_pal:		dc.w	1,255
				dc.l	$00000000
dtt_grn:		dc.l	$00ffffff
				dc.l	$00000000
				dc.w	0

;-----------------------------------------------------------------------------------

DRAWLINEOFTEXT:
				move.w	#$f00,$dff180
				rts

;-----------------------------------------------------------------------------------

				INCLUDE	level_blurb.s			;tweentext data

;-----------------------------------------------------------------------------------
