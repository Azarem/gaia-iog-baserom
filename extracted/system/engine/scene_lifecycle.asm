; Scene lifecycle management — transitions, state initialization, and resource loading (252392–254128, Bank 03).
; 
; Contains the complete scene transition pipeline: detecting pending transitions, executing visual exit/enter effects, clearing state, loading scene resources (HUD, palettes, player graphics, camera bounds), and spawning actors.
; 
; === TRANSITION PIPELINE ===
; 
; CheckSceneTransition → ExecuteSceneTransition orchestrates the full scene change:
; 1. Run ScreenExitTransition (if world is active)
; 2. Disable NMI, clear world-ready flag
; 3. Resolve target scene from $0D52 (special) or sceneNext (normal)
; 4. ClearSceneState: comprehensive reset of all game variables, followed by scene script execution, camera init, event blocks, actor spawning, collision setup, palette/graphics loading, and initial tilemap rendering
; 5. Run ScreenEnterTransition
; 6. Optional: wait for player input (press-start screens via $00B4)
; 
; === VISUAL TRANSITIONS ===
; 
; ScreenExitTransition and ScreenEnterTransition each support 4–5 transition effect types selected by gfxCacheIdxA ($0648) and $0649 respectively:
; - Type 0: Graduated brightness fade (speed controlled by gfxCacheIdxB / $064B)
; - Type 1: Instant blank/display
; - Type 2: Mosaic dissolve with brightness fade
; - Type 3: Sine-wave HDMA scroll distortion with brightness fade
; - Type 4 (exit only): Alternative wave pattern (ScreenExitTransition_WaveAlt)
; 
; Wave transitions use ApplyScrollWaveEffect and ComputeSineScrollTable to build per-scanline horizontal scroll offsets via hardware multiply, driving HDMA channels 6 and 7.
; 
; === SCENE RESOURCE LOADING (ClearSceneState) ===
; 
; ClearSceneState is the ‘big setup’ function that calls into multiple engine subsystems to prepare a new scene:
; - SceneScriptMain: parse scene definition (tileset, tilemap, music, display config)
; - InitCameraBounds: set camera limits from map geometry or custom packed bounds
; - ApplyAllEventBlocks: apply persistent tile modifications from event flags
; - PlaceBarrierTiles: place barrier collision tiles
; - Actor/thinker spawning and initialization via actor_execution
; - LoadScenePalettes / LoadPlayerGraphics: character/form-dependent resource loading
; - CameraFullRefresh or RenderPaletteTiles: initial tilemap rendering depending on scroll mode
---------------------------------------------

?BANK 03

?INCLUDE 'actor_execution'
?INCLUDE 'camera_tilemap'
?INCLUDE 'DisplaySceneTitle'
?INCLUDE 'DmaWordToVram'
?INCLUDE 'event_blocks'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'math_lookup_tables'
?INCLUDE 'scene_script'
?INCLUDE 'sprite_composition'
?INCLUDE 'system_core'
?INCLUDE 'thinker_execution'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'
?INCLUDE 'warps_interaction'

!extVelocityX                   0408
!extVelocityY                   040A
!invincibilityTimer             040C
!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRaw                      0660
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!mapBoundsX                     0692
!mapBoundsY                     0696
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!cameraLowerYBound              06DE
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!scrollModeFlags                06EF
!musicRoomGroup                 06F6
!dmaSkipFlag                    0800
!joypadInject                   09AC
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!climbStateData                 09E0
!displayModeFlags               09EC
!eventFlags                     0A00
!cachedPrevMaxHp                0ACC
!cachedPrevHp                   0AD0
!enemyHealthTimer               0AE4
!activeActorCount               0DBC
!INIDISP                        2100
!MOSAIC                         2106
!BG3SC                          2109
!BG12NBA                        210B
!BG3HOFS                        2111
!BG3VOFS                        2112
!VMADDL                         2116
!W12SEL                         2123
!W34SEL                         2124
!WOBJSEL                        2125
!WH0                            2126
!WH1                            2127
!WH2                            2128
!WH3                            2129
!WBGLOG                         212A
!WOBJLOG                        212B
!COLDATA                        2132
!HDMAEN                         420C
!RDMPYL                         4216
!RDMPYH                         4217
!sineTableA                     7E8900
!sineTableB                     7E8B00
!backdropColors                 7F0C00
!oamComposeBuffer               7F3100
!L_WRMPYA                       804202
!L_WRMPYB                       804203

---------------------------------------------

; Quick test for pending scene transitions.
; 
; Checks two trigger sources:
; 1. Special transition registers $0D52/$0D53 (nonzero = special transition pending)
; 2. sceneNext ($0642, nonzero = normal scene change pending)
; 
; If either is nonzero, falls through to ExecuteSceneTransition. Otherwise returns immediately via RTL. Called every frame from the main game loop.

CheckSceneTransition {
    LDA $0D52             ; Check $0D52/$0D53 — special transition pending?
    ORA $0D53
    BNE ExecuteSceneTransition ; Special transition → ExecuteSceneTransition
    LDA $sceneNext        ; Check sceneNext ($0642) — normal transition?
    BNE ExecuteSceneTransition
    RTL                   ; No transition queued — return to main loop
}

---------------------------------------------
; Main scene transition orchestrator — handles the full scene change sequence.
; 
; Three-phase operation:
; 
; === PHASE 1: EXIT ===
; If worldReadyFlag is positive (world active and visible): runs ScreenExitTransition for the visual fade/dissolve effect. Then clears worldReadyFlag to 0. If worldReadyFlag is negative (bit 7 set), skips the exit transition entirely (used for initial boot or forced transitions). Disables NMI, enables display.
; 
; === PHASE 2: RESOLVE TARGET SCENE ===
; Two paths:
; - $0D52 nonzero (special transition): Saves $0D52 → $0D54, $0652 → $0D6C, clears both. Records the source scene in $0D6E and current scene in $0D6F. Sets scene ID to $FE (special marker).
; - sceneNext nonzero (normal transition): Records source scene in $0D6E, clears $0D6F. Uses sceneNext as the new scene ID.
; 
; Stores the resolved scene to sceneCurrent and computes the doubled scene index ($0646) for table lookups.
; 
; === PHASE 3: LOAD ===
; Calls ClearSceneState (the comprehensive scene setup), LoadHudTilemap, UpdateHUD, and a chain of VBlank sync/NMI enable calls. Sets worldReadyFlag to $0F0F (fully ready). Clears graphics cache indices.
; 
; If $00B4 is nonzero (press-start flag): enters a wait loop calling UpdateFrameDialogue until any button is pressed, then clears the flag, flushes the VRAM buffer, and enables display mode bit 0.
; 
; Finally clears joypadInject and $09AD before returning.

ExecuteSceneTransition {
    LDA $worldReadyFlag   ; Check worldReadyFlag for transition mode
    BMI loc_03DA03        ; Negative → skip exit transition (boot/forced path)
    BEQ loc_03DA00        ; Zero → no exit transition needed
    JSR $&ScreenExitTransition ; World active — run visual exit transition

  loc_03DA00:
    STZ $worldReadyFlag   ; Clear worldReadyFlag

  loc_03DA03:
    STZ $66
    JSL $@vblank_joypad.EnableNmiOnly ; Enable NMI-only, then enable display
    JSL $@vblank_joypad.EnterForcedBlank
    LDA #$00
    XBA 
    LDA $0D52             ; Check $0D52/$0D53 — special vs normal transition path
    ORA $0D53
    BEQ loc_03DA41
    REP #$20              ; Special: archive $0D52→$0D54, $0652→$0D6C, clear sources
    LDA $0D52
    STA $0D54
    STZ $0D52
    LDA $0652
    STA $0D6C
    STZ $0652
    LDA #$0000
    SEP #$20
    LDA $sceneNext        ; Record source scene in $0D6E, current in $0D6F
    STA $0D6E
    LDA $sceneCurrent
    STA $0D6F
    LDA #$FE              ; Special scene marker = $FE
    BRA loc_03DA4D

  loc_03DA41:
    LDA $sceneCurrent     ; Normal: record sceneCurrent → $0D6E
    STA $0D6E
    STZ $0D6F
    LDA $sceneNext        ; Load target from sceneNext

  loc_03DA4D:
    STZ $sceneNext        ; Clear sceneNext, commit to sceneCurrent
    STA $sceneCurrent
    REP #$20
    ASL                   ; Double scene ID → $0646 for table lookups
    STA $0646
    SEP #$20
    JSL $@ClearSceneState ; ClearSceneState — full world teardown and rebuild
    JSL $@LoadHudTilemap
    JSL $@system_core.UpdateHUD ; UpdateHUD for new scene
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.ScreenBlackout ; Force blank before enter transition
    LDA $worldReadyFlag   ; Check if world was previously ready
    BNE loc_03DA81
    JSR $&ScreenEnterTransition ; Run enter transition, set worldReadyFlag=$0F0F
    LDX #$000F
    STX $worldReadyFlag

  loc_03DA81:
    LDX #$0000            ; Clear gfxCacheIdxA/B
    STX $gfxCacheIdxB
    STX $gfxCacheIdxA
    LDA $00B4             ; Check press-start wait flag ($00B4)
    BEQ loc_03DAB4

  loc_03DA8F:
    JSL $@system_core.UpdateFrameDialogue ; Wait loop: poll all joypad inputs for any button
    LDA $joypadCurrent
    ORA $0657
    ORA $joypadRaw
    ORA $0661
    BEQ loc_03DA8F
    STZ $00B4             ; Button pressed — clear wait, flush VRAM, enable display
    STZ $00B5
    JSL $@vram_buffer_clear.ClearVramBufferPartial
    LDA #$01
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue

  loc_03DAB4:
    STZ $joypadInject     ; Clear joypadInject and $09AD
    STZ $09AD
    RTL 
}

---------------------------------------------
; Visual exit transition effect dispatcher — selects from 5 effect types.
; 
; Dispatches based on gfxCacheIdxA ($0648):
; 
; - Type 0 (Graduated fade): Brightness ramps from $0F down to 0 over multiple frames. gfxCacheIdxB ($064A) controls the frame delay between brightness steps — higher values produce a slower fade. Each step writes the current brightness to INIDISP.
; 
; - Type 1 (Instant blank): Single call to UpdateFrameDialogue, then sets INIDISP to 0. Fastest transition.
; 
; - Type 2 (Mosaic dissolve): Brightness ramps down from $0F to 0 while MOSAIC register increases (pixel size grows). The mosaic value is computed as (15 − brightness) << 4 | 3, creating a dissolve effect as the screen fades.
; 
; - Type 3 (Wave scroll): Initializes the HDMA sine wave system ($0070 = wave frequency 6, $006E = wave phase 0 if not already running). Computes a wave amplitude from gfxCacheIdxB (clamped to 8 max). Two nested loops: inner loop advances the wave phase via ApplyScrollWaveEffect, outer loop decrements brightness from $0F to 0, producing a sine-wave screen distortion that increases as the screen fades out.
; 
; - Type 4 (Wave alternate): Jumps to ScreenExitTransition_WaveAlt for a variant wave pattern.
; 
; All types (except instant) call UpdateFrameDialogue each frame to keep audio and display sync running during the transition.

ScreenExitTransition {
    LDA $gfxCacheIdxA     ; Dispatch on gfxCacheIdxA: 0=fade, 1=instant, 2=mosaic, 3=wave, 4=waveAlt
    BEQ loc_03DAD0
    DEC 
    BEQ loc_03DAF2
    DEC 
    BEQ loc_03DAFA
    DEC 
    BEQ loc_03DB20
    DEC 
    BNE loc_03DACF
    JMP $&ScreenExitTransition_WaveAlt ; Type 4 → JMP ScreenExitTransition_WaveAlt

  loc_03DACF:
    RTS 

  loc_03DAD0:
    LDA #$0F              ; Type 0: brightness $0F → 0
    STA $0DB6

  loc_03DAD5:
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB     ; gfxCacheIdxB = frame delay between brightness steps
    TAX 

  loc_03DADC:
    JSL $@system_core.UpdateFrameDialogue ; Inner loop: UpdateFrameDialogue, wait delay frames
    LDA $0DB6
    BEQ loc_03DAF1
    DEX 
    BPL loc_03DADC
    STA $INIDISP          ; Write brightness to INIDISP, decrement
    DEC 
    STA $0DB6
    BPL loc_03DAD5

  loc_03DAF1:
    RTS 

  loc_03DAF2:
    JSL $@system_core.UpdateFrameDialogue ; Type 1: one frame sync, INIDISP=0 (instant blank)
    STZ $INIDISP
    RTS 

  loc_03DAFA:
    LDA #$0F              ; Type 2: brightness $0F → 0 with mosaic dissolve

  loc_03DAFC:
    PHA 
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB
    TAX 
    PLA 

  loc_03DB05:
    JSL $@system_core.UpdateFrameDialogue
    DEX 
    BPL loc_03DB05
    STA $INIDISP          ; Write INIDISP, compute MOSAIC = (15−bright)<<4 | 3
    PHA 
    EOR #$0F
    ASL 
    ASL 
    ASL 
    ASL 
    ORA #$03
    STA $MOSAIC
    PLA 
    DEC 
    BPL loc_03DAFC
    RTS 

  loc_03DB20:
    PHA                   ; Type 3: init wave system ($0070=6 freq, $006E=0 phase)
    PHA 
    LDA $0070
    BNE loc_03DB2F
    LDA #$06
    STA $0070
    STZ $006E

  loc_03DB2F:
    LDA $gfxCacheIdxB     ; Clamp gfxCacheIdxB to max 8 for amplitude
    CMP #$08
    BCC loc_03DB3B
    LDA #$08
    STA $gfxCacheIdxB

  loc_03DB3B:
    ASL                   ; Compute wave iteration count from clamped amplitude
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$80
    EOR #$FF
    INC 
    STA $01, S

  loc_03DB47:
    LDA $006E             ; Inner loop: advance phase, ResetHdma, ApplyScrollWaveEffect
    INC 
    STA $006E
    STA $00
    LDA $01, S
    DEC 
    STA $01, S
    BMI loc_03DB66
    PHA 
    JSL $@hdma_dma_spc.ResetHdmaState
    LDA #$FF
    STA $6C
    PLA 
    JSR $&ApplyScrollWaveEffect
    BRA loc_03DB47

  loc_03DB66:
    LDA #$0F              ; Wind-down: brightness $0F → 0 with wave per frame
    STA $01, S

  loc_03DB6A:
    LDA $gfxCacheIdxB
    STA $02, S

  loc_03DB6F:
    LDA $006E             ; Each frame: ResetHdma, apply wave, advance phase
    STA $00
    PHA 
    JSL $@hdma_dma_spc.ResetHdmaState
    LDA #$FF
    STA $6C
    PLA 
    JSR $&ApplyScrollWaveEffect
    INC 
    STA $006E
    LDA $02, S
    DEC 
    STA $02, S
    BNE loc_03DB6F
    LDA $01, S            ; Decrement brightness, write INIDISP
    DEC 
    STA $01, S
    STA $INIDISP
    BNE loc_03DB6A
    LDA #$00              ; Final INIDISP=0, clear wave state
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

---------------------------------------------
; Alternative wave exit transition — variant loop structure.
; 
; Similar to type 3 but with a different nesting pattern: the wave iteration count per brightness level is controlled by gfxCacheIdxB directly (rather than being computed from it). Brightness starts at $0F and decrements each outer iteration. Each inner iteration advances the wave phase and calls UpdateFrameDialogue for frame sync.
; 
; Initializes the HDMA sine wave system ($0070/$006E) if not already running. Clears both on completion.

ScreenExitTransition_WaveAlt {
    PHA 
    PHA 
    LDA $0070             ; Init wave system if not running ($0070=6, $006E=0)
    BNE loc_03DBB3
    LDA #$06
    STA $0070
    STZ $006E

  loc_03DBB3:
    LDA $gfxCacheIdxB     ; gfxCacheIdxB → inner count, $0F → brightness
    STA $01, S
    LDA #$0F
    STA $02, S

  loc_03DBBC:
    INC $006E             ; Each iteration: advance phase, ResetHdma, apply wave, UpdateFrameDialogue
    STA $00
    PHA 
    JSL $@hdma_dma_spc.ResetHdmaState
    LDA #$FF
    STA $6C
    PLA 
    JSR $&ApplyScrollWaveEffect
    JSL $@system_core.UpdateFrameDialogue
    LDA $01, S            ; Decrement inner count; when exhausted, reload and decrement brightness
    DEC 
    STA $01, S
    BNE loc_03DBBC
    LDA $gfxCacheIdxB
    STA $01, S
    LDA $02, S
    DEC 
    STA $02, S
    STA $INIDISP          ; Write brightness to INIDISP, loop until 0
    BNE loc_03DBBC
    LDA #$00
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070             ; Clear wave state ($0070, $006E)
    STZ $006E
    RTS 
}

---------------------------------------------
; Apply one frame of sine-wave scroll distortion via HDMA.
; 
; Calls ComputeSineScrollTable to fill the per-scanline scroll offset tables at $7E8900 (sineTableA) and $7E8B00 (sineTableB). Then configures HDMA indirect mode table at $7E8800:
; - $7E8800: $FF (256 scanlines, transfer count)
; - $7E8801: pointer to sineTableA (computed from wave phase $36)
; - $7E8803: $E0 (scanline count for second segment)
; - $7E8804: pointer to sineTableB (sineTableA + $FE)
; - $7E8806: $00 (end marker)
; 
; Queues HDMA channels 6 and 7 via COP [QueueHdmaChannel] targeting BG1/BG2 horizontal scroll registers ($0D/$0F in register $7E). Then calls UpdateFrameDialogue for one frame of display sync.

ApplyScrollWaveEffect {
    PHA                   ; Save A, build sine tables, configure HDMA indirect table
    JSR $&ComputeSineScrollTable
    REP #$20
    LDA $36               ; Wave phase from DP $36, masked to word boundary
    AND #$01FE
    CLC 
    ADC #$8900            ; sineTableA pointer = $8900 + (phase & $01FE)
    STA $7E8801
    CLC 
    ADC #$00FE            ; sineTableB pointer = sineTableA + $FE
    STA $7E8804
    SEP #$20
    LDA #$FF              ; HDMA table: $FF scanlines, $E0 scanlines, $00 end
    STA $7E8800
    LDA #$E0
    STA $7E8803
    LDA #$00
    STA $7E8806
    COP [QueueHdmaChannel] ( #06, #$8800, #$0D7E ) ; Queue HDMA ch6 → BG1 H-scroll, ch7 → BG2 H-scroll
    COP [QueueHdmaChannel] ( #07, #$8800, #$0F7E )
    JSL $@system_core.UpdateFrameDialogue ; UpdateFrameDialogue — one frame sync
    PLA 
    RTS 
}

---------------------------------------------
; Build per-scanline horizontal scroll offset tables for HDMA wave effect.
; 
; For each of 256 scanlines ($0200 bytes, 128 entries per table):
; 1. Reads a signed sine value from the lookup table at binary_01C455, indexed by the current phase (Y)
; 2. Multiplies the sine value by the wave amplitude ($006E) using the SNES hardware multiplier ($4202/$4203 → $4216/$4217)
; 3. For negative sine values: performs sign-extended multiplication using $FF multiply + carry-based addition of the low byte
; 4. Adds the base BG1 horizontal scroll ($bg1ScrollH) to the offset
; 5. Stores the result to both sineTableA ($7E8900,X) and sineTableB ($7E8B00,X)
; 6. Advances the phase by the wave frequency ($0070) per scanline
; 
; If $00 (amplitude parameter from caller) is zero, returns immediately without filling the tables.
; 
; The phase accumulation ($006E += $0070 per scanline) controls the spatial frequency of the wave. The $006E parameter from the caller controls the amplitude. Together they produce the characteristic 'wavy screen' effect seen during scene transitions.

ComputeSineScrollTable {
    PHP                   ; SEP #$20, zero X (table index) and Y (phase index)
    SEP #$20
    LDX #$0000
    TXY 
    LDA $00               ; Check amplitude ($00) — zero = skip table fill
    BEQ loc_03DC90
    LDA $006E             ; Write wave phase to hardware multiplier WRMPYA ($4202)
    STA $L_WRMPYA
    CLC 

  loc_03DC4C:
    LDA $&math_lookup_tables.sine_table_8bit, Y ; Load signed sine sample from lookup table
    BPL loc_03DC52
    SEC                   ; Negative sine → set carry for sign-extend path

  loc_03DC52:
    STA $L_WRMPYB         ; Write to WRMPYB ($4203) — 4 NOP wait for multiply
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH           ; Read RDMPYH result
    BCC loc_03DC70
    PHA                   ; Negative: sign-extend via $FF multiply + RDMPYL
    LDA #$FF
    STA $L_WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $RDMPYL
    REP #$20
    BRA loc_03DC75

  loc_03DC70:
    REP #$20              ; Positive: mask result to low byte
    AND #$00FF

  loc_03DC75:
    CLC 
    ADC $bg1ScrollH       ; Add base BG1 horizontal scroll ($068A)
    STA $sineTableA, X    ; Store offset to sineTableA and sineTableB
    STA $sineTableB, X
    TYA 
    SEP #$20
    CLC 
    ADC $0070             ; Advance phase by frequency $0070, loop 256 scanlines
    TAY 
    INX 
    INX 
    CPX #$0200
    BNE loc_03DC4C

  loc_03DC90:
    PLP 
    RTS 
}

---------------------------------------------
; Visual enter transition effect dispatcher — selects from 4 effect types.
; 
; Dispatches based on $0649:
; 
; - Type 0 (Graduated fade-in): Brightness ramps from 1 up to $0F. $064B controls the frame delay between steps (same role as gfxCacheIdxB in exit transitions). Each step writes to INIDISP and increments until reaching full brightness ($10 comparison catches the >= $0F case).
; 
; - Type 1 (Instant display): Single UpdateFrameDialogue, then sets INIDISP to $0F. Fastest enter.
; 
; - Type 2 (Mosaic dissolve-in): Brightness ramps from 0 up to $0F while MOSAIC register decreases (pixel size shrinks from maximum to 1:1). Computed as (15 − brightness) << 4 | 3. The reverse of exit type 2 — large mosaic pixels dissolve into the sharp final image.
; 
; - Type 3 (Wave scroll enter): Initializes HDMA sine wave with phase $80 ($006E) and frequency 6 ($0070). The wave phase is decremented each inner iteration (BEQ exits when phase reaches 0), causing the wave amplitude to shrink over time. Brightness ramps up as the wave settles, clamped at $0F. After the wave phase reaches 0, a wind-down loop steps brightness up to $0F with $064B-frame delays between steps.
; 
; All types call UpdateFrameDialogue per frame for audio/display sync.

ScreenEnterTransition {
    LDA $0649             ; Dispatch on $0649: 0=fade, 1=instant, 2=mosaic, 3=wave
    BEQ loc_03DCA1
    DEC 
    BEQ loc_03DCC5
    DEC 
    BEQ loc_03DCCF
    DEC 
    BEQ loc_03DCF7
    RTS 

  loc_03DCA1:
    LDA #$01              ; Type 0: brightness 1 → $0F
    STA $0DB6

  loc_03DCA6:
    LDA #$00
    XBA 
    LDA $064B             ; $064B = frame delay between steps
    TAX 

  loc_03DCAD:
    JSL $@system_core.UpdateFrameDialogue ; Inner loop: UpdateFrameDialogue, wait delay frames
    LDA $0DB6
    BEQ loc_03DCC4
    DEX 
    BPL loc_03DCAD
    STA $INIDISP          ; Write INIDISP, increment brightness
    INC 
    STA $0DB6
    CMP #$10              ; Exit at brightness $10 (past full)
    BCC loc_03DCA6

  loc_03DCC4:
    RTS 

  loc_03DCC5:
    JSL $@system_core.UpdateFrameDialogue ; Type 1: one frame sync, INIDISP=$0F (instant on)
    LDA #$0F
    STA $INIDISP
    RTS 

  loc_03DCCF:
    LDA #$00              ; Type 2: brightness 0 → $0F with shrinking mosaic

  loc_03DCD1:
    PHA 
    LDA #$00
    XBA 
    LDA $064B
    TAX 
    PLA 

  loc_03DCDA:
    JSL $@system_core.UpdateFrameDialogue
    DEX 
    BPL loc_03DCDA
    STA $INIDISP          ; Write INIDISP, compute MOSAIC = (15−bright)<<4 | 3
    PHA 
    EOR #$0F
    ASL 
    ASL 
    ASL 
    ASL 
    ORA #$03
    STA $MOSAIC
    PLA 
    INC 
    CMP #$10              ; Exit at brightness $10
    BCC loc_03DCD1
    RTS 

  loc_03DCF7:
    LDA $0070             ; Type 3: init wave ($0070=6, $006E=$80 max amplitude)
    BNE loc_03DD06
    LDA #$06
    STA $0070
    LDA #$80
    STA $006E

  loc_03DD06:
    LDA #$00              ; Push brightness=0 on stack
    PHA 

  loc_03DD09:
    LDA $064B             ; Load frame delay from $064B

  loc_03DD0C:
    DEC $006E             ; Decrement wave phase $006E — amplitude shrinks toward 0
    BEQ loc_03DD36        ; Phase=0 → exit to wind-down
    STA $00
    PHA 
    JSL $@hdma_dma_spc.ResetHdmaState
    LDA #$FF
    STA $6C
    PLA 
    JSR $&ApplyScrollWaveEffect ; Inner: ResetHdma, apply wave, decrement delay
    DEC 
    BNE loc_03DD0C
    LDA $01, S            ; Increment brightness, clamp to $0F
    INC 
    CMP #$0F
    BCC loc_03DD2C
    LDA #$0F

  loc_03DD2C:
    STA $INIDISP          ; Write INIDISP, save brightness, loop
    STA $01, S
    BRA loc_03DD09

  loc_03DD33:
    LDA $064B

  loc_03DD36:
    JSL $@system_core.UpdateFrameDialogue ; Wind-down: UpdateFrameDialogue with delay frames
    DEC 
    BNE loc_03DD36
    LDA $01, S            ; Step brightness toward $0F until full
    CMP #$0F
    BEQ loc_03DD4B
    INC 
    STA $INIDISP
    STA $01, S
    BRA loc_03DD33

  loc_03DD4B:
    STA $INIDISP          ; Final INIDISP=$0F, clear wave state
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

---------------------------------------------
; Comprehensive scene state reset and initialization — the 'big setup' function.
; 
; Called by ExecuteSceneTransition after resolving the target scene. Performs a complete teardown and rebuild of the game world in a fixed sequence:
; 
; === PHASE 1: CLEAR STATE ===
; Disables HDMA. Zeroes all critical game variables: joypad masks, cached HP, display mode, player flags, event flags, camera targets/deltas, scroll positions/overrides, player speeds, external velocities, enemy health timer, climb state, actor count, DMA skip flag. Sets invincibility timer to $FFFF (disabled). Clears backdrop colors and COLDATA. Resets BG3 tilemap ($78), character base ($22), MOSAIC, and all window mask/logic registers.
; 
; === PHASE 2: LOAD SCENE ===
; Calls subsystems in order:
; 1. ClearVramBufferFull — flush VRAM write buffer
; 2. SceneScriptMain — parse scene script (loads tileset, tilemap, music, display config)
; 3. InitCameraBounds — set camera limits from map bounds or custom $0652 data
; 4. ApplyAllEventBlocks — apply persistent event-driven tile changes
; 5. PlaceBarrierTiles — write barrier collision tiles to map
; 6. InitActorPool — reset actor/thinker pools
; 7. SpawnSceneActors — instantiate actors from scene definition table
; 8. DisplaySceneTitle — display centered area name overlay if entering a new scene
; 9. SpawnSceneThinkers — instantiate thinkers from scene definition table
; 
; === PHASE 3: PREPARE RENDERING ===
; 10. LoadScenePalettes — load scene/character palettes
; 11. LoadPlayerGraphics — DMA player sprite tiles to VRAM
; 12. ClearActorRenderList — reset the OAM render list
; 13. InitWarpTable — set up warp zone collision rectangles
; 14. RunActors_Normal ×2 — run two frames of actor AI to settle initial positions
; 15. ResetHdmaState ×2 — clear HDMA channels (once before thinkers, once after)
; 16. RunThinkers_TypeA/B — execute both thinker phases
; 17. Set $FF sentinel in OAM buffer, sort actors, compose sprites
; 18. DmaPlayerTilesToVram — initial player tile upload
; 
; === PHASE 4: RENDER TILEMAP ===
; Two paths based on scrollModeFlags bit 3:
; - Set: Calls RenderPaletteTiles (palette-based scene, no scrolling BG)
; - Clear: Calls CameraFullRefresh for layer 0 (if $069B nonzero) and layer 1 (if $069D nonzero) to render the full visible tilemap
; 
; Finally clears musicRoomGroup, effect deltas, and related scroll variables.

ClearSceneState {
    STZ $HDMAEN           ; Disable HDMA for scene teardown
    LDX #$0000            ; Zero X — clear all scene state variables
    STX $joypadMaskInv    ; Clear joypad masks, cached HP, display/player flags
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $displayModeFlags
    STX $playerFlags
    STX $eventFlags
    STX $cameraDeltaX     ; Clear camera positions, scroll overrides, BG scroll values
    STX $cameraTargetX
    STX $cameraDeltaY
    STX $cameraTargetY
    STX $scrollOverrideH
    STX $forcedScrollOverride
    STX $scrollOverrideV
    STX $06CC
    STX $bg2ScrollH
    STX $savedCameraDelta
    STX $bg1ScrollH
    STX $bg1ScrollV
    STX $playerSpeedEw    ; Clear player speeds, external velocities, enemy timer
    STX $playerSpeedNs
    STX $extVelocityX
    STX $extVelocityY
    STX $enemyHealthTimer
    STX $0AEC
    STX $0AEE
    STX $climbStateData   ; Clear climb state, actor count, DMA flag
    STX $00DA
    STX $activeActorCount
    STX $09CC
    STX $09CE
    STX $00B2
    STX $0C07
    STX $dmaSkipFlag
    STX $00EA
    DEX                   ; X=$FFFF → invincibility timer disabled
    STX $invincibilityTimer
    LDA #$00              ; Clear backdrop colors ($7F0C00–02) to black
    STA $backdropColors
    STA $7F0C01
    STA $7F0C02
    LDA #$E0              ; COLDATA=$E0 — force black backdrop
    STA $COLDATA
    LDA #$78              ; BG3SC=$78 — tilemap at $7800, 64×32 size
    STA $BG3SC
    STZ $BG3HOFS          ; Reset BG3 H/V scroll (double-write registers)
    STZ $BG3HOFS
    STZ $BG3VOFS
    STZ $BG3VOFS
    LDA $0A1F             ; Clear bit 7 of scene status $0A1F
    AND #$7F
    STA $0A1F
    LDA #$01
    STA $enemyHealthTimer ; Enemy health timer = 1 (minimum display)
    LDA #$22              ; BG12NBA=$22 — char bases $0000/$2000
    STA $BG12NBA
    STZ $MOSAIC           ; Clear MOSAIC, all window masks/logic/boundaries
    STZ $W12SEL
    STZ $W34SEL
    STZ $WOBJSEL
    STZ $WBGLOG
    STZ $WOBJLOG
    STZ $WH0
    STZ $WH2
    STZ $WH3
    LDA #$FF
    STA $WH1              ; Window 1 right = $FF (full width)
    LDA #$E0
    STA $COLDATA          ; Re-apply COLDATA=$E0 after window setup
    JSL $@vram_buffer_clear.ClearVramBufferFull ; Flush VRAM buffer, parse scene script
    JSL $@scene_script.SceneScriptMain
    JSL $@InitCameraBounds ; Init camera bounds, apply event blocks, place barriers
    JSL $@event_blocks.ApplyAllEventBlocks
    JSL $@warps_interaction.PlaceBarrierTiles
    LDX #$0000            ; Clear joypad state before actor spawning
    STX $joypadMaskStd
    STX $joypadCurrent
    STX $joypadRaw
    JSL $@actor_execution.InitActorPool ; Init actor pool, spawn actors, display scene title, spawn thinkers
    JSL $@actor_execution.SpawnSceneActors
    JSL $@DisplaySceneTitle
    JSL $@thinker_execution.SpawnSceneThinkers
    JSL $@LoadScenePalettes ; Load palettes, load player graphics
    JSL $@LoadPlayerGraphics
    JSL $@sprite_composition.ClearActorRenderList ; Clear render list, init warp table
    JSL $@warps_interaction.InitWarpTable
    JSL $@actor_execution.RunActors_Normal ; Two actor ticks to settle initial positions
    JSL $@actor_execution.RunActors_Normal
    JSL $@hdma_dma_spc.ResetHdmaState ; ResetHdma, run type-A and type-B thinkers, ResetHdma
    JSL $@thinker_execution.RunThinkers_TypeA
    JSL $@thinker_execution.RunThinkers_TypeB
    JSL $@hdma_dma_spc.ResetHdmaState
    STZ $HDMAEN           ; Disable HDMA before sprite composition
    COP [SetFlagByte] ( #FF ) ; COP SetFlagByte $FF — mark all actors for compose
    LDA #$FF
    STA $oamComposeBuffer ; Write $FF sentinels to OAM compose buffer
    STA $7F3101
    JSL $@sprite_composition.SortActorsByDepth ; Sort actors by depth, compose sprites, DMA player tiles
    JSL $@sprite_composition.ComposeAllSprites
    JSL $@hdma_dma_spc.DmaPlayerTilesToVram
    LDA $scrollModeFlags  ; Check scrollModeFlags bit 3 — palette-tile mode?
    BIT #$08
    BEQ loc_03DEA2
    JSL $@scene_script.RenderPaletteTiles ; Palette mode → RenderPaletteTiles
    BRA loc_03DEBA

  loc_03DEA2:
    LDA $069B             ; Check $069B → CameraFullRefresh BG1 (layer 0)
    BEQ loc_03DEAE
    LDX #$0000
    JSL $@camera_tilemap.CameraFullRefresh

  loc_03DEAE:
    LDA $069D             ; Check $069D → CameraFullRefresh BG2 (layer 2)
    BEQ loc_03DEBA
    LDX #$0002
    JSL $@camera_tilemap.CameraFullRefresh

  loc_03DEBA:
    STZ $musicRoomGroup   ; Clear music room group, effect deltas, companion words
    LDX #$0000
    STX $effectDeltaX
    STX $effectDeltaY
    STX $06E8
    STX $06EA
    RTL 
}

---------------------------------------------
; Load the heads-up display tilemap into the VRAM staging buffer.
; 
; First checks $09ED bit 6 — if set, the HUD is suppressed (returns immediately). This flag is set during cutscenes and special scenes where no status display should appear.
; 
; Switches to 16-bit mode and sets data bank to current program bank (PHK/PLB) for direct access to HudTilemapData.
; 
; The data stream uses a simple format:
; - Nonzero word: tile data — written directly to $7F0200,X (VRAM staging buffer)
; - Zero word followed by nonzero word: skip command — the second word is a tile count to advance X by (×2 for word offset)
; - Zero word followed by zero word: end of stream
; 
; After loading, sets displayModeFlags bit 0 ($0001) to signal that the VRAM buffer has pending data for the next VBlank transfer.

LoadHudTilemap {
    LDA $09ED             ; Check $09ED bit 6 — HUD suppressed (cutscene/menu)?
    BIT #$40
    BEQ loc_03DED5
    RTL                   ; HUD suppressed — return without loading

  loc_03DED5:
    PHP                   ; 16-bit A, set data bank to code bank for table access
    REP #$20
    PHB 
    PHK 
    PLB 
    LDY #$0000
    TYX 

  loc_03DEDF:
    LDA $&HudTilemapData, Y ; Parse loop: read HudTilemapData word
    BNE loc_03DEF7        ; Nonzero → write tile word to VRAM staging $7F0200,X
    LDA $&HudTilemapData+2, Y ; Zero word: check next word for skip count or end marker
    BEQ loc_03DF01        ; Double-zero = end of stream
    INY 
    INY 
    INY 
    INY 
    ASL                   ; Skip command: advance X by tile count × 2
    STA $0E
    TXA 
    CLC 
    ADC $0E
    TAX 
    BRA loc_03DEDF

  loc_03DEF7:
    STA $7F0200, X
    INX 
    INX 
    INY 
    INY 
    BRA loc_03DEDF

  loc_03DF01:
    LDA #$0001            ; Set displayModeFlags bit 0 — VRAM buffer pending
    TSB $displayModeFlags
    PLB 
    PLP 
    RTL 
}

---------------------------------------------
; Static tilemap data for the in-game HUD display.
; 
; Contains 75 word entries (150 bytes) encoding the BG3 tilemap for the HP bar, gem counter, and defense/strength indicators. Entries include tile indices, palette bits, and priority flags in SNES tilemap word format.
; 
; Embedded skip commands (zero words) advance the cursor past empty regions of the HUD layout, avoiding the need to store blank tiles explicitly.

HudTilemapData [
  #$0000   ;00
  #$000F   ;01
  #$340E   ;02
  #$340F   ;03
  #$0000   ;04
  #$0010   ;05
  #$2CCE   ;06
  #$2CCF   ;07
  #$0000   ;08
  #$0008   ;09
  #$ECEF   ;0A
  #$2CDA   ;0B
  #$2CDB   ;0C
  #$2CDC   ;0D
  #$341E   ;0E
  #$341F   ;0F
  #$6CDC   ;10
  #$6CDB   ;11
  #$6CDA   ;12
  #$ACEF   ;13
  #$0000   ;14
  #$0008   ;15
  #$6CCF   ;16
  #$6CCE   ;17
  #$0000   ;18
  #$0002   ;19
  #$2CDE   ;1A
  #$0000   ;1B
  #$000A   ;1C
  #$2CEA   ;1D
  #$2CD9   ;1E
  #$0000   ;1F
  #$0001   ;20
  #$2CED   ;21
  #$6CED   ;22
  #$0000   ;23
  #$0002   ;24
  #$6CEA   ;25
  #$0000   ;26
  #$000A   ;27
  #$6CDE   ;28
  #$0000   ;29
  #$0002   ;2A
  #$2CEE   ;2B
  #$0000   ;2C
  #$000A   ;2D
  #$2CFA   ;2E
  #$2CFB   ;2F
  #$2CFC   ;30
  #$2CFD   ;31
  #$6CFD   ;32
  #$2CE9   ;33
  #$6CFB   ;34
  #$6CFA   ;35
  #$0000   ;36
  #$000A   ;37
  #$6CEE   ;38
  #$0000   ;39
  #$0002   ;3A
  #$2CFE   ;3B
  #$2CEF   ;3C
  #$0000   ;3D
  #$0008   ;3E
  #$ECCF   ;3F
  #$ECCE   ;40
  #$0000   ;41
  #$0006   ;42
  #$ACCE   ;43
  #$ACCF   ;44
  #$0000   ;45
  #$0008   ;46
  #$6CEF   ;47
  #$6CFE   ;48
  #$0000   ;49
  #$0000   ;4A
]

---------------------------------------------
; Load standard scene palettes with character-form-specific overrides.
; 
; Operates in 16-bit mode. Checks the current scene against a skip list:
; - Scene $F7 (intro sequence): skip all palette loading
; - Scene $F0, $FD: skip standard palettes
; - Scene $FF (title screen): skip standard palettes
; 
; For non-skipped scenes:
; 1. Loads fx_palette_198040 to palette slot 1 (COP CopyPalette: source=@198040, start=1, dest=1, count=23). This is the standard HUD/UI palette.
; 2. Loads fx_palette_198020 to palette slot 0 (source=@198020, start=0, dest=$90, count=16). This is the standard game palette.
; 3. If playerFlags bit 3 ($0008) is set (Shadow form or transformation state): loads an additional palette from fx_palette_198000 (31 entries) via a manual DMA setup through $0402/$0405. This palette provides Shadow's distinctive color scheme.

LoadScenePalettes {
    PHP 
    REP #$20              ; 16-bit A for scene ID checks and COP palette ops
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00F7            ; Scene $F7 (intro) — skip all palette loading
    BEQ loc_03DFF6
    COP [CopyPalette] ( @fx_palette_198040, #01, #01, #17 ) ; COP CopyPalette: 23 HUD/UI colors from @198040
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00F0            ; Scenes $F0, $FD, $FF — skip game palette
    BEQ loc_03DFF6
    CMP #$00FD
    BEQ loc_03DFF6
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00FF
    BEQ loc_03DFF6
    COP [CopyPalette] ( @fx_palette_198020, #00, #90, #10 ) ; COP CopyPalette: 16 game colors from @198020 to CGRAM $90
    LDY #$0B40
    LDA $playerFlags      ; playerFlags bit 3 — Shadow/ability form?
    BIT #$0008
    BEQ loc_03DFF6        ; Normal form — skip Shadow palette
    SEP #$20
    LDA #$^fx_palette_198000 ; Shadow form: DMA 31 entries from @198000 via $0402 helper
    LDX #$&fx_palette_198000
    STA $0405
    REP #$20
    LDA #$001F
    JSR $0402

  loc_03DFF6:
    PLP 
    RTL 
}

---------------------------------------------
; Load player character sprite graphics to VRAM.
; 
; Checks the current scene against a skip list — scenes $F7, $FE, $8C don't load player graphics (no visible player character).
; 
; For normal scenes:
; 1. Sets VMADDL to $4200 and DMA transfers $1C00 bytes (7168 bytes = 112 tiles) from gfx_000000 to VRAM. This is the main player character spriteset.
; 
; 2. If playerFlags bit 3 ($08) is set: loads $0800 bytes (2048 bytes = 32 tiles) of special FX graphics from misc_fx_1CD580 to VRAM $4400. These are ability-related sprite tiles (Dark Friar projectiles, Aura Barrier orbitals, etc.).
; 
; 3. If scene is $E8 (Dark Gaia boss fight) and playerFlags bit 3 is NOT set: loads $0600 bytes (1536 bytes = 24 tiles) of alternative FX graphics from misc_fx_1CCA80 to VRAM $4400. These are the ranged projectile tiles used during the final boss.
; 
; All DMA transfers use scene_script.DmaWordToVram for the actual transfer.

LoadPlayerGraphics {
    PHP                   ; Scenes $F7, $FE, $8C — skip player graphics entirely
    LDA $sceneCurrent
    CMP #$F7
    BEQ loc_03E04E
    CMP #$FE
    BEQ loc_03E04E
    CMP #$8C
    BEQ loc_03E04E
    LDX #$4200            ; Main spritesheet: $1C00 bytes (112 tiles) → VRAM $4200
    STX $VMADDL
    LDX #$&gfx_000000
    LDA #$^gfx_000000
    LDY #$1C00
    JSL $@DmaWordToVram
    LDA $playerFlags      ; playerFlags bit 3 — ability form?
    BIT #$08
    BEQ loc_03E035
    LDX #$4400            ; Shadow: $0800 bytes FX tiles (misc_fx_1CD580) → VRAM $4400
    STX $VMADDL
    LDX #$&misc_fx_1CD580
    LDA #$^misc_fx_1CD580
    LDY #$0800
    JSL $@DmaWordToVram
    PLP 
    RTL 

  loc_03E035:
    LDA $sceneCurrent     ; Scene $E8 (Dark Gaia boss)?
    CMP #$E8
    BNE loc_03E04E
    LDX #$4400            ; Boss: $0600 bytes projectile tiles (misc_fx_1CCA80) → VRAM $4400
    STX $VMADDL
    LDX #$&misc_fx_1CCA80
    LDA #$^misc_fx_1CCA80
    LDY #$0600
    JSL $@DmaWordToVram

  loc_03E04E:
    PLP 
    RTL 
}

---------------------------------------------
; Initialize camera boundary limits from map geometry or custom bounds.
; 
; Two paths based on $0652:
; 
; === Normal path ($0652 = 0) ===
; Copies mapBoundsX/Y directly to cameraBoundsX/Y and cameraLowerYBound. Zeroes cameraOffsetX/Y (no scroll offset from map origin).
; 
; === Custom bounds path ($0652 ≠ 0) ===
; Parses packed nibble format from $0652/$0653 into camera window parameters:
; - $0652 low nibble → cameraOffsetX high byte (left edge, in 256-pixel units)
; - $0652 high nibble → cameraOffsetY high byte (top edge)
; - $0653 low nibble → cameraBoundsX high byte (right edge)
; - $0653 high nibble → cameraBoundsY high byte (bottom edge), also stored to $06DF
; 
; Used for scenes with camera-restricted areas (e.g., boss arenas, cutscene frames).
; 
; === Common finalization ===
; Clears low bytes of cameraBoundsY and cameraLowerYBound. Zeroes $0652 (consumed). Applies visible height correction: cameraBoundsY += $0100 − $06EC (adjusts for the playable viewport height vs. the full map).

InitCameraBounds {
    LDX $0652             ; Load $0652 — custom camera bounds override?
    BNE loc_03E06F        ; Custom bounds → decode packed nibble format
    LDX $mapBoundsX       ; Normal: copy mapBoundsX/Y directly to cameraBounds
    STX $cameraBoundsX
    LDX $mapBoundsY
    STX $cameraBoundsY
    STX $cameraLowerYBound
    LDX #$0000            ; Zero camera offsets (no custom pan origin)
    STX $cameraOffsetX
    STX $cameraOffsetY
    BRA loc_03E094

  loc_03E06F:
    LDA $0652             ; $0652 low nibble → cameraOffsetX high byte
    PHA 
    AND #$0F
    STA $cameraOffsetX+1
    PLA 
    LSR                   ; $0652 high nibble → cameraOffsetY high byte
    LSR 
    LSR 
    LSR 
    STA $cameraOffsetY+1
    LDA $0653             ; $0653 low nibble → cameraBoundsX high byte
    PHA 
    AND #$0F
    STA $cameraBoundsX+1
    PLA 
    LSR                   ; $0653 high nibble → cameraBoundsY high byte
    LSR 
    LSR 
    LSR 
    STA $cameraBoundsY+1
    STA $06DF

  loc_03E094:
    STZ $cameraBoundsY    ; Clear Y bound low bytes
    STZ $cameraLowerYBound
    REP #$20
    STZ $0652             ; Consume $0652, apply viewport correction: bounds += $100 − $06EC
    LDA #$0100
    SEC 
    SBC $06EC
    CLC 
    ADC $cameraBoundsY
    STA $cameraBoundsY
    SEP #$20
    RTL 
}