---------------------------------------------

awBA_bones [
  actor-def < #2C, #01, #10, {

  code_08A261:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A26F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A26F {
    COP [PrintWideString] ( &widestring_08A289 )
    COP [DialogueOptions] ( #02, #02, &code_list_08A279 )
}

code_list_08A279 [
  &code_08A284   ;00
  &code_08A27F   ;01
  &code_08A284   ;02
]

code_08A27F {
    COP [PrintWideString] ( &widestring_08A2EC )
    RTL 
}

code_08A284 {
    COP [PrintWideString] ( &widestring_08A4A9 )
    RTL 
}

widestring_08A289 `[DEF][TPL:0]The bones of a lost [N]explorer fascinated by [N]something...? [FIN]There's some kind of [N]journal... [N] Read [N] Quit[PAL:0]`

widestring_08A2EC `[CLR]       Ankor Wat[N]    Research Record[N][N]        Friezer[FIN]There is a temple where [N]a spirit is said to live. [FIN]In the Main Hall, second[N]floor, a bright room[N]blocks the way.[FIN]You must go through it [N]to reach the top [N]floor. The bright light [N]masks the corridor. [FIN]If you want to meet the [N]spirit, you must wear the [N]Black Crystal Glasses. [FIN]I saw something shining [N]on the ground near [N]the Main Hall, [N]but I had to run. [FIN]Probably the glasses[N]from the legend...[FIN]I regret coming here...[N]I hope my child can[N]carry on my dream... [END]`

widestring_08A4A9 `[CLD]`