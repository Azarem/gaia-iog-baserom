; ==============================================================================
; NGP epilogue thinker - epilogue slot flag on thinker spawn table
; ==============================================================================
; What it does: Adds h_epilogue_thinker (sets epilogue-related SRAM flag bits on
;   the selected save slot) and appends its spawn entry to scene $CEA9B table.
; Vanilla behavior: thinker_spawn_0CEA9B listed only vanilla thinkers for that
;   scene; no epilogue-init thinker on slot select.
; Hooks (overrides): scene_thinkers.thinker_spawn_0CEA9B+= (extra spawn row).
; Adds: h_epilogue_thinker / e_epilogue_thinker (COP [3D] then RTL).
; Depends on: scene_thinkers include; SRAM mirror $306354/$3063FC/$3063FE layout.
; State: Reads/writes slot index via $0D8C and SRAM indexed by X from ASL table.
; Hazards: Thinker runs with PHX; ORA #$0080 on checksum-related words; verify
;   slot index math matches DiaryScanSramSlots flag at $0DC6.
; ==============================================================================

h_epilogue_thinker [
  thinker_def < #00, #08, {

  e_epilogue_thinker:
    PHX
    LDA $0D8C
    XBA
    ASL
    TAX
    LDA $306354, X
    BIT #$0080
    BNE epilogue_init_next
    ORA #$0080
    STA $306354, X

    LDA $3063FC, X
    CLC
    ADC #$0080
    STA $3063FC, X
    
    LDA $3063FE, X
    EOR #$0080
    STA $3063FE, X

  epilogue_init_next:
    PLX
    COP [3D]
    RTL
} > ]


------------------------------------------
?INCLUDE 'scene_thinkers'
------------------------------------------

scene_thinkers.thinker_spawn_0CEA9B+=: thinker-spawn < #00, @h_epilogue_thinker >

