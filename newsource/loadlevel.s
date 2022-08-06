;*****************************************************************************
;Get memory for & load level data
;*****************************************************************************

LoadLevel:		SAVEREGS

				moveq	#MEMF_PUBLIC,d1			;Alloc texture space
				move.l	#50000,d0
				EXECCALL AllocMem
				move.l	d0,LevelGfxPtr

				moveq	#MEMF_PUBLIC,d1			;Alloc clip space
				move.l	#40000,d0
				CALLA6	AllocMem
				move.l	d0,LevelClipsPtr

				move.w	LevelSelected,d0		;Generate names of level files
				add.b	#'a',d0
				move.b	d0,LEVA
				move.b	d0,LEVB
				move.b	d0,LEVC

				move.l	#LDname,d1				;Load level data
				move.l	#MODE_OLDFILE,d2
				DOSCALL	Open
				move.l	d0,-(a7)

				move.l	d0,d1
				move.l	LevelClipsPtr,d2
				move.l	#40000,d3
				CALLA6	Read

				move.l	(a7)+,d1
				CALLA6	Close

				move.l	LevelClipsPtr,d0		;Decrunch level data
				moveq	#0,d1
				move.l	LevelDataPtr(pc),a0
				lea		WorkSpace,a1
				sub.l	a2,a2
				jsr		unLHA

;--
				move.l	#LGname,d1				;Load level graphics
				move.l	#MODE_OLDFILE,d2
				CALLA6	Open
				move.l	d0,-(a7)

				move.l	d0,d1
				move.l	LevelClipsPtr,d2
				move.l	#40000,d3
				CALLA6	Read

				move.l	(a7)+,d1
				CALLA6	Close

				move.l	LevelClipsPtr,d0		;Decrunch level graphics
				moveq	#0,d1
				move.l	LevelGfxPtr,a0
				lea		WorkSpace,a1
				sub.l	a2,a2
				jsr		unLHA

;--
				move.l	#LCname,d1				;Load level clips
				move.l	#MODE_OLDFILE,d2
				CALLA6	Open
				move.l	d0,-(a7)

				move.l	d0,d1
				move.l	#WorkSpace+16384,d2
				move.l	#16000,d3
				CALLA6	Read

				move.l	(a7)+,d1
				CALLA6	Close

				move.l	#WorkSpace+16384,d0		;Decrunch level clips
				moveq	#0,d1
				move.l	LevelClipsPtr,a0
				lea		WorkSpace,a1
				sub.l	a2,a2
				jsr		unLHA

	; Initialize level
	; Poke all clip offsets into
	; correct bit of level data.

				move.l	LevelGfxPtr,a0
				move.l	12(a0),a1
				add.l	a0,a1
				move.l	a1,ZoneGraphAdds
				move.l	(a0),a1
				add.l	a0,a1
				move.l	a1,DoorData
				move.l	4(a0),a1
				add.l	a0,a1
				move.l	a1,LiftData
				move.l	8(a0),a1
				add.l	a0,a1
				move.l	a1,SwitchData
				adda.w	#16,a0
				move.l	a0,ZoneAdds

				move.l	LevelDataPtr(pc),a1
				move.l	16+6(a1),a2
				add.l	a1,a2
				move.l	a2,Points
				move.w	8+6(a1),d0
				lea		4(a2,d0.w*4),a2
				move.l	a2,PointBrights

				move.l	20+6(a1),a2
				add.l	a1,a2
				move.l	a2,FloorLines
				move.l	24+6(a1),a2
				add.l	a1,a2
				move.l	a2,ObjectData
				move.l	28+6(a1),a2
				add.l	a1,a2
				move.l	a2,PlayerShotData
				move.l	32+6(a1),a2
				add.l	a1,a2
				move.l	a2,NastyShotData

				add.l	#64*20,a2
				move.l	a2,OtherNastyData

				move.l	36+6(a1),a2
				add.l	a1,a2
				move.l	a2,ObjectPoints
				move.l	40+6(a1),a2
				add.l	a1,a2
				move.l	a2,PLR1_Obj
				move.l	44+6(a1),a2
				add.l	a1,a2
				move.l	a2,PLR2_Obj
				move.w	14+6(a1),NumObjectPoints


				move.l	LevelClipsPtr,a2
				moveq	#0,d0
				move.w	10+6(a1),d7				;numzones
.assignclips:
				move.l	(a0)+,a3
				add.l	a1,a3					; pointer to a zone
				adda.w	#ToListOfGraph,a3		; pointer to zonelist
.dowholezone:
				tst.w	(a3)
				blt.s	.nomorethiszone
				tst.w	2(a3)
				blt.s	.thisonenull

				move.l	d0,d1
				asr.l	#1,d1
				move.w	d1,2(a3)

.findnextclip:
				cmp.w	#-2,(a2,d0.l)
				beq.s	.foundnextclip
				addq.l	#2,d0
				bra.s	.findnextclip
.foundnextclip:
				addq.l	#2,d0

.thisonenull:
				addq	#8,a3
				bra.s	.dowholezone

.nomorethiszone:
				dbra	d7,.assignclips

				lea		(a2,d0.l),a2
				move.l	a2,CONNECT_TABLE

	; SET UP INITIAL POSITION OF PLAYER

				move.l	LevelDataPtr(pc),a1
				move.w	4(a1),d0
				move.l	ZoneAdds,a0
				move.l	(a0,d0.w*4),d0
				add.l	LevelDataPtr(pc),d0
				move.l	d0,PLR1_Roompt
				move.l	PLR1_Roompt,a0
				move.l	ToZoneFloor(a0),d0
				sub.l	#playerheight,d0
				move.l	d0,PLR1s_yoff
				move.l	d0,PLR1_yoff
				move.l	d0,PLR1s_tyoff
				move.l	PLR1_Roompt,PLR1_OldRoompt

				move.l	LevelDataPtr(pc),a1
				move.w	10(a1),d0
				move.l	ZoneAdds,a0
				move.l	(a0,d0.w*4),d0
				add.l	LevelDataPtr(pc),d0
				move.l	d0,PLR2_Roompt
				move.l	PLR2_Roompt,a0
				move.l	ToZoneFloor(a0),d0
				sub.l	#playerheight,d0
				move.l	d0,PLR2s_yoff
				move.l	d0,PLR2_yoff
				move.l	d0,PLR2s_tyoff
				move.l	d0,PLR2_yoff

				move.l	PLR2_Roompt,PLR2_OldRoompt

				move.w	(a1),PLR1s_xoff
				move.w	2(a1),PLR1s_zoff
				move.w	(a1),PLR1_xoff
				move.w	2(a1),PLR1_zoff
				move.w	6(a1),PLR2s_xoff
				move.w	8(a1),PLR2s_zoff
				move.w	6(a1),PLR2_xoff
				move.w	8(a1),PLR2_zoff

				GETREGS
				rts

;--------------------------------------------------------------------------------

UnLoadLevel:	SAVEREGS

				lea		LevelGfxPtr,a1
				move.l	#50000,d0
				jsr		parole

				lea		LevelClipsPtr,a1
				move.l	#40000,d0
				jsr		parole

				GETREGS
				rts

;--------------------------------------------------------------------------------

LDname:			dc.b	'ab3d2:levels/level_'
LEVA:			dc.b	'a/twolev.bin',0

LGname:			dc.b	'ab3d2:levels/level_'
LEVB:			dc.b	'a/twolev.graph.bin',0

LCname:			dc.b	'ab3d2:levels/level_'
LEVC:			dc.b	'a/twolev.clips',0
				EVEN

LevelDataPtr:
				dc.l	0

Prefsfile:		dc.b	"k"						;keyboard/joystick
				dc.b	"4"						;4/8 channel
				dc.b	"n"						;Stereo?
				dc.b	"x"
				dcb.b	50
				EVEN

;--------------------------------------------------------------------------------

_DOSBase:		dc.l	0
mors:			dc.w	0

;--------------------------------------------------------------------------------
