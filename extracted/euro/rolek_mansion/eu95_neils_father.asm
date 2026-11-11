; Neil's father at the Rolek mansion (scene $95): a Moon Tribe reveal triggered by the Teapot.
; 
; $A8 set: the actor dies at spawn. Otherwise it stands solid with 'You can't go wrong by taking over the Rolek Company.' and waits for $A8 (set by UseItem_Teapot when the Teapot is used in tiles (28,09)-(2D,0D) of this scene). Then it locks the player ($EFFC, joypadMaskStd reads $EFF0), waits 4 ticks (WaitByte #03), starts music #1B, waits (WaitByte #3B), clears its solidity, walks, prints 'Moon Tribe: Ku ku ku... Soon this world will be wrapped in darkness. The previous owner of this body is now a skeleton sleeping under the shrine...', walks toward (0268,0060), starts music #04, waits 120 ticks (WaitByte #77), unlocks the player and falls through into code_07E21A (COP Die). Neil's mother runs the same walk and dies earlier in the same visit.
---------------------------------------------

!joypadMaskStd                  065A
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

eu95_neils_father [
  actor-def < #02, #00, #10, {

  code_07E1BD:
    COP [BranchOnFlagByte] ( #A8, #01, &code_07E21A )
    LDA #$1200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07E21C )
    COP [NudgePosition] ( #00, #FE )
    COP [WaitOnFlagByte] ( #A8, #01 )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #03 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [ClearSolidHere]
    COP [NudgePosition] ( #00, #F0 )
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2F, #06 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_07E259 )
    LDA #$0268
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #01 )
    COP [StartMusic] ( #04 )
    COP [WaitByte] ( #77 )
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]

code_07E21A {
    COP [Die]
}

code_07E21C {
    COP [PrintDialogString] ( &dialogstring_07E221 )
    RTL 
}

dialogstring_07E221 `[TPL:A]Neil's father: You can't [N]go wrong by taking over [N]the Rolek Company.[END]`

dialogstring_07E259 `[TPL:B]Moon Tribe: Ku ku ku...[N]Soon this world will be[N]wrapped in darkness.[FIN]The previous owner of [N]this body is now a [N]skeleton sleeping [N]under the shrine. [END]`