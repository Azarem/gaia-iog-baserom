; Future vision cutscene at Angkor Wat (~201 lines).
; 
; Major story cutscene showing Will a vision of the future
; world. The spirit guide reveals the new world's geography
; and the comet's role in reshaping Earth. Uses Mode 7
; or multi-layer effects for the vision display.
; Key narrative moment before the endgame.
---------------------------------------------

?INCLUDE 'mode7_perspective'
?INCLUDE 'oneshot_palette_flash_19'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!INIDISP                        2100
!M7SEL                          211A
!TM                             212C
!CGWSEL                         2130
!CGADSUB                        2131
!animScratch2                   7F000E
!loopCounter                    7F0014

---------------------------------------------

; Angkor Wat future vision actor-def — Mode 7 init and companion spawn.
; 
; Minimal actor-def following the same pattern as GardenCrashCutscene:
; 1. Mask joypad ($FFF0) to disable UI during cutscene
; 2. Configure Mode 7 color math: M7SEL=0, TM=$01 (BG1 main), CGADSUB=$01, CGWSEL=$82
; 3. SpawnThinker Mode7PerspectiveUpdate with $0804 in animScratch2
; 4. SpawnBefore FutureVisionController as companion
; 5. Single SetEntryContinue + RTL — actor remains alive but idle; all work done by companion
; 
; Note: uses TM ($212C) instead of TS ($212D) compared to garden_crash — main screen layer enable rather than sub screen.

FutureVisionCutscene [
  actor-def < #00, #00, #18, {

  code_03A1FD:
    LDA #$FFF0            ; Mask joypad $FFF0 — disable UI buttons during vision cutscene
    TSB $joypadMaskStd
    SEP #$20              ; Switch to 8-bit A for PPU register writes
    STZ $M7SEL            ; M7SEL = $00: no Mode 7 flip
    LDA #$01              ; TM = $01: BG1 on main screen (note: TM not TS, unlike garden_crash)
    STA $TM
    STA $CGADSUB          ; CGADSUB = $01: color math addition on BG1
    LDA #$82              ; CGWSEL = $82: sub screen = fixed color, math on BG & OBJ
    STA $CGWSEL
    REP #$20
    COP [SpawnThinker] ( @mode7_perspective.Mode7PerspectiveUpdate ) ; Spawn Mode7PerspectiveUpdate thinker for per-scanline rotation HDMA
    PHX 
    TYX                   ; Switch to thinker's actor slot
    LDA #$0804            ; $0804 → thinker params (same as garden crash: $08 rotation, $04 scale)
    STA $animScratch2, X
    PLX 
    COP [SpawnBefore] ( @FutureVisionController ) ; Spawn FutureVisionController as companion (does all the work)
    COP [SetEntryContinue] ; Yield indefinitely — actor stays alive but idle
    RTL 
} >
]

---------------------------------------------
; Companion thinker driving the 5-phase vision sequence.
; 
; Phase 1 — Init + zoom-in with rotation:
; - Camera position ($0170,$01D0), M7 center ($01F0,$0250)
; - Scale $001C, perspective $0130
; - Spawns oneshot_palette_flash_19 thinker for visual flash
; - Per-frame: INC $BC (rotate). On even frames only (skip odd via $0036 & 1): INC $B8 (zoom in)
; - Zoom-in runs until scale reaches $0080 (~200 frames at half-speed)
; 
; Phase 2 — Full rotation wait (loc_03A277):
; - New yield point via SetEntryContinue
; - Per-frame: check ($BC & $01FF) == 0 (full 512-step rotation)
; - INC $BC each frame until complete
; 
; Phase 3 — Hold + zoom-out with scroll (loc_03A285):
; - WaitByte $77: 119-frame pause
; - Per-frame zoom-out: DEC $B8 from $80 → $60 (32 frames)
; - Simultaneously: INC $B6 (rotation angle), INC cameraTargetY ×2, INC $CC ×2 (camera + M7 center scroll down by 2px/frame)
; 
; Phase 4 — Long upward scroll + brightness fade (loc_03A2A6):
; - Loop $FF (255): scroll up 1px/frame
; - Loop $80 (128): continued scroll
; - Loop $7F (127): scroll + INIDISP brightness fade. Extracts bits 3-6 of loopCounter via AND $0078 >> 3, producing 16-step fade from $0F to $00 (8 frames per brightness level)
; 
; Phase 5 — Scene transition:
; - QueueMapChange to scene $BF at ($00F8,$00C0), params ($00, $2200)
; - gfxCacheIdxA = $0001, gfxCacheIdxB = $0400
; - Final yield + RTL

FutureVisionController {
    LDA #$0800            ; Controller init: set render flag $0800
    TSB $10
    LDA #$0170            ; Camera X = $0170 (368px)
    STA $cameraTargetX
    LDA #$01D0            ; Camera Y = $01D0 (464px)
    STA $cameraTargetY
    LDA #$01F0            ; Mode 7 center X = $01F0 (496px)
    STA $00CA
    LDA #$0250            ; Mode 7 center Y = $0250 (592px)
    STA $00CC
    LDA #$001C            ; Scale = $001C (28) — very zoomed out initially
    STA $00B8
    LDA #$0130            ; Perspective angle = $0130 (304) — starting rotation offset
    STA $00BC
    COP [SpawnThinker] ( @oneshot_palette_flash_19.code_00B7D8 ) ; Spawn palette flash thinker for dramatic visual entrance
    COP [SetEntryContinue]
    INC $00BC             ; Phase 1: rotate perspective every frame
    LDA $0036             ; Check frame parity ($0036 & 1)
    AND #$0001
    BEQ loc_03A26A        ; Even frame → also zoom in; odd frame → rotation only (RTL)
    RTL 

  loc_03A26A:
    LDA $00B8             ; Check if scale reached $0080 (target zoom level)
    CMP #$0080
    BEQ loc_03A277
    INC                   ; INC scale — zoom in by 1 every other frame
    STA $00B8
    RTL 

  loc_03A277:
    COP [SetEntryContinue] ; Phase 2: new yield point — wait for full rotation
    LDA $00BC             ; Check perspective angle low 9 bits
    AND #$01FF
    BEQ loc_03A285        ; ($BC & $01FF) == 0 → full 512-step rotation complete
    INC $00BC             ; Not complete → keep rotating
    RTL 

  loc_03A285:
    COP [WaitByte] ( #77 ) ; Phase 3: WaitByte $77 — 119-frame pause to hold the view
    COP [SetEntryContinue]
    LDA $00B8             ; Zoom-out loop: check if scale reached $0060
    CMP #$0060
    BEQ loc_03A2A6        ; Scale == $60 → zoom-out complete, enter scroll phase
    DEC                   ; DEC scale — zoom out by 1 per frame
    STA $00B8
    INC $00B6             ; INC rotation angle ($B6) — spin during zoom-out
    INC $cameraTargetY    ; Scroll camera down 2px/frame (INC×2)
    INC $cameraTargetY
    INC $00CC             ; Scroll Mode 7 center down 2px/frame (INC×2)
    INC $00CC
    RTL 

  loc_03A2A6:
    COP [LoopInit] ( #FF ) ; Phase 4a: 255-frame upward scroll
    DEC $cameraTargetY    ; Scroll camera up 1px/frame
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #80 ) ; Phase 4b: 128-frame continued scroll
    DEC $cameraTargetY
    DEC $00CC
    COP [LoopNext]
    COP [LoopInit] ( #7F ) ; Phase 4c: 127-frame scroll + brightness fade
    DEC $cameraTargetY
    DEC $00CC
    LDA $loopCounter, X   ; Extract loopCounter bits 3-6 for brightness ramp
    AND #$0078            ; AND $0078: isolate bits 3-6
    LSR                   ; LSR ×3: shift to bits 0-3 → INIDISP brightness 0-15
    LSR 
    LSR 
    SEP #$20              ; Switch to 8-bit for INIDISP write
    STA $INIDISP          ; Write brightness — fades from $0F (full) to $00 (black) over 127 frames
    REP #$20
    COP [LoopNext]
    COP [QueueMapChange] ( #BF, #$00F8, #$00C0, #00, #$2200 ) ; Phase 5: QueueMapChange to scene $BF at ($00F8,$00C0), params ($00, $2200)
    LDA #$0001            ; gfxCacheIdxA = $0001 (instant transition type)
    STA $gfxCacheIdxA
    LDA #$0400            ; gfxCacheIdxB = $0400 (transition brightness speed)
    STA $gfxCacheIdxB
    COP [SetEntryContinue] ; Final yield before actor terminates
    RTL 
}