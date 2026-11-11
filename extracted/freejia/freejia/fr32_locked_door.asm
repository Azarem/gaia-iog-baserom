; Locked door in Freejia (scene $32).
; 
; Solid door actor. It tests no flag and applies no background change. At spawn, when Will is within #01 tile (BranchIfPlayerNear), it shows frame #00, sets the joypad lock ($CFFC) for #1D ticks and plays sound #0E; then (and otherwise at once) it shows frame #01, marks itself solid and sets the talk handler, which always prints 'It's locked from the inside...'.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

!joypadMaskStd                  065A

---------------------------------------------

fr32_locked_door [
  actor-def < #01, #00, #18, {

  code_05CFBF:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [SetSpritePriority] ( #20 )
    COP [BranchIfPlayerNear] ( #01, &code_05CFDF )

  loc_05CFD1:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05CFF8 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05CFDF {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh2] ( #0E )
    LDA #$CFFC
    TRB $joypadMaskStd
    BRA loc_05CFD1
}

code_05CFF8 {
    COP [PrintDialogString] ( &dialogstring_05CFFD )
    RTL 
}

dialogstring_05CFFD `[DEF]Will: [N]It's locked from [N]the inside... [END]`