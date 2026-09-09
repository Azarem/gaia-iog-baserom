!joypadMaskStd                  065A
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

eu95_neils_father [
  actor-def < #02, #00, #10, {

  code_07E1BD:
    COP [BranchIfFlagByte] ( #A8, #01, &code_07E21A )
    LDA #$1200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07E21C )
    COP [AddPosition] ( #00, #FE )
    COP [ExitIfFlagByte] ( #A8, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [ClearLowHere]
    COP [AddPosition] ( #00, #F0 )
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2F, #06 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_07E259 )
    LDA #$0268
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #01 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #77 )
    LDA #$EFF0
    TRB $joypadMaskStd
} >
]

code_07E21A {
    COP [Die]
}

code_07E21C {
    COP [PrintWideString] ( &widestring_07E221 )
    RTL 
}

widestring_07E221 `[TPL:A]Neil's father: You can't [N]go wrong by taking over [N]the Rolek Company.[END]`

widestring_07E259 `[TPL:B]Moon Tribe: Ku ku ku...[N]Soon this world will be[N]wrapped in darkness.[FIN]The previous owner of [N]this body is now a [N]skeleton sleeping [N]under the shrine. [END]`