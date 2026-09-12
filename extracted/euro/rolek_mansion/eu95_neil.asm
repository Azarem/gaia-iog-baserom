!gfxCacheIdxB                   064A

---------------------------------------------

eu95_neil [
  actor-def < #1A, #00, #10, {

  code_07E37D:
    COP [BranchIfFlagByte] ( #AA, #01, &code_07E390 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07E392 )
    COP [AddPosition] ( #00, #FE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07E390 {
    COP [Die]
}

code_07E392 {
    COP [BranchIfFlagByte] ( #A8, #01, &code_07E39D )
    COP [PrintDialogString] ( &dialogstring_07E3B5 )
    RTL 
}

code_07E39D {
    COP [PrintDialogString] ( &dialogstring_07E3F4 )
    COP [SetFlagByte] ( #AA )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #96, #$00A0, #$0090, #03, #$1100 )
    RTL 
}

dialogstring_07E3B5 `[TPL:B]Neil: [N]To live for yourself or [N]for others, that's the [N]question...[END]`

dialogstring_07E3F4 `[TPL:B][TPL:6][DLY:2]Neil: [N]. . . . . . . [FIN]I finally realize how[N]important my parents[N]are to me. I wish I could[N]have told them... [FIN]Will... [N]Just leave me alone [N]for a while... [FIN][TPL:0][DLY:1]I'm ashamed to hear you[N]talk that way...[N]I've never seen you[N]like this before.[END]`