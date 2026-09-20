; Sky Garden crash landing cutscene — the garden falls from the sky.
; 
; Major cutscene (~258 lines) that plays when the Sky Garden
; descends after defeating all four Crystal Birds. Manages
; the dramatic crash sequence with screen shake, Mode 7-style
; effects, palette fades, and the party's escape. Transitions
; to the garden_descent scene.
---------------------------------------------

?INCLUDE 'mode7_perspective'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!M7SEL                          211A
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!animScratch2                   7F000E
!moveScratch2                   7F002E

---------------------------------------------

; Sky Garden crash cutscene actor-def — Mode 7 init, companion spawning, and animation loop.
; 
; Init phase:
; 1. Mask joypad ($FFF0) to disable UI buttons during cutscene
; 2. Configure Mode 7 color math: M7SEL=0, TS=$01, CGADSUB=$01, CGWSEL=$82
; 3. SpawnThinker Mode7PerspectiveUpdate for per-scanline rotation HDMA
; 4. Write $0804 to thinker's animScratch2 (rotation/scale speed params)
; 5. SpawnBefore CrashCameraController as companion (runs before this actor each frame)
; 6. Position sprite at cameraTargetX + $80, stage sprite config #04
; 
; Main loop (loc_03A0E7): two-yield cycle per iteration. First yield: animate one frame, copy animation result ($08) to timer ($24), clear $08. Second yield: position at cameraTargetY + $B4. Check flag byte #01 — when set by CrashCameraController, branch to GardenCrashExitPhase. Otherwise decrement $24; if negative, loop back. If non-negative, return (wait for next frame).

GardenCrashCutscene [
  actor-def < #00, #00, #18, {

  code_03A0AD:
    LDA #$FFF0            ; Mask joypad $FFF0 — disable Start/Select/Y/B during crash cutscene
    TSB $joypadMaskStd
    SEP #$20              ; Switch to 8-bit A for PPU register writes
    STZ $M7SEL            ; M7SEL = $00: no Mode 7 flip
    LDA #$01              ; TS = $01: BG1 on main screen
    STA $TS
    STA $CGADSUB          ; CGADSUB = $01: color math addition on BG1
    LDA #$82              ; CGWSEL = $82: sub screen = fixed color, math on BG & OBJ always
    STA $CGWSEL
    REP #$20
    COP [SpawnThinker] ( @mode7_perspective.Mode7PerspectiveUpdate ) ; Spawn Mode7PerspectiveUpdate thinker for per-scanline rotation HDMA
    PHX 
    TYX                   ; Switch to thinker's actor slot (Y = spawned thinker index)
    LDA #$0804            ; $0804 → thinker params: $08 = rotation speed, $04 = scale step
    STA $animScratch2, X
    PLX 
    COP [SpawnBefore] ( @CrashCameraController ) ; Spawn CrashCameraController as companion (runs before main actor)
    LDA $cameraTargetX    ; Center sprite at cameraTargetX + $80
    CLC 
    ADC #$0080
    STA $14
    COP [StageSprAndHitbox] ( #04 ) ; Stage sprite/hitbox config #04

  loc_03A0E7:
    COP [SetEntryHere]    ; Main loop: yield, animate, track camera
    COP [AnimOneFrame]
    LDA $08               ; Copy animation result to timer $24
    STA $24
    STZ $08
    COP [SetEntryHere]    ; Second yield per cycle
    LDA $cameraTargetY    ; Position sprite at cameraTargetY + $B4 (vertical offset from camera center)
    CLC 
    ADC #$00B4
    STA $16
    COP [BranchOnFlagByte] ( #01, #01, &GardenCrashExitPhase ) ; Check flag byte #01 — set by CrashCameraController when approach phase ends
    DEC $24               ; Decrement animation timer
    BMI loc_03A107        ; Timer negative → loop back to main loop
    RTL 

  loc_03A107:
    BRA loc_03A0E7
} >
]

---------------------------------------------
; Terminal animation phase — 30-frame fadeout after camera signals completion.
; 
; Entered when CrashCameraController sets flag byte #01 (approach + gravity phases complete). SetEntryExit marks this as a terminal state. Loops 30 frames ($1E): each frame animates one step and positions at cameraTargetY + $B4, tracking the still-scrolling camera. After the loop, one final yield + RTL ends the actor.

GardenCrashExitPhase {
    COP [SetEntryHereAndYield] ; Exit phase: SetEntryExit marks terminal state
    COP [LoopStart] ( #1E ) ; Loop 30 frames for fadeout animation
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $cameraTargetY    ; Track camera Y + $B4 each frame during exit
    CLC 
    ADC #$00B4
    STA $16
    COP [LoopEnd]         ; LoopNext: decrement and branch back for remaining frames
    COP [SetEntryHere]    ; Final yield after loop, then RTL ends actor
    RTL 
}

---------------------------------------------
; Companion thinker driving camera scroll, gravity acceleration, and scene transition.
; 
; Three-phase thinker spawned via SpawnBefore, running before the main crash actor each frame.
; 
; Phase 1 — Approach (600 frames):
; - Set render flag $0800 in actor flags ($10)
; - Timer = $0258 (600 frames)
; - Mode 7 center X = cameraTargetX + $80 → $00CA
; - Rotation angle = $0200 → $00B6, scale = $0032 → $00B8, perspective = 0 → $00BC
; - Per-frame: scroll cameraTargetY up by 2, compute Y center = (cameraTargetY & $03FF) + $70 → $00CC
; - Decrement timer; continue until timer < 0
; 
; Phase 2 — Signal + scroll (60 frames):
; - SetFlagByte #01 (tells main actor to enter exit phase)
; - Loop 60 more frames of continued camera scroll
; - SpawnAfterFlags CrashDebrisSfx with $2000 flags
; 
; Phase 3 — Gravity:
; - InitGravity(0, 5, 0): vertical gravity at speed 5
; - TickGravity loop: add velocity (moveScratch2) to Mode 7 scale ($00B8)
; - Continue camera scroll each frame
; - When scale ≥ $0500 (loc_03A1AF): trigger scene transition
;   - Set game flag $0AA6 = 1 (marks garden crash in game state)
;   - Set gfxCacheIdxB = $0404 (post-crash graphics)
;   - QueueMapChange to scene $58 with params ($0000, $0000, $80, $1100)
;   - Continue gravity + camera scroll for smooth visual exit

CrashCameraController {
    LDA #$0800            ; Camera controller init: set render flag $0800
    TSB $10
    LDA #$0258            ; Timer = $0258 (600 frames) for approach phase
    STA $24
    LDA $cameraTargetX    ; Mode 7 center X = cameraTargetX + $80
    CLC 
    ADC #$0080
    STA $00CA             ; Store center X → $00CA (Mode 7 scroll center X)
    LDA #$0200            ; Rotation angle $0200 → $00B6 (initial perspective rotation)
    STA $00B6
    LDA #$0032            ; Scale $0032 (50) → $00B8 (initial Mode 7 zoom level)
    STA $00B8
    STZ $00BC             ; Perspective angle 0 → $00BC
    COP [SetEntryHere]
    LDA $cameraTargetY    ; Per-frame: scroll camera up by 2 pixels
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF            ; Mask to 10-bit rotation range ($03FF)
    CLC 
    ADC #$0070            ; Add $70 offset for Mode 7 Y center
    STA $00CC             ; Store computed Y center → $00CC
    DEC $24               ; Decrement approach timer
    BMI loc_03A15E        ; Timer negative → approach phase complete, enter signal phase
    RTL 

  loc_03A15E:
    COP [SetFlagByte] ( #01 ) ; Signal main actor: SetFlagByte #01 (triggers exit phase)
    COP [LoopStart] ( #3C ) ; Loop 60 more frames ($3C) of continued camera scroll
    LDA $cameraTargetY    ; Continue scrolling camera up by 2px/frame during signal phase
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    COP [LoopEnd]         ; LoopNext: 60-frame extended scroll
    COP [SpawnAfterFlags] ( @CrashDebrisSfx, #$2000 ) ; Spawn CrashDebrisSfx with flags $2000
    COP [InitGravity] ( #00, #05, #00 ) ; InitGravity(0, 5, 0): start vertical gravity at speed 5
    COP [SetEntryHere]
    COP [TickGravity]     ; Gravity loop: TickGravity updates velocity
    LDA $moveScratch2, X  ; Read gravity velocity from moveScratch2
    CLC 
    ADC $00B8             ; Add velocity to Mode 7 scale ($00B8) — garden appears to rush closer
    STA $00B8
    CMP #$0500            ; Scale ≥ $0500? Impact threshold reached
    BCS loc_03A1AF        ; BCS → scene transition at loc_03A1AF
    LDA $cameraTargetY    ; Continue camera scroll during gravity
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 

  loc_03A1AF:
    LDA #$0001            ; Set game flag $0AA6 = 1 (garden crash occurred in game state)
    STA $0AA6
    LDA #$0404            ; Post-crash graphics cache: $0404 → gfxCacheIdxB
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #80, #$1100 ) ; QueueMapChange to scene $58 (post-crash map), params ($0000, $0000, $80, $1100)
    COP [SetEntryHere]
    COP [TickGravity]     ; Post-transition: continue gravity + camera scroll for smooth exit
    LDA $moveScratch2, X  ; Add gravity velocity to scale (continues increasing)
    CLC 
    ADC $00B8
    STA $00B8
    LDA $cameraTargetY    ; Continue camera scroll after scene change queued
    SEC 
    SBC #$0002
    STA $cameraTargetY
    AND #$03FF
    CLC 
    ADC #$0070
    STA $00CC
    RTL 
}

---------------------------------------------
; Crash debris sound effect actor — 6 random sound bursts.
; 
; Spawned via SpawnAfterFlags with $2000 flags during the gravity phase. Loops 6 times: each iteration generates a random byte, masks to $1C (values 0/4/8/12/16/20/24/28) and stores to $08 as an animation/frame offset, then plays sound #15 (crash/impact). Dies after all 6 iterations.

CrashDebrisSfx {
    COP [LoopStart] ( #06 ) ; Debris SFX: loop 6 times
    COP [RngByte]         ; Random byte for animation variety
    AND #$001C            ; Mask to $1C (values 0/4/8/12/16/20/24/28)
    STA $08               ; Store random offset → $08 (animation frame variant)
    COP [PlaySoundCh1] ( #15 ) ; Play crash sound #15
    COP [LoopEnd]         ; Loop back for remaining sound bursts
    COP [Die]             ; Die after 6 iterations
}