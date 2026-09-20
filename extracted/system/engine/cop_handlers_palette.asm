; COP handlers for background event-block transitions, palette animation, and thinker lifecycle (Bank $00, 11 COP handlers).
; 
; StageBgChange queues a BG tilemap/palette swap via event_blocks.LookupEventBlock without applying it. ApplyBgChange performs the animated transition loop calling AnimateEventBlock and UpdateFrameDialogue. StageBgChangeFromDeathIdx uses the actor's deathActionIdx as the event-block index.
; 
; PaletteRestart/Start/StartLoop initialize palette animation sequences from bundle IDs. PaletteStep/StepLoop advance palette frames, with loop variants supporting repeat counts via retPtr1.
; 
; SpawnThinkerParam/SpawnThinker allocate special thinker actors via AllocateSpecialActor and set entry pointers from script operands. KillThinker unlinks the thinker from the doubly-linked list ($005A/$005C) and returns the slot to the actor free stack.
---------------------------------------------

?BANK 00

?INCLUDE 'hdma_dma_spc'

!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006

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
    LDA [$0A]             ; Read palette bundle ID byte
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bundle ID in animScratch+2 for LoadPaletteBundle

  loc_009370:
    STZ $0E               ; Reset frame index to 0 (start from first palette frame)
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Load palette bundle header and frame data
    JSL $@hdma_dma_spc.DecompressGfxToVram ; Decompress and apply first palette frame to CGRAM staging
    LDA $0A
    STA $00               ; Save script pointer for deferred re-entry
    PLA                   ; Pop COP frame and yield RTL (palette step next frame)
    PLA 
    RTL 
}

---------------------------------------------
; COP #38 with two byte operands (bundle ID, repeat count). Stores bundle ID in animScratch+2 and repeat count in retPtr1, loads/decompresses the first frame, then yields via RTL.

PaletteStartLoop {
    TYX 
    LDA [$0A]             ; Read palette bundle ID
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bundle ID
    STZ $000E, X
    LDA [$0A]             ; Read repeat count byte
    INC $0A
    AND #$00FF
    STA $retPtr1, X       ; Store repeat count in retPtr1 ($7F0004)
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Load and decompress first palette frame
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
    LDA $spritesetPtr, X  ; Decrement spritesetPtr frame delay counter
    DEC 
    BNE loc_0093BD        ; Counter nonzero: not time to advance palette frame yet
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Counter reached zero: load next palette frame from bundle
    BCC loc_0093C7        ; Carry clear = more frames remain in bundle
    LDA $0A               ; Carry set = bundle exhausted: resume script
    STA $02, S
    RTI 

  loc_0093BD:
    STA $spritesetPtr, X  ; Store decremented counter back to spritesetPtr
    LDA $animScratch, X   ; Load current animation scratch (frame data pointer)
    STA $08               ; Store to $08 for DecompressGfxToVram

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
    LDA $spritesetPtr, X  ; Decrement palette frame delay counter
    DEC 
    BNE loc_0093EE

  loc_0093D6:
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Load next frame from bundle
    BCC loc_0093F9        ; Carry clear = more frames in bundle
    LDA $retPtr1, X       ; Bundle exhausted: check retPtr1 repeat counter
    DEC 
    BEQ loc_0093E9        ; Counter reached zero: all repeats done → resume script
    STA $retPtr1, X       ; Decremented counter still nonzero: reload bundle from frame 0
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