; Descent cutscene — the party escapes the falling Sky Garden.
; 
; Scripted sequence where Neil's airplane attempts to catch
; the falling party. Manages character sprite movement,
; camera control, and the transition to the ocean scenes.
; Leads into the Mu chapter.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!TM                             212C

---------------------------------------------

sp58_descent_cutscene [
  actor-def < #00, #02, #18, {

  code_068114:
    LDA #$1000
    TSB $12
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA #$EFF0
    TSB $joypadMaskStd
    LDA $0AA6
    BNE loc_068183
    COP [SpawnAfterFlags] ( @code_068185, #$2000 )

  code_068140:
    COP [StageSpriteMoveY] ( #00, #11 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #01, #00, &code_068140 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearFlagByte] ( #02 )
    LDA #$FFF0
    STA $16
    COP [StageSpriteLoopMoveY] ( #00, #34, #11 )
    COP [AnimLoop]
    COP [PlaySoundBoth] ( #$2C2C )
    COP [StageSpriteLoopMoveX] ( #02, #A0, #02 )
    COP [AnimLoop]
    LDA #$0002
    STA $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #80, #$1100 )
    COP [SetEntryContinue]
    RTL 

  loc_068183:
    COP [Die]
} >
]

code_068185 {
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [Die]
}