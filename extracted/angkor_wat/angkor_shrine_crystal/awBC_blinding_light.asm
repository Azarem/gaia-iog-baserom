; Crystal shrine light of Angkor Wat (scene $BC). The first time ($B7 clear) the actor sets $B7, locks the player ($CFFC), waits 29 frames, prints 'Setting one foot inside, the floating crystal started to glow!' and unlocks. Whether or not the narration ran, it then tests the Black Crystal Glasses (item $1C): with the glasses equipped at that moment no flash runs. Otherwise it waits 19 frames, spawns oneshot_palette_flash_18, waits 179 frames and polls the equip test every frame; when the glasses are equipped it spawns oneshot_palette_flash_19 once and parks in a polling loop that spawns flash 18 again only if the glasses are unequipped later.
---------------------------------------------

?INCLUDE 'oneshot_palette_flash_18'
?INCLUDE 'oneshot_palette_flash_19'

!joypadMaskStd                  065A

---------------------------------------------

awBC_blinding_light [
  actor-def < #00, #00, #30, {

  code_089A1F:
    COP [BranchOnFlagByte] ( #B7, #01, &code_089A3B )
    COP [SetFlagByte] ( #B7 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_089A65 )
    LDA #$CFFC
    TRB $joypadMaskStd
} >
]

code_089A3B {
    COP [BranchIfItemEquipped] ( #1C, &code_089A5B )
    COP [WaitByte] ( #13 )

  loc_089A43:
    COP [SpawnThinker] ( @oneshot_palette_flash_18.FlashPalette18 )
    COP [WaitByte] ( #B3 )
    COP [SetEntryHere]
    COP [BranchIfItemEquipped] ( #1C, &code_089A53 )
    RTL 
}

code_089A53 {
    COP [SpawnThinker] ( @oneshot_palette_flash_19.FlashPalette19 )
    COP [WaitByte] ( #B3 )
}

code_089A5B {
    COP [SetEntryHere]
    COP [BranchIfItemEquipped] ( #1C, &code_089A64 )
    BRA loc_089A43
}

code_089A64 {
    RTL 
}

dialogstring_089A65 `[DEF][TPL:0]Setting one foot inside,[N]the floating crystal[N]started to glow![PAL:0][END]`