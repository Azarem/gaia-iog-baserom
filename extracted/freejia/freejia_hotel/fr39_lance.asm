; Lance at the Freejia hotel — amnesia subplot after Incan ship escape.
; 
; Complex NPC (~117 lines). Says: "They say I don't know who I am.
; Kind of strange..." Later: "What is this place?" — Lance has
; amnesia from hitting his head. Kara comments: "Somehow I feel
; a little..." Dialog tracks the Memory Melody quest to cure him.
---------------------------------------------

?INCLUDE 'actor_pool'
?INCLUDE 'spriteset_enemies'

!joypadMaskStd                  065A

---------------------------------------------

fr39_lance [
  actor-def < #02, #00, #10, {

  code_05C781:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C7E7 )
    COP [ExitIfFlagByte] ( #0F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [SpawnAfterFlags] ( @code_05CD16, #$2800 )
    COP [WaitByte] ( #77 )
    COP [SetSpritePriority] ( #30 )
    COP [PrintDialogString] ( &dialogstring_05C85E )
    COP [ClearFlagByte] ( #0F )
    COP [SpawnThinkerParam] ( #1C, @actor_pool.PaletteResetAndKillThinker )
    COP [SetSpritePriority] ( #20 )
    COP [WaitByte] ( #77 )
    COP [FadeThenStartMusic] ( #02 )
    COP [WaitWord] ( #$012B )
    COP [StageSpriteLoop] ( #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #28 )
    COP [AnimLoop]
    COP [WaitWord] ( #$012B )
    COP [PrintDialogString] ( &dialogstring_05CA69 )
    COP [SetFlagByte] ( #68 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C7E7 {
    COP [BranchIfFlagByte] ( #68, #01, &code_05C7F5 )
    COP [SetFlagByte] ( #02 )
    COP [PrintDialogString] ( &dialogstring_05C7FA )
    RTL 
}

code_05C7F5 {
    COP [PrintDialogString] ( &dialogstring_05CAEC )
    RTL 
}

dialogstring_05C7FA `[TPL:A][TPL:4]Lance: They say I don't [N]know who I am. [N]Kind of strange.... [FIN]If I don't know who I[N]am, how did I get here?[PAL:0][END]`

dialogstring_05C85E `[TPL:B][TPL:4][DLY:2]Lance: [N]What is this place? [FIN][TPL:1]Kara: Somehow I feel [N]a little homesick... [FIN][TPL:3]Erik: [N]I feel like I'm back in [N]the womb.... [FIN][TPL:2]Lilly: Everything[N]that's happened and the[N]people I've met are[N]pouring into my head...[FIN][TPL:4]Lance: I was raised in [N]the town of South Cape. [FIN]When my father [N]didn't come back [N]from an expedition... [FIN]The most important thing [N]in my life was gone. I [N]didn't know what to do. [FIN][TPL:1]Kara: I couldn't [N]stand my father using [N]soldiers to invade [N]other countries. [FIN]It's awful when someone[N]loses their life.[FIN]What had taken years[N]to put together was[N]destroyed in one moment.[FIN][TPL:3]Erik: I wonder if Seth [N]is all right...? [FIN][TPL:2]Lilly: People live on[N]because they forget[N]about unpleasant things.[PAL:0][END]`

dialogstring_05CA69 `[TPL:A][TPL:4]Lance: What? What have I [N]been doing? What's [FIN]happened to everyone? [FIN][TPL:2]Lilly: Lance! [N]Your memory is back! [FIN][TPL:1]Kara: [N]I was worried! [FIN][TPL:3]Erik: I wondered [N]what would happen.[PAL:0][END]`

dialogstring_05CAEC `[TPL:B][TPL:4]Lance: I guess everyone [N]was worried. I'd take [N]care of someone in the [N]same situation.[PAL:0][END]`
---------------------------------------------

code_05CD16 {
    COP [SpawnAfterFlags] ( @code_05CD30, #$0B01 )
    COP [RngByte]
    AND #$0003
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #0F, #01, &code_05CD16 )
    COP [Die]
}

code_05CD30 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePriority] ( #30 )
    LDA #$0200
    STA $16
    COP [RngByte]
    CLC 
    ADC #$0100
    STA $14
    AND #$0003
    BEQ loc_05CD6B
    DEC 
    BEQ loc_05CD62
    DEC 
    BEQ loc_05CD59
    COP [StageSpriteLoopMoveY] ( #02, #10, #04 )
    COP [AnimLoop]
    COP [Die]

  loc_05CD59:
    COP [StageSpriteLoopMoveY] ( #02, #08, #08 )
    COP [AnimLoop]
    COP [Die]

  loc_05CD62:
    COP [StageSpriteLoopMoveY] ( #02, #06, #0C )
    COP [AnimLoop]
    COP [Die]

  loc_05CD6B:
    COP [StageSpriteLoopMoveY] ( #02, #04, #10 )
    COP [AnimLoop]
    COP [Die]
}