; Prologue 3: the missing (~124 lines).
; 
; Third prologue segment about Will's father's disappearance
; at the Tower of Babel. Establishes Will's motivation to
; search for his father. Transitions to the game's opening.
---------------------------------------------

?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'pr_thinkers'

!gfxCacheIdxB                   064A
!cameraBoundsY                  06DC
!playerActor                    09AA
!displayModeFlags               09EC
!CGWSEL                         2130
!CGADSUB                        2131
!COLDATA                        2132

---------------------------------------------

pr8E_prologue3 [
  actor-def < #00, #00, #38, {

  code_0BCD4E:
    LDA #$4001
    TSB $displayModeFlags
    COP [CopyPalette] ( @pal_prologue_missing, #00, #00, #20 )
    LDA #$0A00
    STA $gfxCacheIdxB
    LDA #$0220
    STA $cameraBoundsY
    SEP #$20
    LDA #$81
    STA $CGADSUB
    LDA #$EF
    STA $COLDATA
    REP #$20
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    AND #$FFF7
    STA $0010, Y
    COP [SpawnAfterFlags] ( @code_0BCE05, #$2800 )
    COP [SetEntryHere]
    LDY $playerActor
    LDA $0016, Y
    INC 
    STA $0016, Y
    CMP #$01A0
    BEQ loc_0BCD9E
    RTL 

  loc_0BCD9E:
    LDA #$000F
    STA $24

  loc_0BCDA3:
    COP [WaitByte] ( #09 )
    SEP #$20
    LDA $24
    ORA #$E0
    STA $COLDATA
    REP #$20
    LDA $24
    BEQ loc_0BCDBA
    DEC 
    STA $24
    BRA loc_0BCDA3

  loc_0BCDBA:
    SEP #$20
    LDA #$82
    STA $CGWSEL
    LDA #$10
    STA $CGADSUB
    LDA #$E0
    STA $COLDATA
    REP #$20
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$003C, #$0048, #$2000 )
    LDA #$&spritestring_0BD1CA
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [WaitWord] ( #$010D )
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    COP [WaitByte] ( #59 )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8F, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryHere]
    RTL 
} >
]

code_0BCE02 {
    COP [SetEntryHere]
    RTL 
}

code_0BCE05 {
    COP [RngByte]
    AND #$0007
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryHereAndYield]
    COP [SpawnAfterFlags] ( @code_0BCE1A, #$1800 )
    BRA code_0BCE05
}

code_0BCE1A {
    LDA #$0100
    STA $14
    COP [RngByte]
    AND #$003F
    CLC 
    ADC #$0138
    STA $16
    COP [StageSpriteLoopMoveX] ( #0C, #08, #02 )
    COP [AnimLoop]
    COP [Die]
}
---------------------------------------------

spritestring_0BD1CA ~People who entered[N]the ruins,[N]searching for[N]wealth, went in,[N]and were never seen[N]again.~