
;-----

NewList:	;a0=list to initialise

	CLR.L	4(A0)
	MOVE.L	A0,8(A0)
	ADDQ.L	#4,A0
	MOVE.L	A0,-(A0)
	RTS

;-----

CreateTask:	;d0=task pri
	;d1=stacksize
	;a0=task name
	;a1=task entry

	SUBA.W	#$002C,SP
	MOVEM.L	D6/D7/A2/A3/A5/A6,-(SP)
	MOVE.L	D0,D7
	MOVE.L	D1,$0018(SP)
	ADDQ.L	#3,D1
	MOVE.L	D1,D6
	ANDI.W	#$FFFC,D6
	MOVEA.L	A0,A2
	MOVE.L	A1,$0020(SP)

	LEA	$012C(A4),A6
	LEA	$0024(SP),A0
	MOVEQ	#7,D0
lbC000446:	MOVE.L	(A6)+,(A0)+
	DBRA	D0,lbC000446
	MOVE.L	D6,$0040(SP)
	LEA	$0024(SP),A0
	MOVEA.L	4.W,A6
	JSR	_LVOAllocEntry(A6)
	MOVEA.L	D0,A5
	TST.L	D0
	BNE.S	lbC000466
	MOVEQ	#0,D0
	BRA.S	lbC0004CA

lbC000466:	MOVEA.L	$0010(A5),A3
	MOVEA.L	$0018(A5),A0
	MOVE.L	A0,$003A(A3)
	MOVE.L	A0,D0
	ADD.L	D6,D0
	MOVE.L	D0,$003E(A3)
	MOVE.L	D0,$0036(A3)
	LEA	8(A3),A1
	MOVE.B	#1,(A1)+
	MOVE.B	D7,(A1)+
	MOVE.L	A2,(A1)+
	LEA	$004A(A3),A2
	MOVEA.L	A2,A0
	BSR	NewList
	MOVEA.L	A2,A0
	MOVEA.L	A5,A1
	JSR	_LVOAddHead(A6)
	MOVE.L	A3,-(SP)
	MOVEA.L	A3,A1
	SUBA.L	A3,A3
	MOVEA.L	$0024(SP),A2
	JSR	_LVOAddTask(A6)
	MOVEM.L	(SP)+,A3
	MOVEA.L	$03FC(A4),A0
	CMPI.W	#$0025,$0014(A0)
	BCS.S	lbC0004C8
	TST.L	D0
	BNE.S	lbC0004C8
	MOVEA.L	A5,A0
	JSR	_LVOFreeEntry(A6)
	MOVEQ	#0,D0
	dc.w	$0C40

;fiX Bad code terminator
lbC0004C8:	MOVE.L	A3,D0
lbC0004CA:	MOVEM.L	(SP)+,D6/D7/A2/A3/A5/A6
	ADDA.W	#$002C,SP
	RTS

_DeleteTask:	MOVEA.L	4(SP),A0
@DeleteTask:	MOVE.L	A6,-(SP)
	MOVEA.L	A0,A1
	MOVEA.L	4.W,A6
	JSR	_LVORemTask(A6)
	MOVEA.L	(SP)+,A6
	RTS
