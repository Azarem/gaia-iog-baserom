; Rusty switch in the aqueduct hall that requires force.
; 
; Will cannot push it initially. Returns after getting Psycho Dash
; ability to force it open.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

ec0F_rusty_switch [
  actor-def < #0F, #01, #03, {

  code_0A8974:
    COP [SetMetasprite] ( @spriteset_enemies )

  loc_0A8979:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$00D8, #$0298, &code_0A899D )
    COP [BranchIfPlayerNear] ( #01, &code_0A898F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_0A8979
} >
]

code_0A898F {
    COP [PrintDialogString] ( &dialogstring_0A89BF )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_0A899C )
    BRA loc_0A8979
}

code_0A899C {
    RTL 
}

code_0A899D {
    COP [WaitByte] ( #0F )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [WaitByte] ( #0F )
    COP [BranchIfFlagWord] ( #$0104, #01, &code_0A89BC )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [StageBgChange] ( #04 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0104 )
}

code_0A89BC {
    COP [SetEntryContinue]
    RTL 
}

dialogstring_0A89BF `[TPL:E][TPL:0]It won't go in![N]Maybe it's rusty...[PAL:0][END]`