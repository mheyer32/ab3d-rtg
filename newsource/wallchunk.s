
;----------------------------------------------------------------------------------

ReleaseWallMem:
				SAVEREGS

				lea		WallTilePtrs(pc),a0
				lea		wallchunkdata(pc),a5

.loop:			move.l	4(a5),d0				;d0=bytesize of next chunk
				beq.s	.done					;Skip if all done

				move.l	(a0),d1					;d1=start address
				beq.s	.notalloced				;Skip if not allocated

				movem.l	a0/a5,-(a7)
				move.l	d1,a1
				EXECCALL FreeMem
				movem.l	(a7)+,a0/a5

.notalloced:	addq.l	#8,a5
				addq.l	#4,a0
				bra.s	.loop

.done:			GETREGS
				rts

;----------------------------------------------------------------------------------

LoadWalls:		SAVEREGS

				lea		WallTilePtrs(pc),a0
				move.l	a0,a4
				moveq	#39,d7
.clrwalls:		clr.l	(a0)+
				dbf		d7,.clrwalls

	;Alloc memory for and load in all wall tiles

				lea		wallchunkdata(pc),a3	;a3=name,len table

.loademin:		move.l	4(a3),d0				;d0=length of this chunk
				beq		.loadedall				;Skip if all done

				movem.l	a4/a3,-(a7)

				move.l	d0,UnpackedLen			;Store filename & unpacked length
				move.l	(a3),blockname

				move.l	blockname,d1			;Open wall file
				move.l	#MODE_OLDFILE,d2
				DOSCALL	Open
				move.l	d0,-(a7)
				beq.s	.noload

				lea		fib,a5					;Get file length from FIB
				move.l	(a7),d1
				move.l	a5,d2
				DOSCALL	ExamineFH
				move.l	$7c(a5),blocklen

				move.l	#MEMF_PUBLIC,d1			;Alloc memory for unpacked data
				move.l	UnpackedLen,d0
				EXECCALL AllocMem
				move.l	d0,blockstart

				move.l	(a7),d1					;Read crunched file to scratchmem
				move.l	#WorkSpace,d2
				move.l	blocklen,d3
				DOSCALL	Read

				move.l	(a7),d1					;Close file
				DOSCALL	Close

				move.l	#WorkSpace,d0			;Uncrunch file
				moveq	#0,d1
				move.l	blockstart,a0
				move.l	LevelDataPtr,a1
				sub.l	a2,a2
				jsr		unLHA

.noload:		addq.l	#4,a7
				movem.l	(a7)+,a4/a3

				move.l	blockstart,(a4)+
				move.l	UnpackedLen,4(a3)

				addq	#8,a3
				bra		.loademin

.loadedall:		GETREGS
				rts

handle:			dc.l	0

UnpackedLen:	dc.l	0

WallTilePtrs:	ds.l	40

wallchunkdata:
				dc.l	GreenMechanicNAME,18560
				dc.l	BlueGreyMetalNAME,13056
				dc.l	TechnoDetailNAME,13056
				dc.l	BlueStoneNAME,4864
				dc.l	RedAlertNAME,7552
				dc.l	RockNAME,10368
				dc.l	scummyNAME,13056
				dc.l	stairfrontsNAME,2400
				dc.l	bigdoorNAME,13056
				dc.l	redrockNAME,13056
				dc.l	dirtNAME,24064
				dc.l	SwitchesNAME,3456
				dc.l	shinyNAME,24064
				dc.l	bluemechNAME,15744
				dc.l	0,0

GreenMechanicNAME: dc.b	'AB3D1:includes/walls/greenmechanic.wad',0
BlueGreyMetalNAME: dc.b	'AB3D1:includes/walls/bluegreymetal.wad',0
TechnoDetailNAME: dc.b	'AB3D1:includes/walls/technodetail.wad',0
BlueStoneNAME:	dc.b	'AB3D1:includes/walls/bluestone.wad',0
RedAlertNAME:	dc.b	'AB3D1:includes/walls/redalert.wad',0
RockNAME:		dc.b	'AB3D1:includes/walls/rock.wad',0
scummyNAME:		dc.b	'AB3D1:includes/walls/scummy.wad',0
stairfrontsNAME: dc.b	'AB3D1:includes/walls/stairfronts.wad',0
bigdoorNAME:	dc.b	'AB3D1:includes/walls/bigdoor.wad',0
redrockNAME:	dc.b	'AB3D1:includes/walls/redrock.wad',0
dirtNAME:		dc.b	'AB3D1:includes/walls/dirt.wad',0
SwitchesNAME:	dc.b	'AB3D1:includes/walls/switches.wad',0
shinyNAME:		dc.b	'AB3D1:includes/walls/shinymetal.wad',0
bluemechNAME:	dc.b	'AB3D1:includes/walls/bluemechanic.wad',0
				EVEN
