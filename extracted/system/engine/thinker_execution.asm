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
; - $0008,X: Frame delay timer (same semantics as actor $08)
; - animScratch ($7F0000,X): Thinker-specific scratch fields
; - animScratch2 ($7F000E,X): Thinker type filter flags
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
; InitThinkerFromSceneData reads a variable-length record: type byte → animScratch+2 ($7F0002,X), code pointer → $42, bank byte → $44. Dereferences the code pointer to read its first word as animScratch2 (thinker filter flags), then stores entry point (code + 2) and bank to slot fields $0000/$0002.
; 
; === EXECUTION TYPES (250157–250357) ===
; 
; Four thinker execution filters based on animScratch2 ($7F000E,X) bit flags, called at different points in the game loop:
; 
; - RunThinkers_TypeA: bit 2 ($0004) CLEAR — general-purpose thinkers (ambient effects, palette cycling, background animations). Runs during normal gameplay.
; - RunThinkers_TypeB: bit 2 ($0004) SET — deferred/secondary thinkers. Runs after TypeA, allowing ordered execution within a single frame.
; - RunThinkers_TypeC: bit 11 ($0800) SET and bit 2 ($0004) CLEAR — cutscene overlay thinkers in the primary phase. Active during cutscene playback.
; - RunThinkers_TypeD: bits 11 ($0800) AND 2 ($0004) both SET — cutscene deferred thinkers. Runs after TypeC for deferred cutscene effects.
; 
; All four types share the same COP dispatch pattern: traverse the linked list from $5A, check filter flags, decrement frame timer, and use PHK/PEA/PHA/RTL to dispatch to the thinker's script entry point. The _Next routine for each type follows the $06 link to the next thinker or exits when the list is exhausted.
---------------------------------------------

?BANK 03

?INCLUDE 'actor_execution'
?INCLUDE 'scene_thinkers'

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
    LDX $0646             ; Scene index ($0646) → look up scene_thinkers table pointer
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
    JSL $@actor_execution.ThinkerPoolAlloc ; Allocate and doubly-link: new.next = prev, prev.prev = new
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
    LDA $44               ; Store bank byte to thinker slot $0002,X
    STA $0002, X
    RTS 
}
---------------------------------------------

; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) CLEAR.
; 
; Processes general-purpose thinkers that should run during normal gameplay. Iterates the thinker linked list from $5A. For each thinker: checks the flag — if bit 2 is set, skips to next. Otherwise performs standard COP dispatch (frame timer check → script call → next link).
; 
; TypeA thinkers typically handle ambient effects, palette cycling, background animations, and other non-deferred tasks.

RunThinkers_TypeA {
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
    BNE RunThinkers_TypeA_Next
    DEC $08
    BPL RunThinkers_TypeA_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeA_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeA_Next {
    LDA $06
    BNE loc_03D135

  loc_03D15A:
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Execute thinkers with animScratch2 ($7F000E,X) bit 2 ($0004) SET.
; 
; Processes deferred/secondary thinkers. Complementary to TypeA — only runs thinkers that TypeA skips. The bit 2 flag acts as a phase selector: TypeA runs first (bit clear), then TypeB runs afterward (bit set), allowing ordered execution of thinker groups within a single frame.

RunThinkers_TypeB {
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
    BEQ RunThinkers_TypeB_Next
    DEC $08
    BPL RunThinkers_TypeB_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeB_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeB_Next {
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
; Processes cutscene/overlay thinkers that are in the primary (non-deferred) phase. Requires bit 11 to be set (cutscene-active) and bit 2 to be clear (not deferred). Used during cutscene playback to run overlay effects like palette transitions or HDMA animations.

RunThinkers_TypeC {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1BF

  loc_03D195:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800            ; Bit 11 ($0800): cutscene thinker flag required for TypeC
    BEQ RunThinkers_TypeC_Next
    BIT #$0004            ; Bit 2 ($0004): must be clear for TypeC (not deferred)
    BNE RunThinkers_TypeC_Next
    DEC $08
    BPL RunThinkers_TypeC_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeC_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeC_Next {
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
; Processes cutscene thinkers in the deferred phase. Uses AND #$0804 / CMP #$0804 to verify both bits are set simultaneously. Complementary to TypeC — runs after TypeC to handle deferred cutscene effects.

RunThinkers_TypeD {
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
    BNE RunThinkers_TypeD_Next
    DEC $08
    BPL RunThinkers_TypeD_Next
    STZ $08
    PHK 
    PEA $&RunThinkers_TypeD_Next-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

RunThinkers_TypeD_Next {
    LDA $06
    BNE loc_03D1CA

  loc_03D1F2:
    PLD 
    PLP 
    RTL 
}