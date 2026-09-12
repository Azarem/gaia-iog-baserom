?INCLUDE 'f_inventory_full'
?INCLUDE 'interaction_handlers'
?INCLUDE 'oneshot_palette_flash_1B'
?INCLUDE 'oneshot_palette_flash_1C'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!displayModeFlags               09EC
!gemCount                       0AD6
!chatPtr                        7F000A

---------------------------------------------

ec0B_cell [
  actor-def < #23, #00, #38, {

  code_04D205:
    COP [BranchIfFlagByte] ( #24, #01, &code_04D30E )
    COP [SpawnLastRel] ( @code_04DB00, #00, #00, #$2000 )
    COP [SolidHighAbs] ( #0E, #11 )
    COP [SolidHighAbs] ( #0F, #11 )
    LDA #$0800
    TRB $10
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04D42F )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04D251, #$04B0 )
    LDA #$1000
    TSB $10
} >
]

code_04D251 {
    COP [PrintDialogString] ( &dialogstring_04D60A )
    COP [SpawnAfterAbsFlags] ( @code_04D346, #$0108, #$FFD0, #$1002 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04D275, #$0258 )
    LDA #$1000
    TSB $10
}

code_04D275 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04D679 )
    COP [WaitByte] ( #1D )
    COP [SpawnThinker] ( @oneshot_palette_flash_1B.code_00B7E2 )
    COP [WaitByte] ( #BF )
    COP [PrintDialogString] ( &dialogstring_04D732 )
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
    COP [WaitByte] ( #BF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04D78A )
    COP [DialogueOptions] ( #02, #02, &code_list_04D2A6 )
}

code_list_04D2A6 [
  &code_04D2AC   ;00
  &code_04D2AC   ;01
  &code_04D2AC   ;02
]

code_04D2AC {
    COP [PrintDialogString] ( &dialogstring_04D87D )
    COP [SpawnAfterAbsFlags] ( @code_04D408, #$00B8, #$FF70, #$0020 )
    COP [SetEntryContinue]
    LDA $gemCount
    BNE loc_04D2C3
    RTL 

  loc_04D2C3:
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04D8D2 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04D2D6, #$012C )
}

code_04D2D6 {
    LDA #$1000
    TSB $10
    LDA #$2000
    TRB $10
    COP [PrintDialogString] ( &dialogstring_04D4A5 )
    COP [StageSpriteLoopMoveY] ( #27, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_04D310, #$0000, #$FFF0, #$1000 )
    COP [ExitIfFlagByte] ( #23, #01 )
    COP [StageSpriteLoopMoveY] ( #26, #0E, #01 )
    COP [AnimLoop]
}

code_04D30E {
    COP [Die]
}

code_04D310 {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetOnInteract] ( &code_04D329 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #23, #01 )
    COP [Die]
}

code_04D329 {
    COP [PrintDialogString] ( &dialogstring_04D4B1 )
    COP [GiveItem] ( #02, &code_04D342 )
    COP [SetFlagByte] ( #23 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_04D5F4 )
    RTL 
}

code_04D342 {
    JML $@f_inventory_full.InventoryFullMessage
}

code_04D346 {
    LDA #$0800
    TRB $10
    COP [SetOnInteract] ( #$0000 )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoopMoveY] ( #2A, #03, #07 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteMoveY] ( #2A, #35 )
    COP [AnimOnce]
    COP [CollPriorityClearMax]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04D36F )
    COP [SetEntryContinue]
    RTL 
}

code_04D36F {
    COP [PrintDialogString] ( &dialogstring_04D37A )
    COP [SetFlagByte] ( #01 )
    COP [ClearLowHere]
    COP [Die]
}

dialogstring_04D37A `[DLG:3,11][SIZ:D,3]Will tastes some of[N]the bread.[FIN]The bread is hard.[N]It's the worst thing[N]he's ever tasted.[FIN]For some reason, he[N]really misses Grandma[N]Lola's creative cuisine...[END]`

code_04D408 {
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$0085
    STA $chatPtr, X
    COP [StageSpriteMoveY] ( #06, #07 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @interaction_handlers.collect_handler_gem, #$2300 )
    COP [StageSpriteMoveY] ( #06, #35 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
}

dialogstring_04D42F `[DLG:3,11][SIZ:D,3][TPL:0]Will: [N]I wonder why I have[N]to suffer so...[FIN]I wonder what will[N]become of me now.[FIN]Anyway, I have to[N]think of a way[N]to get out of here.[PAL:0][END]`

dialogstring_04D4A5 `[TPL:C]Oink oink[PAU:28][CLD]`

dialogstring_04D4B1 `[DLG:3,11][SIZ:D,4][TPL:0]Will: [N]I wonder if this [N]is Kara's pig...[FIN]What luck! There's a[N]letter and a key tied[N]to its tail...[FIN][TPL:F][PAL:0]The letter read...[FIN][TPL:1] Sorry to hear[N] that you're in prison.[FIN] It's terrible what my[N] father's done, but hear[N] what I have to say.[FIN] I too am a prisoner[N] --in a prison of silk[N] and gold. [FIN] But tonight I [N] will leave the castle[N] forever. [FIN] You also will [N] be free. [N]                  Kara[PAL:0][FIN]`

dialogstring_04D5F4 `[CLR][SFX:0][DLY:9]You have the key![PAU:FF][END]`

dialogstring_04D60A `[DLG:3,12][SIZ:D,3]A soldier's whisper[N]comes from a hole[N]in the ceiling.[FIN][DLG:3,12][SIZ:D,3]It's today's ration of[N]bread.[N]Even moss drinks water.[END]`

dialogstring_04D679 `[DLG:3,11][SIZ:D,4][TPL:0]Time passes slowly, but[N]the long day is ending.[FIN]It pains me to think of[N]the prisoners' feelings,[N]not knowing what they[N]should do....[FIN]While I was trying to[N]think of a way out,[N]I drifted off to sleep.[PAL:0][END]`

dialogstring_04D732 `[PAU:78][DLG:3,11][SIZ:D,3][DLY:0]A familiar voice[N]speaks from the flute.[FIN][TPL:E][TPL:4]Flute: [N]Will....[FIN]Flute:[N]This is your father.[END]`

dialogstring_04D78A `[PAU:3C][TPL:E][TPL:0][DLY:0]Will: [N]Father...? [FIN][TPL:4]Flute: You were[N]a cute child, but now[N]you've grown up.[FIN]Isn't Grandma Lola's[N]pie delicious?[FIN][TPL:0]Will: [N]Uh, sure, Dad![N]Where are you?![FIN][TPL:4]Flute:[N]I can't tell you now...[FIN][TPL:F][TPL:4]I have something to ask[N]of you. Listen...[N][PAL:0] Yes, if it's your wish![N] No! You deserted me!`

dialogstring_04D87D `[CLD][TPL:F][TPL:4][CLR][DLY:0]Flute:[N]I want you to[N]save me....[FIN]I, too, was once[N]held in this cell.[N]Look at the[N]left-hand wall.[END]`

dialogstring_04D8D2 `[DEF][TPL:0]Will: [N]...This? [FIN][TPL:4]Flute: Have you[N]heard anything[N]from Grandpa Bill?[FIN][TPL:0]Will: [N]Grandpa?[N]He was an architect...[FIN][TPL:4]Flute:[N]Your Grandpa knows the [N]secret of that stone.[FIN][TPL:0]Will: [N]Secret...?[FIN][TPL:4]Flute: Starting now,[N]you will encounter[N]a terrible thing.[FIN][TPL:0]Will: [N]Do I have to...?[FIN][TPL:4]Flute: Pick up the[N]stone your enemy left.[FIN]The power of the[N]Crystal is contained[N]there.[FIN]That power will prove[N]to be your ally....[FIN]You must make a[N]pilgrimage to the ruins[N]of the world to find [N]the Mystic Statues.[FIN]The closer you get to [N]the Crystal, [N]the stronger the evil[N]power will be...[FIN]Will... No time...[N]Quickly... First[N]to the Incan ruins...[FIN][PAL:0][SFX:10]The flute's voice fades[N]and disappears.[END]`

code_04DB00 {
    COP [AdhocVramDma] ( @gfx_000000+A00, #$4700, #$0200 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #00, #00, &code_04DB00 )
    RTL 
}