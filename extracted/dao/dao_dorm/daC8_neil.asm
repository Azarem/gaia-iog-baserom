; Neil in the Dao dormitory — surprise reunion.
; 
; Extended NPC (~66 lines). "Will!! I never thought I'd meet
; you in a place like this!" Neil has become the Rolek Company
; representative: "I came to Dao to replace the labor trade
; with pepper imports." Shows Neil's growth and initiative.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

daC8_neil [
  actor-def < #12, #00, #10, {

  code_08A5B1:
    COP [BranchOnFlagByte] ( #D2, #01, &code_08A5ED )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08A5EF )
    COP [BranchOnFlagByte] ( #B4, #01, &code_08A5EA )
    COP [SetFlagByte] ( #B4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08A61D )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_08A5EA {
    COP [SetEntryHere]
    RTL 
}

code_08A5ED {
    COP [Die]
}

code_08A5EF {
    COP [BranchOnFlagByte] ( #D0, #01, &code_08A5FA )
    COP [PrintDialogString] ( &dialogstring_08A700 )
    RTL 
}

code_08A5FA {
    COP [PrintDialogString] ( &dialogstring_08A73C )
    LDA #$000B
    STA $0D60
    LDA #$0404
    STA $gfxCacheIdxB
    COP [StageWorldMapMove] ( #$0094, #$0114, #00, #21 )
    COP [QueueMapChange] ( #DC, #$0000, #$0000, #00, #$1100 )
    RTL 
}

dialogstring_08A61D `[TPL:B][TPL:6]Neil: Will!! I never [N]thought I'd meet you [N]in a place like this! [FIN][TPL:0]Neil! You've become [N]the company president?! [FIN][TPL:6]Neil: Yes. I [N]tried replacing the [N]labor trade with [N]pepper imports. [FIN]This led me all [N]the way to Dao. [FIN]There's a pyramid near [N]here. I wonder if a [N]Mystic Statue is there?[PAL:0][END]`

dialogstring_08A700 `[TPL:B][TPL:6]I came to Dao to replace [N]the labor trade with [N]pepper imports.[PAL:0][END]`

dialogstring_08A73C `[TPL:B][TPL:6]Neil: [N]Really.... [N]Do you have to go? [FIN]Once you make up your[N]mind to do something[N]nothing can stop you.[FIN]OK. I'll take Will to the [N]Tower of Babel, then [N]take Kara and Erik [N]to South Cape. [FIN]This time the airplane[N]won't crash![PAL:0][END]`