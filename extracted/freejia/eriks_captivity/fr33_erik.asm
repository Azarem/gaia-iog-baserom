; Erik imprisoned in Freejia — rescue cutscene.
; 
; Erik is held captive. On first interaction: "Impossible! You've
; come to rescue me!!" Triggers the rescue sequence with flag
; checks and joypad lock. Key story event where the party
; reunites with Erik after his capture.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

fr33_erik [
  actor-def < #0A, #00, #10, {

  code_05CD77:
    COP [BranchIfFlagByte] ( #65, #01, &code_05CDA3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CDA5 )
    COP [ExitIfFlagByte] ( #65, #01 )
    COP [ClearLowHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #10, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #06, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_05CDA3 {
    COP [Die]
}

code_05CDA5 {
    COP [PrintDialogString] ( &dialogstring_05CDBC )
    COP [SetFlagByte] ( #57 )
    COP [SetFlagByte] ( #58 )
    COP [SetFlagByte] ( #64 )
    COP [SetFlagByte] ( #65 )
    LDA #$0007
    STA $0AA6
    RTL 
}

dialogstring_05CDBC `[TPL:E][TPL:3]Erik: [N]Impossible! You've come [N]to rescue me!! [FIN]I didn't think you could [N]break down the door! [FIN]The man ran away, [N]scared. [FIN]I tried to sneak into the[N]camp to rescue three[N]laborer brothers.[FIN]I was discovered, and[N]now I'm like this...[FIN]The laborers were[N]forced to work in[N]the diamond mine.[FIN]I'll tell you where. [N]Please save them! [FIN]Will learns the[N]location of the mine![N][PAL:0][END]`