;*****************************************************************************
;Sound stuff
;*****************************************************************************

InitSound:	SAVEREGS

	move.l       #empty,pos1LEFT
	move.l       #empty,pos2LEFT
	move.l       #empty,pos1RIGHT
	move.l       #empty,pos2RIGHT
	move.l       #emptyend,Samp0endLEFT
	move.l       #emptyend,Samp1endLEFT
	move.l       #emptyend,Samp0endRIGHT
	move.l       #emptyend,Samp1endRIGHT

	move.l       #$dff000,a6

	move.l       #null,$dff0a0
	move.w       #100,$dff0a4
	move.w       #443,$dff0a6
	move.w       #63,$dff0a8

	move.l       #null2,$dff0b0
	move.w       #100,$dff0b4
	move.w       #443,$dff0b6
	move.w       #63,$dff0b8

	move.l       #null4,$dff0c0
	move.w       #100,$dff0c4
	move.w       #443,$dff0c6
	move.w       #63,$dff0c8

	move.l       #null3,$dff0d0
	move.w       #100,$dff0d4
	move.w       #443,$dff0d6
	move.w       #63,$dff0d8

	cmp.b        #'s',Prefsfile+2	;Set Stero/Mono sound mode
	seq          STEREO

	lea	tab,a1
	moveq	#64,d7
	moveq	#0,d6
.outerlop:	lea	pretab,a0
	move.w       #255,d5
.scaledownlop:
	move.b       (a0)+,d0
	extb	d0
	muls         d6,d0
	asr.l        #6,d0
	move.b       d0,(a1)+
	dbra         d5,.scaledownlop
	addq         #1,d6
	dbra         d7,.outerlop

	clr.b        UseAllChannels

	move.l       SampleList+6*8,pos0LEFT
	move.l       SampleList+6*8+4,Samp0endLEFT

	GETREGS
	rts
