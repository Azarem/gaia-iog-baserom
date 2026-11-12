; South Cape school teacher (Priest) who gives the opening narration.
; 
; At spawn the actor stands solid with the interact handler code_048AD9 (flag $21 clear: 'Please recite with me'; set: 'What is it, Will?'). With flag $10 clear it locks the joypad ($CFFC), waits 30 ticks (WaitByte #1D), prints Will's monologue, waits 60 ticks (WaitByte #3B), plays six sound pairs 31 ticks apart (JumpAfterDelay #$001E), waits 60 ticks, prints the lesson ('That's all for today's lesson'), waits 60 ticks and sets $10. That is the only flag it sets; sc08_erik releases the joypad lock after its walk. With $10 set at load the lesson is skipped and the joypad stays free; Lance, Erik and Seth die at spawn.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

sc08_priest [
  actor-def < #35, #00, #10, {

  code_048A8F:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_048AD9 )
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #10, #00, &code_048AA3 )
    COP [SetEntryHere]
    RTL 
} >
]

code_048AA3 {
    LDA #$CFFC
    TSB $joypadMaskStd
    LDA #$0400
    STA $gfxCacheIdxB
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_048AE9 )
    COP [WaitByte] ( #3B )
    COP [LoopStart] ( #06 )
    COP [PlaySoundBoth] ( #$0909 )
    COP [JumpAfterDelay] ( @code_048AC7, #$001E )
}

code_048AC7 {
    COP [LoopEnd]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_048C01 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #10 )
    COP [SetEntryHere]
    RTL 
}

code_048AD9 {
    COP [BranchOnFlagByte] ( #21, #01, &code_048AE4 )
    COP [PrintDialogString] ( &dialogstring_048C98 )
    RTL 
}

code_048AE4 {
    COP [PrintDialogString] ( &dialogstring_048CDB )
    RTL 
}

dialogstring_048AE9 `[DLG:3,6][SIZ:D,3][TPL:0][DLY:0]My name is Will.[FIN]A year has passed since[N]I went to the Tower of[N]Babel with my father.[FIN]My father and his party[N]met with disaster.[FIN]Somehow, I made it[N]back to South Cape...[FIN]I still can't believe[N]my father is gone.[N]I'll never believe it...[FIN]When I grow up, I'll[N]be an explorer and[N]see the world.[FIN]Somewhere, I will meet[N]my father...[END]`

dialogstring_048C01 `[DEF]Teacher:[N]That's all for[N]today's lesson.[FIN]You four do your best[N]not to fall behind.[FIN]Demons have appeared[N]outside of town. If you[N]go very far, you must[N]go with your parents.[END]`

dialogstring_048C98 `[DEF]Oh, Will. [N]Please recite with me.[FIN]The world shines[N]on brightly[N]through eternity....[END]`

dialogstring_048CDB `[DEF]What is it, Will? Looking[N]at your face, I wonder[N]if you're plotting[N]something again....[END]`