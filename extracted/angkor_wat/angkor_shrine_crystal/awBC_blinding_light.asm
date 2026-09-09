?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'

!joypadMaskStd                  065A

---------------------------------------------

awBC_blinding_light [
  actor-def < #00, #00, #30, {

  code_089A1F:
    COP [BranchIfFlagByte] ( #B7, #01, &code_089A3B )
    COP [SetFlagByte] ( #B7 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_089A65 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_089A3B {
    COP [BranchIfEquipped] ( #1C, &code_089A5B )
    COP [WaitByte] ( #13 )

  loc_089A43:
    COP [SpawnThinker] ( @oneshot_palette_flash_18.code_00B7CE )
    COP [WaitByte] ( #B3 )
    COP [SetEntryContinue]
    COP [BranchIfEquipped] ( #1C, &code_089A53 )
    RTL 
}

code_089A53 {
    COP [SpawnThinker] ( @oneshot_palette_flash_19.code_00B7D8 )
    COP [WaitByte] ( #B3 )
}

code_089A5B {
    COP [SetEntryContinue]
    COP [BranchIfEquipped] ( #1C, &code_089A64 )
    BRA loc_089A43
}

code_089A64 {
    RTL 
}

widestring_089A65 `[DEF][TPL:0]Setting one foot inside,[N]the floating crystal[N]started to glow![PAL:0][END]`