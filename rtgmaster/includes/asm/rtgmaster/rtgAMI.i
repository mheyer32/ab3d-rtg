;
;     $VER: rtgAMI.i 1.005 (09 Oct 1997)
;

        IFND    RTGAMI_I
RTGAMI_I        SET     1

        IFND    RTGSUBLIBS_I
        Include "include:Rtgmaster/RtgSublibs.i"
        ENDC

        IFND    EXEC_LIBRARIES_I
        Include "exec/libraries.i"
        ENDC

        IFND    EXEC_TYPES_I
        Include "exec/types.i"
        ENDC

;
; Include files for rtgAMI.library
;
; Only rtgAMI.library specific structures are located in here
;

 STRUCTURE RtgBaseAMI,0
  STRUCT rbAMI_LibBase,LIB_SIZE
  UWORD  rbAMI_Pad1
  ULONG rbAMI_SegList
  APTR  rbAMI_ExecBase
  APTR  rbAMI_UtilityBase
  APTR  rbAMI_DosBase
  APTR  rbAMI_CGXBase
  APTR  rbAMI_GfxBase
  APTR  rbAMI_IntBase
  ULONG rbAMI_Flags
  APTR  rbAMI_ExpansionBase
  APTR  rbAMI_DiskFontBase
  LABEL rbAMI_SIZEOF

 STRUCTURE RtgScreenAMI,0
  STRUCT rsAMI_Header,rs_SIZEOF
  UWORD rsAMI_Locks
  ULONG rsAMI_ScreenHandle
  ULONG rsAMI_PlaneSize
  ULONG rsAMI_DispBuf      ;Buffer currently displayed
  ULONG rsAMI_ChipMem1
  ULONG rsAMI_ChipMem2
  ULONG rsAMI_ChipMem3
  STRUCT rsAMI_Bitmap1,40
  STRUCT rsAMI_Bitmap2,40
  STRUCT rsAMI_Bitmap3,40
  ULONG rsAMI_Flags
  STRUCT rsAMI_MyRect,8
  STRUCT rsAMI_Place,52
  STRUCT rsAMI_RastPort1,100
  STRUCT rsAMI_RastPort2,100
  STRUCT rsAMI_RastPort3,100
  APTR   rsAMI_MyWindow
  APTR   rsAMI_Pointer
  STRUCT   rsAMI_PortData,16
  ULONG rsAMI_dbufinfo
  ULONG rsAMI_DispBuf1
  ULONG rsAMI_DispBuf2
  ULONG rsAMI_DispBuf3
  ULONG rsAMI_SafeToWrite
  ULONG rsAMI_SafeToDisp
  ULONG rsAMI_SrcMode
  APTR rsAMI_tempras
  APTR rsAMI_tempbm
  APTR rsAMI_wbcolors
  ULONG rsAMI_Width
  ULONG rsAMI_Height
  ULONG rsAMI_colchanged
  APTR  rsAMI_colarray1
  APTR  rsAMI_ccol
  LABEL rsAMI_SIZEOF

        ENDC
