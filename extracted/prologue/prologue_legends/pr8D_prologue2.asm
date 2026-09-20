; Prologue 2: the legends (~237 lines).
; 
; Second prologue segment. Continues the opening narrative
; with animated text and character silhouettes showing the
; legends of past civilizations affected by the comet's
; cyclical return. Extensive scripted text sequences.
---------------------------------------------

?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'pr_thinkers'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!M7SEL                          211A

---------------------------------------------

pr8D_prologue2 [
  actor-def < #00, #00, #38, {

  code_0BCB51:
    SEP #$20
    STZ $M7SEL
    REP #$20
    COP [CopyPalette] ( @pal_prologue_legends, #00, #00, #20 )
    COP [BranchOnFlagWord] ( #$017C, #01, &code_0BCB8A )
    COP [SetFlagWord] ( #$017C )
    COP [SpawnBeforeFlags] ( @code_0BCC2B, #$2800 )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0020, #$0050, #$2000 )
    LDA #$&spritestring_0BD0B2
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [Die]
} >
]

code_0BCB8A {
    COP [BranchOnFlagWord] ( #$017D, #01, &code_0BCBB4 )
    COP [SetFlagWord] ( #$017D )
    COP [SpawnBeforeFlags] ( @code_0BCC5B, #$2800 )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0064, #$0058, #$2000 )
    LDA #$&spritestring_0BD0E3
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [Die]
}

code_0BCBB4 {
    COP [BranchOnFlagWord] ( #$017E, #01, &code_0BCBDE )
    COP [SetFlagWord] ( #$017E )
    COP [SpawnBeforeFlags] ( @code_0BCC85, #$2800 )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0038, #$007C, #$2000 )
    LDA #$&spritestring_0BD11C
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [Die]
}

code_0BCBDE {
    COP [BranchOnFlagWord] ( #$017F, #01, &code_0BCC08 )
    COP [SetFlagWord] ( #$017F )
    COP [SpawnBeforeFlags] ( @code_0BCCAE, #$2800 )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0040, #$0020, #$2000 )
    LDA #$&spritestring_0BD144
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [Die]
}

code_0BCC08 {
    COP [SpawnBeforeFlags] ( @code_0BCCD7, #$2800 )
    COP [ClearFlagWord] ( #$017C )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0038, #$0050, #$2000 )
    LDA #$&spritestring_0BD189
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [Die]
}

code_0BCC2B {
    JSR $&code_0BCD26
    COP [SetEntryHere]
    LDA $0036
    AND #$0003
    BNE loc_0BCC3E
    DEC $00CA
    DEC $cameraTargetX

  loc_0BCC3E:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00E0
    BEQ code_0BCC55
    CMP #$008B
    BCC loc_0BCC52
    RTL 

  loc_0BCC52:
    JMP $&code_0BCCF5

  code_0BCC55:
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    RTL 
}

code_0BCC5B {
    JSR $&code_0BCD26
    COP [SetEntryHere]
    LDA $0036
    AND #$0003
    BNE loc_0BCC6E
    INC $00CA
    INC $cameraTargetX

  loc_0BCC6E:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00E0
    BEQ code_0BCC55
    CMP #$008B
    BCC loc_0BCC82
    RTL 

  loc_0BCC82:
    JMP $&code_0BCCF5
}

code_0BCC85 {
    JSR $&code_0BCD26
    COP [SetEntryHere]
    LDA $0036
    AND #$0003
    BNE loc_0BCC98
    INC $00CC
    INC $cameraTargetY

  loc_0BCC98:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00E0
    BEQ code_0BCC55
    CMP #$008B
    BCC loc_0BCCAC
    RTL 

  loc_0BCCAC:
    BRA code_0BCCF5
}

code_0BCCAE {
    JSR $&code_0BCD26
    COP [SetEntryHere]
    LDA $0036
    AND #$0003
    BNE loc_0BCCC1
    DEC $00CC
    DEC $cameraTargetY

  loc_0BCCC1:
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$00E0
    BEQ code_0BCC55
    CMP #$008B
    BCC loc_0BCCD5
    RTL 

  loc_0BCCD5:
    BRA code_0BCCF5
}

code_0BCCD7 {
    JSR $&code_0BCD26
    COP [SetEntryHere]
    DEC $00C2
    DEC $00C8
    LDA $00C2
    CMP #$0050
    BNE loc_0BCCED
    JMP $&code_0BCC55

  loc_0BCCED:
    CMP #$0000
    BEQ loc_0BCCF3
    RTL 

  loc_0BCCF3:
    BRA code_0BCCF5
}

code_0BCCF5 {
    COP [BranchOnFlagWord] ( #$017C, #00, &code_0BCD14 )
    LDA #$0200
    STA $gfxCacheIdxB
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #8D, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_0BCD14 {
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8E, #$0000, #$0000, #00, #$1100 )
    COP [Die]
}

code_0BCD26 {
    LDA #$0200
    STA $00C2
    LDA #$0200
    STA $00C8
    LDA #$0200
    STA $00CA
    LDA #$0200
    STA $00CC
    LDA #$0180
    STA $cameraTargetX
    LDA #$0180
    STA $cameraTargetY
    RTS 
}
---------------------------------------------

spritestring_0BD0B2 ~As time passed,[N]many legends [N]began to surface. ~

spritestring_0BD0E3 ~A legend from each[N]ruin,[N]a legend from each[N]culture.... ~

spritestring_0BD11C ~Various relics[N]were found in the[N]ruins.~

spritestring_0BD144 ~One of the[N]legends told of[N]strange statues[N]in the shapes of[N]spirits.~

spritestring_0BD189 ~What was a spirit to[N]ancient people...[N]The ruins [N]don't tell us.~