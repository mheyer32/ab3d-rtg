;
;     $VER: rtgsublibs.i 1.006 (29 Jul 1996)
;

        IFND    RTGSUBLIBS_I
RTGSUBLIBS_I    SET     1

        IFND    UTILITY_TAGITEM_I
        Include "utility/tagitem.i"
        ENDC

        IFND    EXEC_TYPES_I
        Include "exec/types.i"
        ENDC

        IFND    EXEC_NODES_I
        Include "exec/nodes.i"
        ENDC

* The TagItem ID's (ti_Tag values) for OpenRtgScreen()
*
* Information like width, height, screenmode to use, depth and overscan
* information is located in the ScreenReq structure which must be passed
* to OpenRtgScreen().  The RtgScreenModeReq() function creates these
* ScreenReq structures for you.

ARGB32 EQU 1
RGB24  EQU 2
RGB16  EQU 4
RGB15  EQU 8
ABGR32 EQU 16
BGR24  EQU 32
BGR16  EQU 64
BGR15  EQU 128
RGBA32 EQU 256
LUT8   EQU 512
GRAFFITI EQU 1024
RGB15PC  EQU 2048
BGR15PC  EQU 4096
RGB16PC  EQU 8192
BGR16PC  EQU 16384
BGRA32   EQU 32768
Planar1  EQU 1
Planar2  EQU 2
Planar3  EQU 4
Planar4  EQU 8
Planar5  EQU 16
Planar6  EQU 32
Planar7  EQU 64
Planar8  EQU 128
Planar1I EQU 65536
Planar2I EQU 131072
Planar3I EQU 262144
Planar4I EQU 524288
Planar5I EQU 1048576
Planar6I EQU 2097152
Planar7I EQU 4194304
Planar8I EQU 8388608
PlanarEHB EQU 32768
PlanarEHBI EQU 2147483648


    ENUM TAG_USER+1           ;rtg_Tags (OpenRtgScreen)

    EITEM rtg_Buffers       ;[1] You can use this tag to specify the number
                            ;of screen buffers for your screen.  Setting this
                            ;to 2 or 3 will allow you to do Double or Triple
                            ;buffering.  Valid values are 1, 2 or 3.
    EITEM rtg_Interleaved   ;[FALSE] Specifying TRUE will cause bitmaps to
                            ;be allocated interleaved.  OpenRtgScreen will
                            ;fail if bitplanes cannot be allocated that way
                            ;unlike Intuition/OpenScreenTagList().
    EITEM rtg_Draggable     ;[TRUE] Specifying FALSE will make the screen
                            ;non-draggable.  Do not use without good reason!
    EITEM rtg_Exclusive     ;[FALSE] Allows screens which won't share the
                            ;display with other screens.  Use sparingly!

    EITEM rtg_ChunkySupport ;[0] This LONG is used to indicate which
;                            ;Chunky modes this application supports.  A
;                            ;set bit means the mode is supported:
;    ;     
;    ;    | Pixels  | Pixel|Color| Pixel 
;    ; Bit|represent| size |space| layout
;    ;------------------------------------------------------------------
;    ;  0  TrueColor  LONG   RGB   %00000000 rrrrrrrr gggggggg bbbbbbbb  ARGB32
;    ;  1  TrueColor 3 BYTE  RGB   %rrrrrrrr gggggggg bbbbbbbb           RGB24
;    ;  2  TrueColor  WORD   RGB   %rrrrrggg gggbbbbb                    RGB16
;    ;  3  TrueColor  WORD   RGB   %0rrrrrgg gggbbbbb                    RGB15
;    ;  4  TrueColor  LONG   BGR   %00000000 bbbbbbbb gggggggg rrrrrrrr  ABGR32
;    ;  5  TrueColor 3 BYTE  BGR   %bbbbbbbb gggggggg rrrrrrrr           BGR24
;    ;  6  TrueColor  WORD   BGR   %bbbbbggg gggrrrrr                    BGR16
;    ;  7  TrueColor  WORD   BGR   %0bbbbbgg gggrrrrr                    BGR15
;    ;  8  TrueColor  LONG   RGB   %rrrrrrrr gggggggg bbbbbbbb 00000000  RGBA32
;    ;  9  ColorMap   BYTE   -     -                                     LUT8
;    ; 10  Graffiti   BYTE   -     - (Graffiti style chunky, very special)
;    ; 11  TrueColor  WORD   RGB   %gggbbbbb 0rrrrrgg                    RGB15PC
;    ; 12  TrueColor  WORD   BGR   %gggrrrrr 0bbbbbgg                    BGR15PC
;    ; 13  TrueColor  WORD   RGB   %gggbbbbb rrrrrggg                    RGB16PC
;    ; 14  TrueColor  WORD   BGR   %gggrrrrr bbbbbggg                    BGR16PC
;    ; 15  TrueColor  LONG   BGR   %bbbbbbbb gggggggg rrrrrrrr 00000000  BGRA32
;
;    ; This table is by no means complete.  There are probably more modes
;    ; available on common Amiga graphic cards, but I have no information
;    ; on them yet.  If you know about such modes please contact me.
;
;    ; Setting this LONG to zero means your application doesn't support
;    ; any Chunky orientated display modes.
;
     EITEM rtg_PlanarSupport ;[0] This LONG is used to indicate which
;                            ;Planar modes this application supports.  A
;                            ;set bit means the mode is supported:
;    ; Bit 0: Indicates it supports 1 bitplane non-interleaved
;    ; Bit 1: Indicates it supports 2 bitplanes non-interleaved
;    ; (...)
;    ; Bit 7: Indicates it supports 8 bitplanes non-interleaved
;
;    ; Bit 16: Indicates it supports 1 bitplane interleaved
;    ; Bit 17: Indicates it supports 2 bitplanes interleaved
;    ; (...)
;    ; Bit 23: Indicates it supports 8 bitplanes interleaved
;
;    ; Bit 15: Indicates it supports EHB mode (6 bitplanes) non-interleaved
;    ; Bit 31: Indicates it supports EHB mode (6 bitplanes) interleaved
;
;    ; Note that all planar modes are color-mapped.  Bits 8-14 and 24-30
;    ; are unused for now, but could be used later to support planar modes
;    ; with even higher number of bitplanes.
;
;    ; Setting this LONG to zero means your application doesn't support
;    ; any Planar orientated display modes.




     EITEM rtg_ZBuffer

     ; Should a Z-Buffer be allocated ? (Only for usage with rtgmaster 3D Extensions)

     EITEM rtg_Use3D

     ; Use the 3D Chips. (You can only do conventional Double/Triple-Buffering, if you do NOT use
     ; them. If you use them, the Extra Buffers are used by the 3D Chips)

     EITEM rtg_Workbench

     ; Open a Window on the Workbench, instead of a Screen. This Tag takes the Colorformat
     ; to use with CopyRtgBlit() as Parameter

     EITEM rtg_MouseMove

     ; RtgGetMsg also returns IDCMP_MOUSEMOVE messages

     EITEM rtg_DeltaMove

     ; RtgGetMsg also returns IDCMP_MOUSEMOVE messages, and it returns Delta-Values,
     ; not absolute values.

     EITEM rtg_PubScreenName

     ; Open a Window on a Public Screen with the provided Public Screen Name.
     ; Note: This does not work with all Sublibraries. Some simply ignore this
     ; (For example EGS...)


     EITEM rtg_ChangeColors

     ; If set, in case of a Workbench Window the Colors are REALLY changed. If
     ; Not set, only ObtainBestPens is done... normally not setting it is the
     ; best choice. If that gives you not nice looking colors, you might try
     ; to set it...

*** End of OpenRtgScreenTagList() enumeration ***


* This structure is private and for the internal use of RtgMaster.library
* and its sub-libraries ONLY.  This structure will change in the future.

 STRUCTURE RtgDimensionInfo,0
  ULONG rdi_Width    ; in pixels
  ULONG rdi_Height   ; in pixels
  LABEL rdi_SIZEOF

* This structure is private and for the internal use of RtgMaster.library
* and its sub-libraries ONLY.  This structure will change in the future.
  
 STRUCTURE ScreenMode,0
  STRUCT sm_ScrNode,8     ; ln_Succ and ln_Pred from ListNode structure

  APTR  sm_Name
  APTR  sm_Description    ; Description of the graphics board this mode
                          ; requires.  For example: "Standard Amiga Chipset".
                          ; Description should not be longer than 31
                          ; characters including terminating NULL-byte.  This
                          ; pointer might be zero so watch out.
  ULONG sm_GraphicsBoard  ; The graphics board this mode requires
  ULONG sm_ModeID         ; ModeID (depends on sm_GraphicsBoard)
  STRUCT sm_Reserved,8    ; 8 bytes reserved space for use of the sub-library
                          ; who creates this ScreenMode structure.  This is
                          ; PRIVATE to the sub-library!

  ULONG sm_MinWidth       ; minimum width in pixels
  ULONG sm_MaxWidth       ; maximum width in pixels
  ULONG sm_MinHeight      ; minimum height in pixels
  ULONG sm_MaxHeight      ; maximum height in pixels

  STRUCT sm_Default,rdi_SIZEOF  ; Standard width and height of this ScreenMode
  STRUCT sm_TextOverscan,rdi_SIZEOF  ; Settable via preferences
  STRUCT sm_StandardOverscan,rdi_SIZEOF  ; Standard overscan size
  STRUCT sm_MaxOverscan,rdi_SIZEOF  ; Maximum width and height (without the
                                    ; need for AutoScrolling).  Hardware
                                    ; dependant.

  ULONG sm_ChunkySupport  ; This LONG is used to indicate which Chunky
                          ; modes this ScreenMode supports.  A set bit
                          ; means the mode is available.  See the
                          ; rtg_ChunkySupport tag for more information.
                          ; Note that the same ScreenMode may never
                          ; use two different layouts (for example BGR
                          ; and RGB)

  ULONG sm_PlanarSupport  ; This LONG is used to indicate which Planar
                          ; modes this ScreenMode supports.  A set bit
                          ; means the mode is available.  See the
                          ; rtg_PlanarSupport tag for more information.
                          ; Note that the same ScreenMode may never
                          ; use both interleaved and non-interleaved
                          ; layouts.

  ULONG sm_PixelAspect    ; For a PAL 320x256 screen you have to write
                          ; this value here:  sm_PixelAspect =
                          ; (320/4)/(256/3) * 65536
                          ;
                          ; This tells the relation between the height and
                          ; the width of a single pixel on 4:3 screen.  For
                          ; a 640x480 screen this value is 1*65536.

  ULONG sm_VertScan       ; Vertical scan rate of this screenmode
                          ; (in Hz)
  ULONG sm_HorScan        ; Horizontal scan rate of this screenmode
                          ; (in Hz)
  ULONG sm_PixelClock     ; Pixelclock rate (in Hz)
  ULONG sm_VertBlank      ; Vertical blank rate of this screenmode
                          ; (in Hz)  (How often the VBlank interupt
                          ; is triggered)
  ULONG sm_Buffers        ; The number of buffers this ScreenMode can
                          ; can handle.  This should always be atleast
                          ; 1, 2 if the Screen can do double-buffering
                          ; and 3 if it can do triple-buffering.

  UWORD sm_BitsRed        ; The number of bits per gun for Red
  UWORD sm_BitsGreen      ; The number of bits per gun for Green
  UWORD sm_BitsBlue       ; The number of bits per gun for Blue

  LABEL sm_SIZEOF

* The TagItem ID's (ti_Tag values) for GetRtgScreenData()
*
* These tags are used to return data to the user about the RtgScreen
* structure in a future compatible way.

    ENUM TAG_USER+1

    EITEM grd_Width         ;Gets you the Width in pixels of the screen
    EITEM grd_Height        ;Gets you the Height in pixels of the screen
    EITEM grd_PixelLayout   ;Gets you the pixellayout of the screen, see
                            ;defines below.  This also tells you whether
                            ;the screen is Chunky or Planar
    EITEM grd_ColorSpace    ;Gets you the colorspace of the screen, see
                            ;defines below
    EITEM grd_Depth         ;The number of colors LOG 2.  For Planar modes
                            ;this also tells you the number of bitplanes.
                            ;Don't rely on this number except to get the
                            ;number of colors for Chunky modes.
    EITEM grd_PlaneSize     ;Tells you the number of bytes to skip to get
                            ;to the next (bit)plane.  You can use this to
                            ;find the start addresses of the other (bit)planes
                            ;in Planar and in (BytePlane) Chunky modes
    EITEM grd_BytesPerRow   ;The number of bytes taken up by a row.  This
                            ;refers to one (bit/byte)plane only for modes
                            ;working with planes.
    EITEM grd_MouseX        ; The X coordinate of the mouse pointer
    EITEM grd_MouseY        ; The Y coordinate of the mouse pointer
    EITEM grd_BusSystem     ; To which Bussystem is the Board connected ?
    EITEM grd_3DChipset     ; For the use of the 3D Extensions
    EITEM grd_Bitmap
    EITEM grd_ScrollVPort
    EITEM grd_Screen
    EITEM grd_Window

grd_Z3 EQU 1 ; Zorro III
grd_Z2 EQU 2 ; Zorro II
grd_Custom EQU 3 ; Custom Chipset
grd_RGBPort EQU 4 ; connected to RGB Port
grd_GVP EQU 5 ; EGS 110 is connected to "special" bus of GVP Turbo Board
grd_DDirect EQU 6 ; DraCo Direct Bus
grd_Ateo EQU 7 ; Ateo Bus
grd_PCI EQU 8 ; PCI

* defines for grd_PixelLayout

grd_PLANAR     EQU 0    ; Non interleaved planar layout [X bitplanes/pixel]
grd_PLANARI    EQU 1    ; Interleaved planar layout     [X bitplanes/pixel] 
grd_CHUNKY     EQU 2    ; 8-bit Chunky layout           [BYTE/pixel]
grd_HICOL15    EQU 3    ; 15-bit Chunky layout          [WORD/pixel]
grd_HICOL16    EQU 4    ; 16-bit Chunky layout          [WORD/pixel]
grd_TRUECOL24  EQU 5    ; 24-bit Chunky layout          [3 BYTES/pixel]
grd_TRUECOL24P EQU 6    ; 24-bit Chunky layout          [3 BYTEPLANES/pixel]
grd_TRUECOL32  EQU 7    ; 24-bit Chunky layout          [LONG/pixel] (RGBx or BGRx)
grd_GRAFFITI   EQU 8    ; 8-bit Graffiti-type Chunky layout (very special...)
grd_TRUECOL32B EQU 9    ; 24-bit Chunky layout          [LONG/pixel] (xRGB or xBGR)

* defines for grd_ColorSpace

grd_Palette    EQU 0    ; Mode uses a Color Look-Up Table (CLUT)
grd_RGB        EQU 1    ; standard RGB color space
grd_BGR        EQU 2    ; high-endian RGB color space, BGR
grd_RGBPC      EQU 3    ; RGB with lowbyte and highbyte swapped
grd_BGRPC      EQU 4    ; BGR with lowbyte and highbyte swapped

*** End of GetRtgScreenData() enumeration ***


* Information about the RtgScreenModeReq tags:
*
* Each tag specified for the RtgScreenModeReq() function limits in some
* way the number of ScreenModes available to the user.  Sometimes this
* means a screenmode is completely ommited, and sometimes this means
* certain screenmodes can only be used if the user selects them to
* be wide enough.  So for example, a ScreenMode which supports screens
* of 300 to 400 pixels in width, could be filtered out completely by
* setting smr_MinWidth to 401.  But if the smr_MinWidth is set to for
* example 320 then the user is allowed to select a width of 320-400
* pixels (for this ScreenMode, and if the smr_MaxWidth allows this).
* If smr_MinWidth is 200 pixels then the ScreenMode is the limiting
* factor which means the user can't select ScreenModes smaller than
* 300 pixels.
*
* The PlanarSupport and ChunkySupport tags determine which ScreenModes
* are available to the user depending on their layout and number of
* colors.

* This structure is private and for the internal use of RtgMaster.library
* and its sub-libraries ONLY.  This structure will change in the future.

 STRUCTURE ScreenReq,0
  ULONG sq_ScreenMode ; Ptr to ScreenMode structure
  ULONG sq_Width      ; Must be within Tag specified limits
  ULONG sq_Height     ; The width and height which the user selected
  UWORD sq_Depth      ; Number of colors log2 which the user selected
  UWORD sq_Overscan   ; 0 = No Overscan.  See defines below.
  UBYTE sq_Flags      ; Bit 0 set: EHB selected (sq_Depth = 6)
                      ; Bit 1 set: Chunky mode
                      ; Bit 2 set: Default X gadget selected
                      ; Bit 3 set: Default Y gadget selected
                      ; Bit 4 set: Autoscroll gadget selected
                      ; Bit 5 set: B&W gadget selected
  LABEL sq_SIZEOF

 STRUCTURE ScreenReqList,0
  STRUCT srl_SRNode,8
  APTR srl_req
  LABEL srl_SIZEOF

* Bits set in sq_Flags

sq_EHB          EQU 1 ; EHB selected (sq_Depth = 6)
sq_CHUNKYMODE   EQU 2 ; Chunky Mode selected
sq_DEFAULTX     EQU 4 ; Default Width selected
sq_DEFAULTY     EQU 8 ; Default Height selected
sq_WORKBENCH    EQU 16; User wants to use Workbench Window

* defines for sq_Overscan

sq_NOOVERSCAN        EQU 0
sq_TEXTOVERSCAN      EQU 1   ; User setable, should be entirely visible
sq_STANDARDOVERSCAN  EQU 2   ; Standard overscan (just past edges)
sq_MAXOVERSCAN       EQU 3   ; Maximum overscan (as much as possible)

* This structure is private and for the internal use of RtgMaster.library
* and its sub-libraries ONLY.  This structure will change in the future.

 STRUCTURE RtgScreen,0
  ULONG rs_LibBase        ; Sub-library base for this ID
  UWORD rs_LibVersion     ; Sub-library version for this ID
  UWORD rs_Pad1
  ULONG rs_GraphicsBoard  ; ID
  STRUCT rs_Reserved,20
  ULONG rs_MouseX
  ULONG rs_MouseY
  APTR  rs_c2pcode
  APTR rs_c2pdata
  ULONG rs_c2pcurr
  STRUCT rs_c2pname,30
  ; This structure is just a fixed-size header for the real sub library's
  ; and graphics board's specific RtgScreen structure.  These are stored
  ; in the rtgXXXX.i files
  LABEL rs_SIZEOF

        ENDC
