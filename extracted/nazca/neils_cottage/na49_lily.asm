?BANK 05

---------------------------------------------

na49_lily [
  actor-def < #23, #00, #10, {

  code_05DD3F:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05DDBB )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #27, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #28, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [PrintDialogString] ( &dialogstring_05DDC0 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05DDDF )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #28, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #07, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #29, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_05DE46 )

  loc_05DD9F:
    COP [DialogueOptions] ( #02, #01, &code_list_05DDA5 )
} >
]

code_list_05DDA5 [
  &code_05DDAB   ;00
  &code_05DDB1   ;01
  &code_05DDAB   ;02
]

code_05DDAB {
    COP [PrintDialogString] ( &dialogstring_05DF9F )
    BRA loc_05DD9F
}

code_05DDB1 {
    COP [PrintDialogString] ( &dialogstring_05DFC3 )
    COP [SetFlagByte] ( #08 )
    COP [SetEntryContinue]
    RTL 
}

code_05DDBB {
    COP [PrintDialogString] ( &dialogstring_05DFDC )
    RTL 
}

dialogstring_05DDC0 `[TPL:A][TPL:1]Kara: [N]This person stinks... [FIN]`

dialogstring_05DDDF `[TPL:A][CLR][TPL:2]Lilly: What are you[N]saying! You shouldn't[N]talk like that!![FIN]There's a wonderful [N]smell in this room,  [N]isn't there?[END]`

dialogstring_05DE46 `[TPL:B][TPL:2]Lilly: There's a new[N]red star below the[N]constellation of Cygnus.[FIN][TPL:6]Neil: [N]That's right! [N]You know a lot! ! [FIN]The red star in Cygnus, [N]Will's interest in ruins.[FIN]Different elements are[N]bound together[N]organically...[FIN]I don't know if it's[N]by coincidence or by[N]design, but something[N]is going to happen.[FIN]Fortunately, the Nazca [N]ground paintings are [N]a week's walk east [N]of here. [FIN][::]Go?[N] Yes[N] No`

dialogstring_05DF9F `[CLR][TPL:6]Neil: [N]Don't say that. [N]Actually, I want to go. [FIN][JMP:&na49_lily.dialogstring_05DE46+M]`

dialogstring_05DFC3 `[CLR][TPL:6]Neil: [N]Good! It's settled![PAL:0][END]`

dialogstring_05DFDC `[TPL:B][TPL:2]Lilly: I shouldn't say [N]anything bad about [N]Will's cousin, but [N]this inventor...[PAL:0][END]`