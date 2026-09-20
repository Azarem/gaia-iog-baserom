; Red Eye event — Neil comments on the close call and heads to Mu.
; 
; Multi-dialog NPC. Neil: "That was a close one!" Kara cries.
; Then Neil suggests: "Well, to the ocean! Mu lies somewhere
; in this ocean." Transitions the story toward the Mu chapter.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

sp58_red_eye [
  actor-def < #07, #00, #18, {

  code_068193:
    LDA #$1000
    TSB $12
    LDA $0AA6
    CMP #$0002
    BNE loc_06821A
    COP [WaitByte] ( #01 )
    COP [FadeThenStartMusic] ( #02 )
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0001
    STA $002C, Y
    LDA #$0000
    STA $002E, Y
    COP [SpawnAfterFlags] ( @code_06821C, #$2000 )
    LDA $14
    SEC 
    SBC #$009C
    STA $14
    COP [StageSpriteLoopMoveX] ( #07, #68, #13 )
    COP [AnimLoop]

  loc_0681E3:
    COP [BranchOnFlagByte] ( #01, #01, &code_0681F0 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    BRA loc_0681E3
} >
]

code_0681F0 {
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$0002
    STA $002C, Y
    COP [StageSpriteLoopMoveX] ( #07, #3C, #11 )
    COP [AnimLoop]
    JSL $@cop_handlers_flags.ClearAllWramFlags
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #59, #$0000, #$0000, #00, #$1100 )

  loc_06821A:
    COP [Die]
}

code_06821C {
    COP [WaitWord] ( #$012B )
    COP [PrintDialogString] ( &dialogstring_068230 )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_06834A )
    COP [Die]
}

dialogstring_068230 `[TPL:A][TPL:6]Neil: [N]That was a close one! [FIN][TPL:1]Kara: [N]Sob...sob... [FIN][TPL:3]Erik: [N]Sniff...sniff... [FIN][TPL:4]Lance: Don't cry. [N]Will's been saved. [FIN][TPL:2]Lilly: Neil, you were [N]great. This invention [N]saved Will's life! [FIN][TPL:6]Neil: Ha ha. [N]Don't flatter me. [FIN]We should try and [N]locate the next ruins. [FIN]I expect the shape of[N]Cygnus is the same as[N]the shape of Mu.[END]`

dialogstring_06834A `[TPL:A][TPL:6]Neil: [N]Well, to the ocean! [FIN]Mu lies somewhere[N]in this ocean.[END]`