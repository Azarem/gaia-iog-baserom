?INCLUDE 'py_death_particle'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!playerActor                    09AA

---------------------------------------------

pyCC_portal [
  actor-def < #1C, #01, #20, {

  code_08CD6F:
    COP [BranchIfFlagByte] ( #FC, #01, &code_08CD93 )
    COP [AddPosition] ( #08, #0C )
    COP [ExitIfFlagByte] ( #D1, #01 )
    LDA #$1000
    TSB $10
    LDA #$2000
    TRB $10
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08CD95 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08CD93 {
    COP [Die]
}

code_08CD95 {
    COP [PrintDialogString] ( &dialogstring_08CDDA )
    COP [DialogueOptions] ( #02, #02, &code_list_08CD9F )
}

code_list_08CD9F [
  &code_08CDA5   ;00
  &code_08CDA5   ;01
  &code_08CDAA   ;02
]

code_08CDA5 {
    COP [PrintDialogString] ( &dialogstring_08CE10 )
    RTL 
}

code_08CDAA {
    COP [PrintDialogString] ( &dialogstring_08CE10 )
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SpawnAfterFlags] ( @py_death_particle, #$1800 )
    LDA #$0303
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #DD, #$00F8, #$01B0, #00, #$2200 )
    COP [SetEntryContinue]
    RTL 
}

dialogstring_08CDDA `[DEF]The mummified queen of[N]the Pyramid appears.[N] Quit[N] Jump in`

dialogstring_08CE10 `[CLD]`