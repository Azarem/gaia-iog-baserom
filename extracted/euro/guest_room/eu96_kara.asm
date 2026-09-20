; Kara in the Euro guest room — impressed by the town's wealth.
; 
; Multi-dialog NPC. "What a big house! The townspeople seem
; to be richer than the King." Later mentions Angkor Wat
; ruins to the west. Story progression dialog.
---------------------------------------------

!gfxCacheIdxB                   064A

---------------------------------------------

eu96_kara [
  actor-def < #1A, #00, #10, {

  code_07D988:
    COP [BranchOnFlagByte] ( #AC, #01, &code_07D9C4 )
    COP [BranchOnFlagByte] ( #AB, #01, &code_07D9BB )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07D9C6 )
    COP [NudgePosition] ( #00, #FE )
    COP [WaitOnFlagByte] ( #AA, #01 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
} >
]

code_07D9BB {
    COP [SetInteractHandler] ( &code_07D9CB )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_07D9C4 {
    COP [Die]
}

code_07D9C6 {
    COP [PrintDialogString] ( &dialogstring_07DA00 )
    RTL 
}

code_07D9CB {
    COP [PrintDialogString] ( &dialogstring_07DA3D )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0004
    STA $0D64
    LDA #$0006
    STA $0D66
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$01D4, #$0134, #00, #19 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    RTL 
}

dialogstring_07DA00 `[TPL:B][TPL:1]Kara: What a big house! [N]The townspeople [N]seem to be richer [N]than the King...[PAL:0][END]`

dialogstring_07DA3D `[TPL:A][TPL:1]Kara: To the west of [N]here are the ruins of [N]Ankor Wat. [FIN]That is where the[N]laborer's home is[N]located.[FIN]Let's go![PAL:0][END]`