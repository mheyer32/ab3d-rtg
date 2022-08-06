;
;     $VER: rtgmaster.i 1.010 (08 Mar 1997)
;

        IFND    RTGMASTER_I
RTGMASTER_I     SET     1

        IFND    UTILITY_TAGITEM_I
        Include "utility/tagitem.i"
        ENDC

        IFND    EXEC_LIBRARIES_I
        Include "exec/libraries.i"
        ENDC

        IFND    EXEC_TYPES_I
        Include "exec/types.i"
        ENDC


* The TagItem ID's (ti_Tag values) for RtgScreenModeReq()
*
* If a tag is ommited the value in the square brackets will be used
* as the default value.

    ENUM TAG_USER+1         ; smr_Tags (RtgScreenModeReq)

    EITEM smr_MinWidth      ;[320] This tag sets the minimum width in
                            ;pixels which the user is allowed to select
    EITEM smr_MaxWidth      ;[2048] This tag sets the maximum width in
                            ;pixels which the user is allowed to select
    EITEM smr_MinHeight     ;[200] This tag sets the minimum height in
                            ;pixels which the user is allowed to select
    EITEM smr_MaxHeight     ;[2048] This tag sets the maximum height in
                            ;pixels which the user is allowed to select

    EITEM smr_PlanarRoundW  ;[16] RtgScreenModeReq will round user inputed
                            ;values for Width to nearest higher multiple
                            ;of thig tag for Planar display modes
    EITEM smr_PlanarRoundH  ;[1] RtgScreenModeReq will round user inputed
                            ;values for Height to nearest higher multiple
                            ;of thig tag for Planar display modes

    EITEM smr_ChunkyRoundW  ;[1] RtgScreenModeReq will round user inputed
                            ;values for Width to nearest higher multiple
                            ;of thig tag for Chunky display modes
    EITEM smr_ChunkyRoundH  ;[1] RtgScreenModeReq will round user inputed
                            ;values for Height to nearest higher multiple
                            ;of thig tag for Chunky display modes

    EITEM smr_ChunkySupport ;[0] This LONG is used to indicate which
                            ;Chunky modes the user is allowed to select.
                            ;A set bit means the mode is selectable.
                            ;See the rtg_ChunkySupport tag for more
                            ;information.

    EITEM smr_PlanarSupport ;[0] This LONG is used to indicate which
                            ;Planar modes the user is allowed to select.
                            ;A set bit means the mode is selectable.
                            ;See the rtg_PlanarSupport tag for more
                            ;information.

    EITEM smr_Buffers       ;[1] Using this tag you're can specify
                            ;the number of buffers your application needs.
                            ;Usually this ranges from 1-3.  Specify
                            ;it here to filter out ScreenModes which can't
                            ;handle the number of buffers you require.

    EITEM smr_ProgramUsesC2P;[TRUE] If the program doesn't use the c2p call you have
                            ;to specify FALSE. In this case the c2p part of the
                            ;window is hidden and the the current c2p module is not
                            ;used when filtering the screen modes.

    EITEM smr_Dummy2        ; Deleted Tagitem

    EITEM smr_Dummy3        ; Deleted Tagitem

    EITEM smr_Dummy4        ; Deleted Tagitem

;*******
; Attention: The following initial values are overwritten
; by the saved preferences if a valid preferences file
; is found.

    EITEM smr_InitialWidth  ;[320] Initial screen width
                            ;The minimal/maximal selectable width is taken into account.

    EITEM smr_InitialHeight ;[200] Initial screen height
                            ;The minimal/maximal selectable height is taken into account.

    EITEM smr_InitialDepth  ;[8] Log2 of number of colors
    EITEM smr_InitialScreenMode ;[the first selectable screenmode]
                                ;Ptr to a string describing the ScreenMode
                                ;(this is essentially the string pointed to
                                ;by sm_Name)

    EITEM smr_InitialDefaultW   ;[TRUE] False if you don't want the Default
                                ;width gadget active.

    EITEM smr_InitialDefaultH   ;[TRUE] False if you don't want the Default
                                ;height gadget active.

    EITEM smr_PrefsFileName
        ; ["RtgScreenMode.prefs"] (STRPTR)
        ; Specifies the file where the selected screenmode is saved when the
        ; user selects the save button

    EITEM smr_ForceOpen
        ; [FALSE] If false, the screenmode requester reads the screenmode
        ; from the file specified by smr_PrefsFileName and returns immediately.
        ; The requester opens only in case of an error when reading the preferences
        ; or when the user presses shift while the requester is called.
        ; If true, the requester opens in any case and lets the user select a
        ; new mode.

    EITEM smr_TitleText         ;["RTG Screenmode Requester"] (STRPTR)
                                ;The title text of the window

    EITEM smr_WindowLeftEdge    ;[0] The left edge of the requester window

    EITEM smr_WindowTopEdge     ;[0] The top edge of the requester window

    EITEM smr_Screen

; [Default Pubscreen] (struct Screen *)
; The (custom or public) screen on which the screenmode requester should
; be opened

    EITEM smr_PubScreenName

; [NULL] (STRPTR)
; The name of the public screen on which the screenmode
; requester should be opened; if not found, the default
; pubscreen is used.

; ----------------added on 27/10/97 by Wolfram---------------

    EITEM smr_MinPixelAspect

; [0] Minimal pixel aspect, defined as
; (1 << 16) * pixel_height / pixel_width
; see also: smr_PixelAspect_Proportional, _Wide and _High

    EITEM smr_MaxPixelAspect

; [ULONG_MAX] Maximal pixel aspect, defined as
; (1 << 16) * pixel_height / pixel_width

    EITEM smr_Workbench

; Offer Workbench Support

; End of RtgScreenModeReq() enumeration ***


;**********************************************************************
; Special values for smr_MinPixelAspect and smr_MaxPixelAspect:
;
; If you want to get only proportional screen modes with 20% variation,
; you can set for example:
;
; smr_MinPixelAspect, smr_PixelAspect_Proportional *  8 / 10,
; smr_MaxPixelAspect, smr_PixelAspect_Proportional * 12 / 10
;

;smr_PixelAspect_Proportional EQU (1 << 16)
;smr_PixelAspect_Wide         EQU (smr_PixelAspect_Proportional / 2)
;smr_PixelAspect_Narrow       EQU (smr_PixelAspect_Proportional * 2)

;End of RtgScreenModeReq() enumeration ***

*** End of RtgScreenModeReq() enumeration ***


    
* Execpt for the rb_LibBase structure this structure is private and for
* the internal use of RtgMaster.library ONLY.  This structure will change
* in the future.

 STRUCTURE RtgBase,0
  STRUCT rb_LibBase,LIB_SIZE
  ALIGNLONG
  ULONG rb_SegList
  APTR  rb_DosBase
  APTR  rb_ExecBase
  APTR  rb_GadToolsBase
  APTR  rb_GfxBase
  APTR  rb_IntBase
  APTR  rb_UtilityBase
  STRUCT rb_Track,8        ; Special memory tracking structure
  APTR  rb_Libraries       ; Ptr to a list of RtgLibs structures
  APTR  rb_FirstScreenMode ; Ptr to first ScreenMode structure
  APTR  rb_LinkerDB
  LABEL rb_SIZEOF

* This structure is private and for the internal use of RtgMaster.library
* ONLY.  This structure will change in the future.

 STRUCTURE RDCMPData,0
    APTR rdcmp_port
    ULONG rdcmp_signal
    APTR rdcmp_MouseX
    APTR rdcmp_MouseY
  LABEL rdcmp_SIZEOF

 STRUCTURE RtgLibs,0
  APTR  rl_Next           ; Link to next structure
  ULONG rl_ID
  APTR  rl_LibBase
  APTR  rl_SMList         ; Null if there aren't any screenmodes
  APTR  rl_LastSM
  UWORD rl_LibVersion
  LABEL rl_SIZEOF

 STRUCTURE RtgBobHandle,0
  ULONG rbh_BufSize
  APTR  rbh_RtgScreen
  APTR  rbh_RefreshBuffer
  ULONG rbh_BPR
  ULONG rbh_Width
  ULONG rbh_Height
  UWORD rbh_numsprites
  UWORD rbh_maxnum
  ULONG rbh_reserved
  LABEL rbh_SIZEOF

;ECS_ID EQU     "ECS "
;AGA_ID EQU     "AGA "
;PICASSO_ID     EQU     "PICA"
;RETINA_ID      EQU     "RETI"
;MERLIN_ID      EQU     "MERL"
;EGS_ID EQU     "EGS "
;CYBGFX_ID      EQU     "CYBG"

        ENDC
