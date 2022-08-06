;********************************************************************************

Scr_Open:		;Open	game					screen and store data about it
				SAVEREGS

				lea		.smr_tags(pc),a0		;Do the screenmode req
				RTGCALL	RtgScreenModeReq
				move.l	d0,Scr_Req
				beq		.so_leave

				move.l	d0,a0					;Open the RTG screen
				lea		.so_tags(pc),a1
				CALLA6	OpenRtgScreen
				move.l	d0,Scr_Base
				beq		.so_leave

				move.l	d0,-(a7)				;Stop screen moving
				move.l	d0,a0
				CALLA6	LockRtgScreen

				move.l	(a7),a0					;Get info about RTG screen
				lea		.gsd_tags(pc),a1
				CALLA6	GetRtgScreenData
				move.l	.gsd_width+4(pc),Scr_Width
				move.l	.gsd_height+4(pc),Scr_Height
				move.l	.gsd_depth+4(pc),d0
				moveq	#1,d1
				lsl.w	d0,d1
				move.l	d1,Scr_Colours

				jsr		ClearTitlePal			;Set palette to all black

				move.l	(a7),a0					;Set blank pointer
				lea		.so_blankpointer(pc),a1
				moveq	#16,d0
				moveq	#18,d1
				moveq	#0,d2
				moveq	#0,d3
				CALLA6	RtgSetPointer

				move.l	.gsd_depth+4(pc),d0		;Setup for EHB or 256 colour palette
				cmp.w	#8,d0
				beq.s	.so_init8
				bsr		.so_initforehb
				bra.s	.so_donepalinit
.so_init8:		bsr		.so_initfor8bit
.so_donepalinit:

				move.l	Scr_Width,d0			;Get X to center 320 wide stuff
				sub.l	#320,d0
				lsr.l	#1,d0
				move.l	d0,Scr_C320X

				move.l	Scr_Height,d0			;Get Y to center 200 wide stuff
				sub.l	#200,d0
				lsr.l	#1,d0
				move.l	d0,Scr_C200Y

				move.l	(a7),a0					;Get buffer addresses
				moveq	#0,d0
				CALLA6	GetBufAdr
				move.l	d0,Scr_Buf0

				move.l	(a7),a0
				moveq	#1,d0
				CALLA6	GetBufAdr
				move.l	d0,Scr_Buf1

				move.l	(a7)+,a0				;Init RDCMP port
				CALLA6	RtgInitRDCMP

.so_leave:		move.l	Scr_Req(pc),d0			;Free screenreq if opened
				beq.s	.sol_nofreereq
				move.l	d0,a0
				CALLA6	FreeRtgScreenModeReq
				clr.l	Scr_Req
.sol_nofreereq:

				GETREGS
				move.l	Scr_Base(pc),d0			;d0=return code, 0 for error
				rts

;-----

.so_initforehb:
				move.l	#tspal_6,ts_pal
				move.b	#"6",ts_namenum
				move.w	#31,ts_stdpen
				move.w	#18,ts_hipen
				rts
;-----

.so_initfor8bit:
				move.l	#tspal_8,ts_pal
				move.b	#"8",ts_namenum
				move.w	#255,ts_stdpen
				move.w	#254,ts_hipen
				rts
;-----
				CNOP	0,4

.smr_tags:		;Tags	for						the screenmode requester

				dc.l	smr_MinWidth,320
				dc.l	smr_MinHeight,200
				dc.l	smr_MaxWidth,320
				dc.l	smr_MaxHeight,256
				dc.l	smr_ChunkySupport,LUT8
				dc.l	smr_PlanarSupport,Planar8|PlanarEHB
				dc.l	smr_Buffers,2
				dc.l	TAG_END,0


.so_tags:		;Tags	for						the screen open

				dc.l	rtg_Buffers,2
				dc.l	rtg_Workbench,0
				dc.l	TAG_END,0


.gsd_tags:		;Tags	for						screen info

				dc.l	grd_BytesPerRow,0
.gsd_width:		dc.l	grd_Width,0
.gsd_height:	dc.l	grd_Height,0
.gsd_depth:		dc.l	grd_Depth,0
.gsd_pfmt:		dc.l	grd_PixelLayout,0
				dc.l	grd_ColorSpace,0
				dc.l	grd_PlaneSize,0
				dc.l	TAG_END,0

.so_blankpointer:
				dcb.b	72,0					;Data for blank pointer image

;-----------------------------------------------------------------------------------

Scr_Close:		;Close	our						screen if open

				SAVEREGS

				move.l	Scr_Base(pc),d0
				beq.s	.sc_done

				move.l	d0,a0
				RTGCALL	UnlockRtgScreen

				move.l	Scr_Base(pc),a0
				CALLA6	CloseRtgScreen

				clr.l	Scr_Base

.sc_done:		GETREGS
				rts

;-----------------------------------------------------------------------------------

Win_Clear:		;Clear	window					to colour 0
				SAVEREGS

				move.l	Win_RP,a1
				moveq	#0,d0
				GRAFCALL SetRast
				CALLA6	WaitBlit

				GETREGS
				rts

;-----------------------------------------------------------------------------------

WaitIntuiMessage:
	;Wait for a message for our window and store its class/code
	;Exit:	Msg_Class/d0 hold message class
	;	Msg_Code/d1  hold message code

				movem.l	d2-7/a0-6,-(a7)

.wi_loop:		move.l	Scr_Base(pc),a0			;Wait for the signal
				move.l	a0,-(a7)
				RTGCALL	RtgWaitRDCMP

				move.l	(a7),a0					;Get d0=message
				CALLA6	RtgGetMsg

				move.l	d0,a1					;Save message information
				move.l	im_Class(a1),Msg_Class
				move.w	im_Code(a1),Msg_Code+2
				move.l	(a7)+,a0
				CALLA6	RtgReplyMsg				;Reply to message

				cmp.l	#IDCMP_RAWKEY,Msg_Class	;If rawkey, set flag in keymap
				bne.s	.wi_notrawkey

				move.l	Msg_Code(pc),d0			;d0=keycode pressed
				cmp.w	#256,d0
				bge.s	.wi_notnormrawkey

				lea		KeyMap,a0				;Remember keypress
				st		0(a0,d0.w)
				move.b	d0,lastpressed
				bra.s	.wi_notrawkey

.wi_notnormrawkey:
.wi_notrawkey:
				movem.l	(a7)+,d2-7/a0-6
				move.l	Msg_Class(pc),d0
				move.l	Msg_Code(pc),d1
				rts

;-----------------------------------------------------------------------------------

WaitIntuiKeyMsg:
	;Wait for an IDCMP key-up message

				move.l	d0,-(a7)

.wi_loop:		jsr		WaitIntuiMessage		;Wait for intuition keypress message
				cmp.l	#IDCMP_RAWKEY,Msg_Class
				bne.s	.wi_loop

				move.l	Msg_Code(pc),d0			;d0=keycode
				btst	#7,d0					;Key up?
				beq.s	.wi_loop				;Loop if not

				bclr	#7,Msg_Code+3			;Clear key-up bit
				move.l	(a7)+,d0
				rts

;-----------------------------------------------------------------------------------

ProcGameIntuiMsg:
	;Process any IDCMP messages waiting for us

				SAVEREGS

.pi_loop:		move.l	Scr_Base(pc),a0			;Get d0=message from userport
				RTGCALL	RtgGetMsg

				tst.l	d0						;Any messages?
				beq.s	.pi_nomoremessages		;Skip if not

				move.l	d0,a1					;Save message information
				move.l	im_Class(a1),d0
				moveq	#0,d1
				move.w	im_Code(a1),d1
				move.l	d0,Msg_Class
				move.l	d1,Msg_Code

				movem.l	d0-1,-(a7)				;Reply to message
				CALLA6	ReplyMsg
				movem.l	(a7)+,d0-1

				cmp.l	#IDCMP_RAWKEY,d0		;Keypress?
				bne.s	.pi_notrawkey			;Skip if not

				btst	#7,d1					;Set/clear keymap byte for this key
				seq		d2
				bclr	#7,d1

				cmp.w	#256,d1					;Skip if not a "normal" rawkey
				bge.s	.pi_notnormrawkey		; eg: fake joystick keycode

				lea		KeyMap,a0
				move.b	d2,(a0,d1.w)
				move.b	d1,lastpressed
				bra.s	.pi_nextmsg

.pi_notnormrawkey:
				bra.s	.pi_nextmsg

.pi_notrawkey:
				cmp.l	#IDCMP_ACTIVEWINDOW,d0	;Activate window?
				bne.s	.pi_notactive			;Skip if not

				nop

.pi_notactive:
				cmp.l	#IDCMP_INACTIVEWINDOW,d0 ;Deactivate window?
				bne.s	.pi_notdeactive			;Skip if not

				nop

.pi_notdeactive:
.pi_nextmsg:	bra		.pi_loop				;See if there are more messages

.pi_nomoremessages:
				GETREGS
				rts

;-----------------------------------------------------------------------------------

InitGameScreen:
	;Display in-game status panel

				SAVEREGS

				move.l	Win_RP,a1				;Set drawmode
				moveq	#RP_JAM2,d0
				CALLA6	SetDrMd

				move.l	Win_RP,a0				;Set writemask
				moveq	#-1,d0
				CALLA6	SetWriteMask

				lea		BGPicBitMap,a0			;a0=source bitmap
				moveq	#0,d0					;d0,d1=src x,y
				moveq	#0,d1
				move.l	Win_RP,a1				;a1=dest rastport
				moveq	#0,d2					;d2,d3=src x,y
				moveq	#0,d3
				move.l	#320,d4					;Width
				move.l	#256,d5					;Height
				move.l	#$c0,d6					;MinTerm - straight copy
				CALLA6	BltBitMapRastPort
				CALLA6	WaitBlit

				move.w	#0,FadeVal
				move.w	#63,FadeAmount
				move.w	#4,FadeDir
				move.l	#gs_pal,FadePal
				jsr		FadeMain

				move.l	Scr_VP,a0
				lea		gs_l32tab(pc),a1
				CALLA6	LoadRGB32

				GETREGS
				rts

gs_l32tab:		dc.w	256,0
gs_pal:			INCBIN	border.pal
gs_pal_e:
				dc.w	0
				EVEN

;-----------------------------------------------------------------------------------

				CNOP	0,4
Scr_Req:		dc.l	0
Scr_Base:		dc.l	0
Scr_Buf0:		dc.l	0
Scr_Buf1:		dc.l	0
Scr_Width:		dc.l	0
Scr_Height:		dc.l	0
Scr_Colours:	dc.l	0
Scr_C320X:		dc.l	0
Scr_C200Y:		dc.l	0

Scr_VP:			dc.l	0
Scr_RP:			dc.l	0
Scr_BM:			dc.l	0

Win_Base:		dc.l	0
Win_Ptr:		dc.l	0
Win_RP:			dc.l	0
Win_UP:			dc.l	0

WPA8_BM:		dc.l	0
WPA8_TmpRP:		dcb.b	rp_SIZEOF

VP_ColorMap:	dc.l	0

Msg_Class:		dc.l	0
Msg_Code:		dc.l	0

;-----------------------------------------------------------------------------------
