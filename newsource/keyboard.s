;**********************************************************************************
; Input handler/keyboard stuff
;**********************************************************************************

Add_IHandler:
	;Add our input eater handler monster daemon thing
	;Returns 0 if failed

				tst.b	IH_handok				;Skip if already installed
				bne		.aih_installed

				SAVEREGS

				EXECCALL CreateMsgPort			;Create message port
				move.l	a0,d0
				beq.s	.aih_failure
				move.l	d0,IH_msgport

				move.l	#IOSTD_SIZE,d0			;Create standard ioreq stucture
				CALLA6	CreateIORequest
				move.l	a0,d0
				beq.s	.aih_failure
				move.l	d0,IH_ioreq

				move.l	a0,a1					;Open input.device (a1=ioreq)
				lea		.inp_name(pc),a0		;a0=device name
				moveq	#0,d0					;d0=unit
				moveq	#0,d1					;d1=flags
				CALLA6	OpenDevice				;Open it
				bne.s	.aih_failure

				st		IH_inpopen				;Set flag

				lea		MyIS_Input(pc),a0		;Init the Interrupt structure
				move.b	#127,LN_PRI(a0)			;Handler priority (max)
				move.l	#.myih_name,LN_NAME(a0)	;Name of owner (us)
				move.l	#MyInt_Input,IS_CODE(a0) ;Interrupt routine
				move.l	#KeyMap,IS_DATA(a0)		;Ptr to data

				move.l	IH_ioreq(pc),a1			;Init the IORequest for addhandler
				move.l	a0,IO_DATA(a1)			;Ptr to Interrupt structure
				move.w	#IND_ADDHANDLER,IO_COMMAND(a1) ;Command - add input handler
				CALLA6	DoIO					;Add the input handler

				st.b	IH_handok
				GETREGS

.aih_installed:
				moveq	#-1,d0
				rts

.aih_failure:
				bsr.s	Rem_IHandler			;Unwind open/allocated things
				GETREGS
				moveq	#0,d0
				rts

.inp_name:		dc.b	"input.device",0

.myih_name:		dc.b	"AB3D-SE Input Eater",0
				EVEN

;----------------------------------------------------------------------------------

Rem_IHandler:
	;Remove our input handler
				SAVEREGS

				tst.b	IH_inpopen				;Did we open input.device
				beq.s	.rih_inperror			;Skip if not

				tst.b	IH_handok
				beq.s	.rih_handerr

				move.l	IH_ioreq(pc),a1			;Init the IORequest for remhandler
				move.l	#MyIS_Input,IO_DATA(a1)	;Ptr to Interrupt structure
				move.w	#IND_REMHANDLER,IO_COMMAND(a1) ;Command - remove input handler
				EXECCALL DoIO					;Remove the input handler
				clr.b	IH_handok

.rih_handerr:
				move.l	IH_ioreq(pc),a1			;Close input.device
				EXECCALL CloseDevice
				clr.b	IH_inpopen

.rih_inperror:
				move.l	IH_ioreq(pc),d0			;Delete ioreq
				beq.s	.rih_ioerror
				move.l	d0,a0
				EXECCALL DeleteIORequest
				clr.l	IH_ioreq

.rih_ioerror:
				move.l	IH_msgport(pc),d0		;Delete message port
				beq.s	.rih_msgerror
				move.l	d0,a0
				EXECCALL DeleteMsgPort
				clr.l	IH_msgport

.rih_msgerror:
				GETREGS
				rts

;----------------------------------------------------------------------------------

Open_Keyboard:
	;Set up keyboard device for reading the key matrix
	;Returns 0 if failed

				SAVEREGS

				tst.b	KB_kbopen				;Skip if already installed
				bne		.sk_installed

				EXECCALL CreateMsgPort			;Create message port
				move.l	a0,d0
				beq.s	.sk_failure
				move.l	d0,KB_msgport

				move.l	#IOSTD_SIZE,d0			;Create standard ioreq stucture
				EXECCALL CreateIORequest
				move.l	a0,d0
				beq.s	.sk_failure
				move.l	d0,KB_ioreq

				move.l	a0,a1					;Open input.device (a1=ioreq)
				lea		.inp_name(pc),a0		;a0=device name
				moveq	#0,d0					;d0=unit
				moveq	#0,d1					;d1=flags
				EXECCALL OpenDevice				;Open it
				bne.s	.sk_failure

				st		KB_kbopen				;Set flag

.sk_installed:
				GETREGS
				moveq	#-1,d0
				rts

.sk_failure:	bsr		Close_Keyboard			;Unwind open/allocated things
				GETREGS
				moveq	#0,d0
				rts

.inp_name:		dc.b	"keyboard.device",0

.myih_name:		dc.b	"AB3D-SE Keyboard Reader",0
				EVEN

;----------------------------------------------------------------------------------

MyInt_Input:	;Keyboard interrupt				server
	;a0=InputEvent structure
	;a1=IS_DATA=KeyMap

				cmp.b	#IECLASS_RAWKEY,ie_Class(a0) ;Keypress?
				bne.s	.ki_done				;Ignore if not

				move.w	ie_Code(a0),d0			;d0=keycode
				tst.b	d0
				bpl.s	.ki_keydown				;Skip if key-down event

				and.w	#$7f,d0					;Key-up event
				clr.b	0(a1,d0.w)
				bra.s	.ki_done

.ki_keydown:	and.w	#$7f,d0					;Store keycode/qualifier
				st		0(a1,d0.w)
				move.b	d0,lastpressed
				move.w	#$f00,$dff180

.ki_done:		moveq	#0,d0					;Return Z to eat all input events
				rts

lastpressed:	dc.b	0
				EVEN

;----------------------------------------------------------------------------------

;Read_Keyboard:
;	;Read the current state of the keyboard matrix
;
;	SAVEREGS
;
;	lea          KeyMap(pc),a0          ;Clear matrix store
;	moveq        #0,d0
;	REPT         15
;	move.l       d0,(a0)+
;	ENDR
;	move.l       d0,(a0)
;
;	move.l       KB_ioreq(pc),a1           ;Init the IORequest for read
;	lea          KeyMap(pc),a0          ;Ptr to state store
;	move.l       a0,IO_DATA(a1)
;	move.w       #KBD_READMATRIX,IO_COMMAND(a1) ;Command
;	move.w       #16,IO_LENGTH(a1)         ;Length of matrix
;	EXECCALL     DoIO	         	;Read the keyboard
;
;	GETREGS
;	rts

;--------------------------------------------------------------------------------

ClearKeyboard:
	;Mark all keys as "unpressed"

				SAVEREGS

				lea		KeyMap(pc),a5
				moveq	#0,d0
				moveq	#15,d1
.clrloop:		move.l	d0,(a5)+
				move.l	d0,(a5)+
				move.l	d0,(a5)+
				move.l	d0,(a5)+
				dbra	d1,.clrloop

				GETREGS
				rts

;----------------------------------------------------------------------------------

Close_Keyboard:
	;Close the keyboard.device

				SAVEREGS

				tst.b	KB_kbopen				;Did we open keyboard.device
				beq.s	.ck_kberror				;Skip if not

				move.l	KB_ioreq(pc),a1			;Close keyboard.device
				EXECCALL CloseDevice
				clr.b	KB_kbopen

.ck_kberror:	move.l	KB_ioreq(pc),d0			;Delete ioreq
				beq.s	.ck_ioerror
				move.l	d0,a0
				EXECCALL DeleteIORequest
				clr.l	KB_ioreq

.ck_ioerror:	move.l	KB_msgport(pc),d0		;Delete message port
				beq.s	.ck_msgerror
				move.l	d0,a0
				EXECCALL DeleteMsgPort
				clr.l	KB_msgport

.ck_msgerror:
				GETREGS
				rts

;----------------------------------------------------------------------------------

	;Variables for various inputhandler things

				CNOP	0,4
MyIS_Input:		dcb.b	IS_SIZE					;Keyboard interrupt structure

IH_msgport:		dc.l	0						;ptr to message port
IH_ioreq:		dc.l	0						;ptr to iorequest for input.device

IH_inpopen:		dc.b	0						;Set NZ if input.device opened
IH_handok:		dc.b	0						;Set NZ if ADDHANDLER succeeded


	;Variables for keyboard.device things

KB_msgport:		dc.l	0						;ptr to message port
KB_ioreq:		dc.l	0						;ptr to iorequest for keyboard.device

KB_kbopen:		dc.b	0						;Set NZ if keyboard.device opened

				CNOP	0,4
KeyMap:			ds.b	256						;Key state store

;----------------------------------------------------------------------------------
