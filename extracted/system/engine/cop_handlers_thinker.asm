?BANK 00

?INCLUDE 'actor_pool'

!animScratch                    7F0000
!animScratch2                   7F000E

---------------------------------------------

; COP #3B with one byte (init param) plus one Address (entry pointer). Allocates a special actor via AllocateSpecialActor, stores param in animScratch+2, writes the far entry pointer to $0000/$0002, copies caller animScratch2, and clears $000E.

SpawnThinkerParam {
    PHY 
    JSR $&actor_pool.AllocateSpecialActor ; Allocate from thinker pool via AllocateSpecialActor
    TYX 
    LDA [$0A]             ; Read param byte and store in animScratch+2 of new thinker
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_009410:
    LDA [$0A]             ; Read entry pointer word from script
    INC $0A
    INC $0A
    STA $0000, X          ; Write entry pointer to new thinker $0000
    LDA [$0A]             ; Read entry bank byte
    INC $0A
    AND #$00FF
    STA $0002, X          ; Write bank byte to new thinker $0002
    TXY 
    LDA $01, S
    TAX 
    LDA $animScratch2, X  ; Copy caller's animScratch2 to new thinker (inherit parent state)
    TYX 
    STA $animScratch2, X
    LDA #$0000            ; Clear $000E on new thinker (no initial OAM attributes)
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
    LDY $0004, X          ; Load prev pointer of dying thinker
    BNE loc_009459        ; Prev nonzero → not the list head (normal splice)
    LDY $0006, X          ; No prev: load next and make it the new head
    STY $005A             ; Update thinker list head ($005A) to next
    BEQ loc_00946D
    LDA #$0000
    STA $0004, Y
    BRA loc_00946D

  loc_009459:
    LDA $0006, X          ; Mid/tail splice: get dying thinker's next
    STA $0006, Y          ; Patch: prev.next = dying.next
    BNE loc_009466        ; If next is null, prev becomes new tail
    STY $005C             ; Update thinker list tail ($005C) to prev
    BRA loc_00946D

  loc_009466:
    TAY 
    LDA $0004, X          ; Reverse patch: next.prev = dying.prev
    STA $0004, Y

  loc_00946D:
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    DEC $0052             ; Pre-decrement thinker free-stack pointer by 2
    DEC $0052
    REP #$20
    TXA                   ; Push freed thinker slot address onto LIFO free stack
    STA [$52]             ; Write freed actor slot address to top of free stack via indirect [$52]
    PLD 
    LDA $0A
    STA $02, S
    RTI 
}