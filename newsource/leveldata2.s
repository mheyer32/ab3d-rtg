*************************************************
* Floor lines:		        *
* A floor line is a line seperating two rooms.  *
* The data for the line is therefore:           *
* x,y,dx,dy,Room1,Room2	            *
* For ease of editing the lines are initially   *
* stored in the form startpt,endpt,Room1,Room2  *
* and the program calculates x,y,dx and dy from *
* this information and stores it in a buffer.   *
*************************************************

PointsToRotatePtr:
				dc.l	0

***************************************


*************************************************************
* ROOM GRAPHICAL DESCRIPTIONS : WALLS AND FLOORS ************
*************************************************************

CONNECT_TABLE:
				dc.l	0
ListOfGraphRooms:
				dc.l	0
NastyShotData:
				dc.l	0
ObjectPoints:
				dc.l	0
PlayerShotData:
				dc.l	0
ObjectData:		dc.l	0
FloorLines:		dc.l	0
Points:			dc.l	0
PLR1_Obj:		dc.l	0
PLR2_Obj:		dc.l	0
ZoneGraphAdds:
				dc.l	0
ZoneAdds:		dc.l	0
NumObjectPoints:
				dc.w	0
LiftData:		dc.l	0
DoorData:		dc.l	0
SwitchData:		dc.l	0
CPtPos:			dc.l	0
NumCPts:		dc.w	0
OtherNastyData:
				dc.l	0

wall			SET		0
seethruwall		SET		13
floor			SET		1
roof			SET		2
setclip			SET		3
object			SET		4
curve			SET		5
light			SET		6
water			SET		7
bumpfloor		SET		8
bumproof		SET		9
smoothfloor		SET		10
smoothroof		SET		11
backdrop		SET		12

GreenStone		SET		0
MetalA			SET		4096
MetalB			SET		4096*2
MetalC			SET		4096*3
Marble			SET		4096*4
BulkHead		SET		4096*5
SpaceWall		SET		4096*6
Sand			SET		0
MarbleFloor		SET		2
RoofLights		SET		256
GreyRoof		SET		258

BackGraph:		dc.w	-1
				dc.w	backdrop
				dc.l	-1

NullClip:		dc.l	0

LevelGfxPtr:
				dc.l	0

;LevelGfxPtrD:
; ds.b 50000

; ds.b 50000
; incbin "tstlev.graph.bin"
LevelClipsPtr:	dc.l	0

;LevelClipsPtrD:
; ds.b 50000
; ds.b 50000
; incbin "tstlev.clips"

ControlPts:
; incbin "ab3:includes/newlev.map"
