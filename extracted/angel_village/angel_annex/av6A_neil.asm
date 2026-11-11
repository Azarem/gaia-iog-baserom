; Neil in the Angel Village annex (scene $6A); he offers the trip to Watermia once the party is reunited.
; 
; At spawn: flag $8D set -> dies. Flag $A9 (reunion done) set -> code_06C065: placed at tile (17,0E) in frame #15 with the handler code_06C077. Flag $8C (Kara rescued) set and $A9 clear -> code_06C056: starts at tile (0F,0E), walks four steps and falls into code_06C065. Otherwise: installs the 'I think the Angels are descendants of the Mu people.' handler.
; 
; code_06C077 asks 'Can we go now? Yes / Wait a minute'. Yes (row 1) prints 'I think it's very hot in the Floating City...', stages world-map move route #11 and queues scene $78 (Watermia) at (0250,0370); the other answers print 'There's no hurry. Take your time.'
---------------------------------------------

!gfxCacheIdxB                   064A

---------------------------------------------

av6A_neil [
  actor-def < #15, #00, #10, {

  code_06C03B:
    COP [BranchOnFlagByte] ( #8D, #01, &av6A_neil_destroy )
    COP [BranchOnFlagByte] ( #A9, #01, &code_06C065 )
    COP [BranchOnFlagByte] ( #8C, #01, &code_06C056 )
    COP [SetInteractHandler] ( &code_06C0CD )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_06C056 {
    COP [SetTilePos] ( #0F, #0E )
    COP [MarkSolidHere]
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #19, #04, #01 )
    COP [AnimLoop]
}

code_06C065 {
    COP [SetTilePos] ( #17, #0E )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_06C077 )
    COP [SetEntryHere]
    RTL 
}

code_06C077 {
    COP [PrintDialogString] ( &dialogstring_06C10D )
    COP [DialogueOptions] ( #02, #01, &code_list_06C081 )
}

code_list_06C081 [
  &code_06C087   ;00
  &code_06C08C   ;01
  &code_06C087   ;02
]

code_06C087 {
    COP [PrintDialogString] ( &dialogstring_06C136 )
    RTL 
}

code_06C08C {
    COP [PrintDialogString] ( &dialogstring_06C15C )
    LDA #$0000
    STA $0D60
    LDA #$0001
    STA $0D62
    LDA #$0002
    STA $0D64
    LDA #$0003
    STA $0D66
    LDA #$0004
    STA $0D68
    LDA #$0005
    STA $0D6A
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0384, #$0164, #00, #11 )
    COP [QueueMapChange] ( #78, #$0250, #$0370, #06, #$4500 )
    RTL 
}

code_06C0CD {
    COP [PrintDialogString] ( &dialogstring_06C0D2 )
    RTL 
}

dialogstring_06C0D2 `[TPL:A][TPL:6]Neil: I think the Angels [N]are descendants of the [N]Mu people.[PAL:0][END]`

dialogstring_06C10D `[TPL:A][TPL:6]Neil: Can we go now? [N] Yes [N] Wait a minute `

dialogstring_06C136 `[CLR]Neil: [N]There's no hurry. [N]Take your time.[PAL:0][END]`

dialogstring_06C15C `[CLR]Neil: [N]I think it's very hot [N]in the Floating City. [FIN]Everyone be careful not[N]to get heat stroke.[PAL:0][END]`
---------------------------------------------

av6A_neil_destroy {
    COP [Die]
}