; Thinker execution system — spawning, scheduling, and per-frame dispatch (250157–250357 + 251879–252010, Bank 03).
; 
; Manages the lifecycle and per-frame execution of scene thinkers — lightweight script actors that run alongside the main actor system. Thinkers handle ambient effects, palette cycling, background animations, cutscene overlays, and HDMA-driven visual effects.
; 
; === THINKER DATA MODEL ===
; 
; Thinkers use a separate memory pool from actors (16 slots of $10 bytes at $0F00, allocated via ThinkerPoolAlloc in actor_execution). Each thinker slot contains:
; - $0000,X: Code entry point (word)
; - $0002,X: Bank byte
; - $0004,X: Previous link pointer (doubly-linked list)
; - $0006,X: Next link pointer
; - $0008,X: Wait counter (same semantics as actor $08: a stored n makes the thinker skip n passes)
; - animScratch ($7F0000,X): Thinker-specific scratch fields
; - animScratch2 ($7F000E,X): Thinker filter flags (first word of the thinker's code, i.e. the first two operands of its thinker-def)
; 
; The thinker linked list is rooted at $005A (head) and $005C (tail).
; 
; === SPAWNING (SpawnSceneThinkers, 251879) ===
; 
; SpawnSceneThinkers reads scene_thinkers[$0646] to find the current scene's thinker definition list. If the pointer is zero or bit 7 ($0080) is set in the first data byte, the scene has no active thinkers.
; 
; For each thinker record (terminated by $FF byte):
; 1. Allocates a slot via actor_execution.ThinkerPoolAlloc
; 2. Links into a doubly-linked list ($0004 = prev, $0006 = next)
; 3. Calls InitThinkerFromSceneData to parse the binary record
; 
; InitThinkerFromSceneData reads a variable-length record: type byte → animScratch+2 ($7F0002,X; the thinker's spawn parameter, e.g. a palette bundle ID), code pointer → $42, bank byte → $44. Dereferences the code pointer to read its first word as animScratch2 (thinker filter flags), then stores entry point (code + 2) and bank to slot fields $0000/$0002.
; 
; === EXECUTION TYPES (250157–250357) ===
; 
; Four runners filter the list on animScratch2 ($7F000E,X):
; 
; - RunThinkers_General: bit 2 ($0004) CLEAR. Called by MainLoop right after the VBlank sync and at scene start.
; - RunThinkers_Hdma: bit 2 SET — the complement of A. MainLoop and the scene-start sequence call it after ResetHdmaState, so the HDMA/window-DMA thinkers (the bit-2 ones: comet_lair_hdma_*, angel_tunnel_window_dma, ...) bind their channels after the per-frame reset.
; - RunThinkers_General_Light: bit 11 ($0800) SET and bit 2 CLEAR. Called by the lighter frame routines of system_core (UpdateFrameDialogue, UpdateFrameRender, UpdateFrameFull) after their VBlank sync.
; - RunThinkers_Hdma_Light: bits 11 AND 2 both SET. The same routines call it after ResetHdmaState, before the sync.
; 
; All 59 scene thinker-defs in extracted/ (32 with filter word $0804, 27 with $0800) have bit 11 set, so for scene thinkers C selects exactly A's set and D exactly B's. Runtime-spawned thinkers (SpawnThinker/SpawnThinkerParam, 77 sites) inherit the spawner's animScratch2 and some scripts store their own (future_vision_cutscene $0804, sE8_dark_gaia $0004, dc2F_adrift ORs in $0800), so there the bit does matter: a thinker without bit 11 runs only in the main loop (TypeA/B) and pauses while the lighter frame routines (dialogue, render, music upload) run. Bit 11 therefore reads as 'keep running in the lighter frame routines', not as a cutscene marker.
; 
; All four runners share one dispatch pattern: walk the list from $5A with D = X = slot, test the filter, then DEC $08 / BPL _Next (a wait counter of n skips n passes; the pass where it was 0 runs the script and STZ $08), push PHK + PEA _Next−1, the thinker's bank and entry − 1, and RTL into the script. The script runs like an actor script (COP ops, SetEntryHereAndYield, ends with RTL back to _Next). _Next follows the $06 link or exits when the list is exhausted.
---------------------------------------------

?BANK 03

?INCLUDE 'actor_execution'
?INCLUDE 'scene_thinkers'

!sceneTableIndex                0646
!animScratch                    7F0000
!animScratch2                   7F000E

---------------------------------------------

; Spawn scene-specific thinker actors from the scene_thinkers table.
; 
; Looks up the thinker list pointer from scene_thinkers[$0646]. If zero, the scene has no thinkers. Otherwise, reads thinker records in a loop:
; 
; 1. Allocates a thinker slot via ThinkerPoolAlloc
; 2. Links into a doubly-linked list ($0004 = prev, $0006 = next)
; 3. Calls InitThinkerFromSceneData to parse the record
; 4. Terminates when data byte = $FF
; 
; Stores list head at $005A and tail at $005C. Uses bank $008C for thinker data.

SpawnSceneThinkers {
    PHP                   ; Initialize thinker list: zero head ($005A) and tail ($005C)
    REP #$20
    STZ $005A
    STZ $005C
    LDX $sceneTableIndex  ; Scene index ($0646) → look up scene_thinkers table pointer
    LDA $@scene_thinkers, X
    BEQ loc_03D82F        ; Zero pointer = no thinkers for this scene
    STA $3E
    LDA #$008C            ; $008C = thinker data bank
    STA $40
    LDA [$3E]
    BIT #$0080            ; Bit 7 ($0080) in first byte = scene has no active thinkers
    BNE loc_03D82F
    JSL $@actor_execution.ThinkerPoolAlloc ; Allocate first thinker slot; store as list head ($005A)
    STY $005A
    BRA loc_03D826

  loc_03D810:
    LDA [$3E]             ; Loop: read next thinker type byte; $FF = end of list
    AND #$00FF
    CMP #$00FF
    BEQ loc_03D82C
    JSL $@actor_execution.ThinkerPoolAlloc ; Allocate and doubly-link: prev.$06 = new, new.$04 = prev
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03D826:
    TYX 
    JSR $&InitThinkerFromSceneData ; Parse scene data record into thinker slot fields
    BRA loc_03D810

  loc_03D82C:
    STX $005C             ; Store last thinker as list tail ($005C)

  loc_03D82F:
    PLP 
    RTL 
}

---------------------------------------------
; Parse a thinker's binary scene data record from pointer $3E.
; 
; Record format (variable length):
; - Byte 0: thinker type → stored to animScratch+2 ($7F0002,X)
; - Bytes 1–2: code pointer → $42 (indirect)
; - Byte 3: bank byte → $44
; 
; Advances $3E past the record. Then dereferences the code pointer to read its first word as animScratch2 ($7F000E,X = thinker filter flags), and stores the entry point (code + 2) and bank to thinker slot fields $0000 and $0002.

InitThinkerFromSceneData {
    LDY #$0000            ; Byte 0: thinker type → animScratch+2 ($7F0002,X)
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $animScratch+2, X
    LDA [$3E], Y          ; Bytes 1–2: code pointer → $42
    INY 
    INY 
    STA $42
    LDA [$3E], Y          ; Byte 3: bank → $44; advance $3E past this record
    INY 
    AND #$00FF
    STA $44
    TYA 
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000
    LDA [$42], Y          ; Read first word of code as animScratch2 (thinker filter flags)
    INY 
    INY 
    STA $animScratch2, X
    TYA 
    CLC 
    ADC $42
    STA $0000, X          ; Entry point = code + 2 → thinker function pointer $0000,X
    LDA $44               ; Load bank byte to thinker slot $0002,X
    STA $0002, X
    RTS 
}
---------------------------------------------

; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) CLEAR (called by MainLoop after the VBlank sync, and by the scene-start sequence).
; 
; Iterates the thinker linked list from $5A with D = X = slot. For each thinker: bit 2 set → next. Otherwise DEC $08 / BPL → next while the wait counter was positive; when it was 0 the script runs and $08 is cleared. There is no bit-11 test here.
; 
; Typical general thinkers: palette cyclers (ambient_palette_cycler), boot-logo palettes, color-add effects.

RunThinkers_General {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D15A

  loc_03D135:
    TCD 
    TAX 
    LDA $animScratch2, X  ; Read animScratch2 ($7F000E,X) for thinker type check
    BIT #$0004            ; Bit 2 ($0004): TypeA processes clear, TypeB processes set
    BNE RunThinkers_General_Next
    DEC $08               ; Wait counter: a stored n skips n passes; the pass where $08 was 0 gives $FFFF and runs the script
    BPL RunThinkers_General_Next
    STZ $08               ; Clear the counter; the script sets a new wait if it wants one
    PHK 
    PEA $&RunThinkers_General_Next-1 ; Return address for the script's RTL: _Next (the script returns like a subroutine)
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC                   ; Entry address - 1: the RTL below jumps to [$02:$00]
    PHA 
    RTL 
}

RunThinkers_General_Next {
    LDA $06
    BNE loc_03D135

  loc_03D15A:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) SET — the complement of RunThinkers_General.
; 
; MainLoop and the scene-start sequence call it right after ResetHdmaState, so thinkers that bind HDMA channels (comet_lair_hdma_*, angel_tunnel_window_dma, dao_sine_hdma_slow, ...) get fresh channels every frame. Same wait-counter dispatch as TypeA.

RunThinkers_Hdma {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D18A

  loc_03D165:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004            ; Bit 2 ($0004): TypeB processes set, skips clear
    BEQ RunThinkers_Hdma_Next
    DEC $08
    BPL RunThinkers_Hdma_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_Hdma_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_Hdma_Next {
    LDA $06
    BNE loc_03D165

  loc_03D18A:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 bit 11 ($0800) SET and bit 2 ($0004) CLEAR.
; 
; Called by UpdateFrameDialogue, UpdateFrameRender and UpdateFrameFull after their VBlank sync. It is RunThinkers_General plus a bit-11 requirement: the 59 scene thinker-defs all carry bit 11 and run here, but a runtime-spawned thinker without bit 11 is paused whenever one of these lighter frame routines runs.

RunThinkers_General_Light {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1BF

  loc_03D195:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800            ; Bit 11 = keep running in the lighter frame routines (set in all 59 scene thinker-defs; runtime-spawned thinkers may lack it)
    BEQ RunThinkers_General_Light_Next
    BIT #$0004            ; Bit 2 ($0004): must be clear for TypeC (not deferred)
    BNE RunThinkers_General_Light_Next
    DEC $08               ; Same wait-counter test as TypeA
    BPL RunThinkers_General_Light_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_General_Light_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_General_Light_Next {
    LDA $06
    BNE loc_03D195

  loc_03D1BF:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with BOTH animScratch2 bits 11 ($0800) AND 2 ($0004) SET.
; 
; Uses AND #$0804 / CMP #$0804 to verify both bits. Called by UpdateFrameDialogue, UpdateFrameRender and UpdateFrameFull after ResetHdmaState and before the VBlank sync — it is TypeB's counterpart in the lighter frame routines: scene thinkers (all with bit 11) run here, runtime-spawned thinkers only if they carry bit 11.

RunThinkers_Hdma_Light {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1F2

  loc_03D1CA:
    TCD 
    TAX 
    LDA $animScratch2, X
    AND #$0804            ; AND #$0804 + CMP #$0804: require both bits 11 and 2 set
    CMP #$0804
    BNE RunThinkers_Hdma_Light_Next
    DEC $08
    BPL RunThinkers_Hdma_Light_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_Hdma_Light_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_Hdma_Light_Next {
    LDA $06
    BNE loc_03D1CA

  loc_03D1F2:
    PLD 
    PLP 
    RTL 
}