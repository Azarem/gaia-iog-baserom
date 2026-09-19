; COP handlers for background event-block transitions, palette animation, and thinker lifecycle (Bank $00, 11 COP handlers).
; 
; StageBgChange queues a BG tilemap/palette swap via event_blocks.LookupEventBlock without applying it. ApplyBgChange performs the animated transition loop calling AnimateEventBlock and UpdateFrameDialogue. StageBgChangeFromDeathIdx uses the actor's deathActionIdx as the event-block index.
; 
; PaletteRestart/Start/StartLoop initialize palette animation sequences from bundle IDs. PaletteStep/StepLoop advance palette frames, with loop variants supporting repeat counts via retPtr1.
; 
; SpawnThinkerParam/SpawnThinker allocate special thinker actors via AllocateSpecialActor and set entry pointers from script operands. KillThinker unlinks the thinker from the doubly-linked list ($005A/$005C) and returns the slot to the actor free stack.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'event_blocks'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'system_core'

!sfxQueueCh1                    06F8
!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006
!animScratch2                   7F000E
!deathActionIdx                 7F0024

---------------------------------------------

; COP #32 background-change stager taking one byte operand: an event-block index. Calls event_blocks.LookupEventBlock to queue a BG tilemap/palette swap without applying it immediately; the paired ApplyBgChange COP performs the animated transition. Used in ending sequences and Babel Tower cutscenes.

StageBgChange {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00931F:
    JSL $@event_blocks.LookupEventBlock
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #33 with no operands. Runs one UpdateFrameRender then loops AnimateEventBlock until carry set, calling UpdateFrameDialogue each iteration to drive the animated BG tilemap/palette transition to completion.

ApplyBgChange {
    TYX 
    SEP #$20
    JSL $@system_core.UpdateFrameRender
    JSL $@system_core.UpdateFrameDialogue
    REP #$20

  loc_009335:
    JSL $@event_blocks.AnimateEventBlock
    BCS loc_009345
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    BRA loc_009335

  loc_009345:
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #34 with no operands. Uses the actor's deathActionIdx ($7F0024) as the event-block index, queues SFX $0F0F to both channels, then calls LookupEventBlock to stage the same BG swap as StageBgChange.

StageBgChangeFromDeathIdx {
    TYX 
    LDA $deathActionIdx, X
    PHA 
    LDA #$0F0F
    STA $sfxQueueCh1
    PLA 
    BRA loc_00931F
}

---------------------------------------------
; COP #36 with no operands. Clears frame index at actor+$0E, calls LoadPaletteBundle and DecompressGfxToVram to reload palette frame 0, then yields via RTL.

PaletteRestart {
    TYX 
    BRA loc_009370
}

---------------------------------------------
; COP #37 with one byte operand (palette bundle ID). Stores the ID in animScratch+2, loads and decompresses the bundle, then yields via RTL.

PaletteStart {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_009370:
    STZ $0E
    JSL $@hdma_dma_spc.LoadPaletteBundle
    JSL $@hdma_dma_spc.DecompressGfxToVram
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #38 with two byte operands (bundle ID, repeat count). Stores bundle ID in animScratch+2 and repeat count in retPtr1, loads/decompresses the first frame, then yields via RTL.

PaletteStartLoop {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    STZ $000E, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $retPtr1, X
    JSL $@hdma_dma_spc.LoadPaletteBundle
    JSL $@hdma_dma_spc.DecompressGfxToVram
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #39 with no operands. Decrements spritesetPtr frame counter each call; on zero calls LoadPaletteBundle and RTI-advances the script when the bundle is exhausted, otherwise updates animScratch and decompresses to VRAM before yielding.

PaletteStep {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0093BD
    JSL $@hdma_dma_spc.LoadPaletteBundle
    BCC loc_0093C7
    LDA $0A
    STA $02, S
    RTI 

  loc_0093BD:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $08

  loc_0093C7:
    JSL $@hdma_dma_spc.DecompressGfxToVram
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #3A with no operands. Like PaletteStep, but when a bundle completes it decrements retPtr1 and reloads from frame 0 if repeats remain; RTI-advances only when both bundle and repeat count are exhausted.

PaletteStepLoop {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0093EE

  loc_0093D6:
    JSL $@hdma_dma_spc.LoadPaletteBundle
    BCC loc_0093F9
    LDA $retPtr1, X
    DEC 
    BEQ loc_0093E9
    STA $retPtr1, X
    BRA loc_0093D6

  loc_0093E9:
    LDA $0A
    STA $02, S
    RTI 

  loc_0093EE:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $0008, X

  loc_0093F9:
    JSL $@hdma_dma_spc.DecompressGfxToVram
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #3B with one byte (init param) plus one Address (entry pointer). Allocates a special actor via AllocateSpecialActor, stores param in animScratch+2, writes the far entry pointer to $0000/$0002, copies caller animScratch2, and clears $000E.

SpawnThinkerParam {
    PHY 
    JSR $&actor_pool.AllocateSpecialActor
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_009410:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, X
    TXY 
    LDA $01, S
    TAX 
    LDA $animScratch2, X
    TYX 
    STA $animScratch2, X
    LDA #$0000
    STA $000E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #3C with one Address operand. Same as SpawnThinkerParam but skips the param byte; allocates a special thinker actor and sets its entry pointer from the script operand.

SpawnThinker {
    PHY 
    JSR $&actor_pool.AllocateSpecialActor
    TYX 
    BRA loc_009410
}

---------------------------------------------
; COP #3D with no operands. Unlinks the current actor from the doubly-linked thinker list ($005A head / $005C tail), then pushes the freed slot onto the actor free stack at $0052.

KillThinker {
    TYX 
    LDY $0004, X
    BNE loc_009459
    LDY $0006, X
    STY $005A
    BEQ loc_00946D
    LDA #$0000
    STA $0004, Y
    BRA loc_00946D

  loc_009459:
    LDA $0006, X
    STA $0006, Y
    BNE loc_009466
    STY $005C
    BRA loc_00946D

  loc_009466:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_00946D:
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    DEC $0052             ; Pre-decrement free-stack pointer by 2 (two 8-bit DECs for word slot)
    DEC $0052
    REP #$20
    TXA 
    STA [$52]             ; Write freed actor slot address to top of free stack via indirect [$52]
    PLD 
    LDA $0A
    STA $02, S
    RTI 
}