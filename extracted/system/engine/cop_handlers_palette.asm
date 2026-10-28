; Palette-bundle animation COP handlers (37729–37887, Bank 00): five ops, #36–#3A (177 script sites). The block holds only these five handlers; the BG event-block ops live in cop_handlers_bg_rearrange and the thinker spawn/kill ops in cop_handlers_thinker.
; 
; A palette bundle (palette_bundles table, selected by a byte ID) is a list of 6-byte sub-entries; each sub-entry is an animation STRIP of N frames (byte 0), every frame being a block of consecutive colors copied to the same palette destination, and the frames of a strip are stored back to back. LoadPaletteBundle (hdma_dma_spc) loads the next sub-entry and CopyPaletteBundleFrame copies one frame (an MVN block move) per step. Per-actor state: bundle ID in animScratch+2 ($7F0002), sub-entry index in DP $0E (reset to 0 when the bundle ends), frames left in the strip in spritesetPtr ($7F0006, loaded from byte 0 of the sub-entry), the source pointer of the next frame in chatPtr, the wait value (sub-entry byte 5) in animScratch ($7F0000) and DP $08, and the pass counter in retPtr1 ($7F0004) for the Loop variants.
; 
; Start ops (#36–#38) load and apply sub-entry 0, store the address after the op in the actor entry point ($00) and YIELD (PLA, PLA, RTL), so on the next frame the script resumes right after the Start op. Step ops (#39, #3A) must therefore directly follow the Start op (the ambient thinkers do exactly this): each frame a Step either keeps yielding or, when the bundle (and, for #3A, every pass) is finished, continues the script with RTI.
; 
; Typical use: ambient_palette_cycler (PaletteRestart + PaletteStep in a loop; the bundle ID is the thinker's spawn parameter), one-shot palette flash thinkers, boot logos, boss and ability palette effects. PaletteStartLoop/StepLoop have three sites (two attack_ability_system ability effects and one unused script).
---------------------------------------------

?BANK 00

?INCLUDE 'hdma_dma_spc'

!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006

---------------------------------------------

; COP #36 with no operands. Restarts the bundle whose ID is already in animScratch+2: branches into the shared tail of PaletteStart (loc_009370), which zeroes the sub-entry index, loads and applies sub-entry 0, saves the resume address and yields. It does not set the bundle ID itself (not "bundle 0"): ambient thinkers get it from their spawn parameter, and the 2 sites are ambient_palette_cycler and PaletteResetAndKillThinker (actor_pool).

PaletteRestart {
    TYX 
    BRA loc_009370
}

---------------------------------------------
; COP #37 with one byte operand (palette bundle ID, 84 sites). Stores the ID in animScratch+2, zeroes the sub-entry index ($0E), loads sub-entry 0 with LoadPaletteBundle and applies it with CopyPaletteBundleFrame. Then stores the address after the operand in $00 (the actor entry point) and yields with PLA, PLA, RTL, so the next frame resumes at the following op (normally PaletteStep).

PaletteStart {
    TYX 
    LDA [$0A]             ; Read palette bundle ID byte
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bundle ID in animScratch+2 for LoadPaletteBundle

  loc_009370:
    STZ $0E               ; Sub-entry index <- 0 (first strip of the bundle)
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Fill the actor fields from sub-entry 0 (hold count, data pointer, ...)
    JSL $@hdma_dma_spc.CopyPaletteBundleFrame ; Apply it using those fields
    LDA $0A
    STA $00               ; Resume address = the op after this one (the Step op)
    PLA                   ; Drop the COP frame and yield (RTL to the actor runner)
    PLA 
    RTL 
}

---------------------------------------------
; COP #38 with two byte operands (bundle ID, pass count). Stores the ID in animScratch+2 and the pass count in retPtr1, zeroes the sub-entry index, applies sub-entry 0 and yields exactly like PaletteStart. The count is the TOTAL number of passes PaletteStepLoop makes through the bundle (a count of 0 would give 65,536 passes, by the DEC in StepLoop). Only 3 sites use it: two attack_ability_system effects (#2A/#4B with 2 passes) and one unused script.

PaletteStartLoop {
    TYX 
    LDA [$0A]             ; Read palette bundle ID
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bundle ID
    STZ $000E, X          ; Sub-entry index ← 0 (same field as DP $0E; D = X = slot)
    LDA [$0A]             ; Read repeat count byte
    INC $0A
    AND #$00FF
    STA $retPtr1, X       ; Store the pass count in retPtr1 ($7F0004)
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Load sub-entry 0
    JSL $@hdma_dma_spc.CopyPaletteBundleFrame ; Apply it
    LDA $0A
    STA $00               ; Resume address = the op after this one (PaletteStepLoop)
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #39 with no operands (85 sites). Decrements the frames-left counter in spritesetPtr once per call. While it is still nonzero the counter is stored back, the strip's wait value (animScratch, sub-entry byte 5) is re-seeded into the wait counter $08 and CopyPaletteBundleFrame copies the strip's next frame; then the actor yields (the entry point saved by PaletteStart makes the same Step op run next frame). When the counter reaches zero LoadPaletteBundle loads the next sub-entry: carry clear = another strip, whose first frame is applied before the actor yields; carry set = end of bundle, so the script continues past this op with RTI and the sub-entry index has been reset to 0.

PaletteStep {
    TYX 
    LDA $spritesetPtr, X  ; Frames left in the strip (byte 0 of the sub-entry, decremented once per step)
    DEC 
    BNE loc_0093BD        ; Still holding: skip the load
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Hold elapsed: load the next sub-entry
    BCC loc_0093C7        ; Carry clear = a sub-entry was loaded: apply it
    LDA $0A               ; Carry set = end of bundle: continue the script
    STA $02, S
    RTI 

  loc_0093BD:
    STA $spritesetPtr, X  ; Store the decremented hold counter
    LDA $animScratch, X   ; Sub-entry byte 5 (extra ticks between frames), kept in animScratch by LoadPaletteBundle
    STA $08               ; DP $08 is the wait counter: the next step runs after this many extra ticks

  loc_0093C7:
    JSL $@hdma_dma_spc.CopyPaletteBundleFrame ; Copy the strip's next frame into the palette staging buffer
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #3A with no operands. Same hold/frame logic as PaletteStep, but when LoadPaletteBundle reports the end of the bundle it decrements the pass counter in retPtr1: if nonzero it is stored and the bundle restarts at once (LoadPaletteBundle already reset the sub-entry index), and only when the counter reaches zero does the script continue with RTI. Pairs with PaletteStartLoop, which sets retPtr1.

PaletteStepLoop {
    TYX 
    LDA $spritesetPtr, X  ; Frames left in the strip (decremented once per step)
    DEC 
    BNE loc_0093EE

  loc_0093D6:
    JSL $@hdma_dma_spc.LoadPaletteBundle ; Strip finished: load the next sub-entry (first frame of the next strip)
    BCC loc_0093F9        ; Carry clear = more frames in bundle
    LDA $retPtr1, X       ; End of bundle: passes left
    DEC 
    BEQ loc_0093E9        ; Last pass finished → continue the script
    STA $retPtr1, X       ; Passes remain: store and load sub-entry 0 again
    BRA loc_0093D6

  loc_0093E9:
    LDA $0A
    STA $02, S
    RTI 

  loc_0093EE:
    STA $spritesetPtr, X
    LDA $animScratch, X   ; Sub-entry byte 5 (extra ticks between frames), kept in animScratch
    STA $0008, X          ; DP $08 of this slot (D = X): the wait counter

  loc_0093F9:
    JSL $@hdma_dma_spc.CopyPaletteBundleFrame
    PLA 
    PLA 
    RTL 
}