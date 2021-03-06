;********************************************************************************
;Stuff to handle the small front screen & screen switching
;********************************************************************************

Scr_Open:	;Attempt to open OS screen in front of all others

	lea	.NewScreen(pc),a0		;Open our screen
	lea	.NewScreenTags(pc),a1
	INTCALL	OpenScreenTagList
	move.l	d0,Scr_Base
	rts

	CNOP 0,4
.NewScreen:	;The NewScreen structure we use
	;Most things are done in the taglist...
	dc.w 0,0			;LeftEdge, TopEdge
	dc.w 0,0,0			;Width, Height, Depth
	dc.b 0,0			;DetailPen, BlockPen
	dc.w 0			;PAL LORES
	dc.w 0			;Type
	dc.l 0			;Default font
	dc.l 0			;Title string
	dc.l 0			;Unused
	dc.l 0			;CustomBitmap

.NewScreenTitle:
	;The title of our screen
	dc.b "AB3D Screen",0
	EVEN

.NewScreenColours:
	;Palette for the front screen.
	dc.w 0,0,0,0
	dc.w 1,8,8,8
	dc.w -1

.NewScreenVC:
	dc.l VTAG_USERCLIP_SET,0
	dc.l VTAG_END_CM,0

.NewScreenTags:
	;Tags used to open our screen
	dc.l SA_Left,0		;Screen dimensions
	dc.l SA_Top,0
	dc.l SA_Width,320
	dc.l SA_Height,200
	dc.l SA_Depth,8
	dc.l SA_BlockPen,0		;Pens to use	
	dc.l SA_DetailPen,0
	dc.l SA_Colors,.NewScreenColours	;Palette
	dc.l SA_Title,.NewScreenTitle	;Ptr to title string
	dc.l SA_SysFont,0		;Default font

	dc.l SA_Type,CUSTOMSCREEN
	dc.l SA_DisplayID,PAL_MONITOR_ID|LORES_KEY
	dc.l SA_VideoControl,.NewScreenVC
	dc.l SA_Draggable,-1
	dc.l SA_Exclusive,-1
	dc.l TAG_END,TAG_END		;End of taglist

;-----------------------------------------------------------------------------------

Scr_Base:	dc.l 0

;-----------------------------------------------------------------------------------

Scr_Close:	;Close our screen if open
	move.l Scr_Base,d0
	beq.s .sc_done
	move.l d0,a0
	INTCALL CloseScreen

.sc_done:	clr.l Scr_Base
	rts

;-----------------------------------------------------------------------------------
