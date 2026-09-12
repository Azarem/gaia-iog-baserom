?INCLUDE 'table_0EDA00'

!joypadMaskStd                  065A

---------------------------------------------

fr32_locked_door [
  actor-def < #01, #00, #18, {

  code_05CFBF:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [SetSpritePriority] ( #20 )
    COP [BranchIfPlayerNear] ( #01, &code_05CFDF )

  loc_05CFD1:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05CFF8 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CFDF {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundCh2] ( #0E )
    LDA #$CFF0
    TRB $joypadMaskStd
    BRA loc_05CFD1
}

code_05CFF8 {
    COP [PrintDialogString] ( &dialogstring_05CFFD )
    RTL 
}

dialogstring_05CFFD `[DEF]Will: [N]It's locked from [N]the inside... [END]`