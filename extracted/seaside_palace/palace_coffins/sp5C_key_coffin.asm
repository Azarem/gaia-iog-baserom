; Key coffin in the Seaside Palace — puzzle with Lilly.
; 
; Interactive coffin (~95 lines). Will: "The coffins are lined
; up..." Later: "I can't seem to open the lid..." Lilly speaks
; from Will's pocket: "Wait a minute. Isn't there a hole in
; the coffin?" Lilly enters through a small hole to retrieve
; the key from inside. Uses the spirit companion mechanic.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!joypadMaskStd                  065A
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sp5C_key_coffin [
  actor-def < #00, #02, #30, {

  code_068FEE:
    COP [BranchIfFlagWord] ( #$013A, #01, &code_069092 )
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_069094 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @spriteset_enemies )
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [StageSpriteLoopMoveX] ( #33, #04, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$0300
    STA $moveXAlt, X
    LDA #$009C
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3B )
    COP [StageBgChange] ( #3A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$013A )
    COP [WaitByte] ( #3B )
    LDA #$0300
    STA $14
    LDA #$00A0
    STA $16
    LDA #$2000
    TRB $10
    COP [PrintDialogString] ( &dialogstring_069167 )
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
    LDA #$2000
    TSB $10
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_069092 {
    COP [Die]
}

code_069094 {
    COP [BranchIfFlagByte] ( #6F, #01, &code_06909F )
    COP [PrintDialogString] ( &dialogstring_0690A7 )
    RTL 
}

code_06909F {
    COP [PrintDialogString] ( &dialogstring_0690CF )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_0690A7 `[DEF][TPL:0]Will: The coffins are [N]lined up...[PAL:0][END]`

dialogstring_0690CF `[DEF][TPL:0]Will: [N]I can't seem to open [N]the lid... [FIN][TPL:2]Lilly speaks from[N]his pocket.[FIN][TPL:2]Lilly: Wait a minute.[N]Isn't there a hole in[N]the coffin?[FIN]I could get in through [N]the hole. I better [N]have a look.[PAL:0][END]`

dialogstring_069167 `[DEF][TPL:2]Lilly: Strange...[N]There's a key fastened[N]inside this coffin. No[N]wonder it didn't open.[PAL:0][END]`