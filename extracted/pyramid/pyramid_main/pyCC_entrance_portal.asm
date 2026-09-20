; Pyramid entrance portal — choice to enter.
; 
; Interactive warp: "The door to the Pyramid appears in the
; light... Quit/Jump in" — gives the player the choice to
; enter the Pyramid or back out. Standard dungeon entrance
; portal with confirmation dialog.
---------------------------------------------

?INCLUDE 'py_death_particle'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!playerActor                    09AA

---------------------------------------------

pyCC_entrance_portal [
  actor-def < #1C, #01, #10, {

  code_08B6A5:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_08B6B1 )
    COP [SetEntryHere]
    RTL 
} >
]

code_08B6B1 {
    COP [PrintDialogString] ( &dialogstring_08B70D )
    COP [DialogueOptions] ( #02, #02, &code_list_08B6BB )
}

code_list_08B6BB [
  &code_08B6C1   ;00
  &code_08B6C1   ;01
  &code_08B6C6   ;02
]

code_08B6C1 {
    COP [PrintDialogString] ( &dialogstring_08B74B )
    RTL 
}

code_08B6C6 {
    COP [PrintDialogString] ( &dialogstring_08B74B )
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [SpawnAfterFlags] ( @py_death_particle, #$1800 )
    LDA #$0303
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #CC, #$01F8, #$0130, #03, #$4400 )
    RTL 
}
---------------------------------------------

dialogstring_08B70D `[TPL:B]The door to the Pyramid[N]appears in the light...[N] Quit[N] Jump in`

dialogstring_08B74B `[CLD]`