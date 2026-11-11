; Door of the Angel Village (scene $6B).
; 
; At spawn the actor writes $0F into four bytes of the collision tile map ($7FC568, $7FC56A, $7FCA52, $7FCA54), nudges itself by (8,0) and installs an interact handler. If the player is near (BranchIfPlayerNear #01) it opens at once; otherwise it waits for scratch flag $01, which the interact handler sets.
; 
; Opening plays sound #06 on channel 2, applies BgChange #45 and writes the shared phase word $0AA6 := 0 (the counter that the undersea-tunnel actors and the test scene read). The actor never closes the door and no persistent flag records it: every load of scene $6B starts with the door closed unless the player spawns next to it.
---------------------------------------------

---------------------------------------------

av6B_door [
  actor-def < #00, #00, #30, {

  code_06D748:
    SEP #$20
    LDA #$0F
    STA $7FC568
    STA $7FC56A
    STA $7FCA52
    STA $7FCA54
    REP #$20
    COP [NudgePosition] ( #08, #00 )
    COP [BranchIfPlayerNear] ( #01, &code_06D76F )
    COP [SetInteractHandler] ( &code_06D780 )
    COP [WaitOnFlagByte] ( #01, #01 )
} >
]

code_06D76F {
    COP [PlaySoundCh2] ( #06 )
    COP [StageBgChange] ( #45 )
    COP [ApplyBgChange]
    LDA #$0000
    STA $0AA6
    COP [SetEntryHere]
    RTL 
}

code_06D780 {
    COP [SetFlagByte] ( #01 )
    RTL 
}