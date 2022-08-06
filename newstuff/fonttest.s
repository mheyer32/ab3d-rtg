

	OPT	O+,W-
	OUTPUT	ram:a
	INCLUDE	PROJ:AB3D/NewSource/macros.s


GetTitleFont:
	SAVEREGS

	lea	.gt_txtattr(pc),a0	;Set font for menu screens
	GRAFCALL	OpenFont
	move.l	d0,TitleFont
	beq.s	.gt_out

	move.l	d0,a0
	move.l	Scr_RP,a1
	CALLA6	SetFont

.gt_out:	GETREGS
	rts

.gt_txtattr:	dc.l	.gt_fontnam		;Name
	dc.w	8		;YSize
	dc.w	0		;Style
	dc.w	FPF_DESIGNED		;Flags

.gt_fontnam:	dc.b	"AB3DMenu.font",0
	EVEN



