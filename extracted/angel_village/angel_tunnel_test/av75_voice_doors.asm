; Ishtar's voice — door puzzle instructions.
; 
; Multi-phase puzzle guide (~129 lines). "Ishtar's voice resounds.
; Don't hurry. Open the doors in order from the left."
; Provides step-by-step instructions for the door sequence
; puzzle. Tracks player progress through each door.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!playerYPos                     09A4

---------------------------------------------

av75_voice_doors [
  actor-def < #00, #00, #10, {

  code_06D787:
    LDA #$0200
    TSB $12
    COP [BranchOnFlagByte] ( #89, #01, &code_06D7BB )
    STZ $067F
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $playerYPos
    CMP #$00F0
    BCC code_06D7BB
    COP [NudgePosition] ( #08, #02 )
    LDA $0E
    AND #$000F
    STA $24
    STZ $0E
    COP [SetInteractHandler] ( &code_06D7BD )
    COP [SetEntryHere]
    RTL 
} >
]

code_06D7BB {
    COP [Die]
}

code_06D7BD {
    LDA $0AA6
    CMP $24
    BCC loc_06D834
    BNE loc_06D839
    COP [PlaySoundCh1] ( #0E )
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06D7D4 )
}

code_list_06D7D4 [
  &code_06D7E4   ;00
  &code_06D7EE   ;01
  &code_06D7F8   ;02
  &code_06D802   ;03
  &code_06D80C   ;04
  &code_06D816   ;05
  &code_06D820   ;06
  &code_06D82A   ;07
]

code_06D7E4 {
    COP [StageBgChange] ( #49 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0149 )
    RTL 
}

code_06D7EE {
    COP [StageBgChange] ( #4A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014A )
    RTL 
}

code_06D7F8 {
    COP [StageBgChange] ( #4B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014B )
    RTL 
}

code_06D802 {
    COP [StageBgChange] ( #4C )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014C )
    RTL 
}

code_06D80C {
    COP [StageBgChange] ( #4D )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014D )
    RTL 
}

code_06D816 {
    COP [StageBgChange] ( #4E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014E )
    RTL 
}

code_06D820 {
    COP [StageBgChange] ( #4F )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$014F )
    RTL 
}

code_06D82A {
    COP [StageBgChange] ( #50 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0150 )
    RTL 

  loc_06D834:
    COP [PrintDialogString] ( &dialogstring_06D83E )
    RTL 

  loc_06D839:
    COP [PrintDialogString] ( &dialogstring_06D87B )
    RTL 
}

dialogstring_06D83E `[TPL:A]Istar's voice resounds.[FIN]Don't hurry.[N]Open the doors in order[N]from the left.[END]`

dialogstring_06D87B `[TPL:A]Istar's voice resounds.[FIN]That door is already[N]open. There's no[N]need to open it.[END]`