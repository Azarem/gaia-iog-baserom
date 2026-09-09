---------------------------------------------

it15_elder [
  actor-def < #22, #00, #30, {

  code_04E92C:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #41, #01, &code_04E958 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #04, #1C, #07, #1E, &code_04E942 )
    RTL 
} >
]

code_04E942 {
    COP [PrintWideString] ( &widestring_04E9FF )
    COP [SetFlagByte] ( #41 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #08, #19, #0D, #1A, &code_04E954 )
    RTL 
}

code_04E954 {
    COP [PrintWideString] ( &widestring_04EA45 )
}

code_04E958 {
    COP [SetOnInteract] ( &code_04E97A )
    COP [SpawnAfterRelFlags] ( @code_04E96A, #$0000, #$0004, #$0B00 )
    COP [SetEntryContinue]
    RTL 
}

code_04E96A {
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #22, #14 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    RTL 
}

code_04E97A {
    COP [BranchIfFlagByte] ( #44, #01, &code_04E9F1 )
    COP [BranchIfNoItem] ( #04, &code_04E9DC )
    COP [BranchIfNoItem] ( #03, &code_04E9E1 )
    COP [BranchIfFlagByte] ( #47, #01, &code_04E9D4 )
    COP [BranchIfFlagByte] ( #0E, #01, &code_04E9BC )
    COP [BranchIfFlagByte] ( #0F, #01, &code_04E9A0 )
    COP [PrintWideString] ( &widestring_04EA77 )
}

code_04E9A0 {
    COP [PrintWideString] ( &widestring_04EC46 )
    COP [DialogueOptions] ( #02, #02, &code_list_04E9AA )
}

code_list_04E9AA [
  &code_04E9B0   ;00
  &code_04E9B8   ;01
  &code_04E9B0   ;02
]

code_04E9B0 {
    COP [PrintWideString] ( &widestring_04EC76 )
    COP [SetFlagByte] ( #0F )
    RTL 
}

code_04E9B8 {
    COP [PrintWideString] ( &widestring_04ECAB )
}

code_04E9BC {
    COP [PrintWideString] ( &widestring_04ECCB )
    COP [DialogueOptions] ( #02, #01, &code_list_04E9C6 )
}

code_list_04E9C6 [
  &code_04E9CC   ;00
  &code_04E9D4   ;01
  &code_04E9CC   ;02
]

code_04E9CC {
    COP [PrintWideString] ( &widestring_04ECEC )
    COP [SetFlagByte] ( #0E )
    RTL 
}

code_04E9D4 {
    COP [PrintWideString] ( &widestring_04ED19 )
    COP [SetFlagByte] ( #47 )
    RTL 
}

code_04E9DC {
    COP [PrintWideString] ( &widestring_04EF6F )
    RTL 
}

code_04E9E1 {
    COP [PrintWideString] ( &widestring_04EDF4 )

  loc_04E9E5:
    COP [DialogueOptions] ( #02, #01, &code_list_04E9EB )
}

code_list_04E9EB [
  &code_04E9F1   ;00
  &code_04E9F7   ;01
  &code_04E9F1   ;02
]

code_04E9F1 {
    COP [PrintWideString] ( &widestring_04EF1C )
    BRA loc_04E9E5
}

code_04E9F7 {
    COP [PrintWideString] ( &widestring_04EF23 )
    COP [SetFlagByte] ( #44 )
    RTL 
}

widestring_04E9FF `[DLG:3,11][SIZ:D,2]Will hears a quiet [N]voice behind him... [FIN][TPL:D][TPL:4]Strange Voice: [N]You've come, Will...[PAL:0][END]`

widestring_04EA45 `[TPL:E][TPL:4]Elder: I'm here. [N]In the flowers. [N]I've lived too long.[PAL:0][END]`

widestring_04EA77 `[DEF][TPL:4]Elder: I can't live [N]without the protection [N]of the Flower Spirit. [FIN]You really look like[N]your father.[FIN]It seems like only[N]yesterday that he came[N]to this village.[FIN][TPL:0]Will: [N]My father... [FIN][TPL:4]Elder: Your mother, Shira,[N]was the only daughter[N]of your grandparents,[N]Bill and Lola.[FIN]She was very beautiful.[FIN]Your father fell in love[N]with her and took her[N]from the village.[FIN]All of the Itory tribe[N]have a strange power, [N]but Shira's was [N]especially strong. [FIN]She made a barrier to[N]hide the town, but[N]your father came[N]through it easily.[FIN]Come to think of it, he[N]was unusual, too...[FIN]`

widestring_04EC46 `[DEF][TPL:4]Were you summoned  [N]by your father? [N][PAL:0] Yes[N] No`

widestring_04EC76 `[CLR][TPL:4]Elder: What? If you[N]weren't....That's a[N]bad sign....[PAL:0][END]`

widestring_04ECAB `[CLR][TPL:4]Elder: That fulfills[N]Lola's prophesy.[FIN]`

widestring_04ECCB `[DEF][TPL:4]Do you plan to go?[N][PAL:0] Yes[N] No`

widestring_04ECEC `[DEF][CLR][TPL:4]Elder: A disobedient [N]son, unlike your father.[PAL:0][END]`

widestring_04ED19 `[DEF][CLR][TPL:4]Elder: Good. I will [N]entrust you with the [N]Incan Statue handed down [N]to the village. [FIN]The statues are the key [N]to the Incan riddle-- [N]untouched by human hands [N]for hundreds of years. [FIN]One statue is enshrined [N]in the cave below. [N]Use all your skill to [N]find it.[PAL:0][END]`

widestring_04EDF4 `[DEF][TPL:4]Elder: [N]Oooh, that's the [N]Incan Statue!![N]Good job! [FIN]I wonder if you were [N]put on this earth to [N]solve the Incan[N]riddle... [FIN]I'll tell you a legend[N]handed down by our[N]people.[FIN][::]Put the statue on the[N]Larai Cliff below the[N]ruins, where the spirits'[N]breath cannot reach. [FIN]The winds in the valley[N]will lead you to[N]the Gold Ship.[FIN]Understand?[N][PAL:0] Yes[N] No`

widestring_04EF1C `[DEF][CLR][TPL:4][JMP:&it15_elder.widestring_04EDF4+M]`

widestring_04EF23 `[CLR][TPL:4]Elder: [N]It's said that the Moon [N]Tribe has one more. [FIN]Have Lilly guide you [N]there. Be careful.[PAL:0][END]`

widestring_04EF6F `[DEF][CLR][JMP:&it15_elder.widestring_04EF23]`