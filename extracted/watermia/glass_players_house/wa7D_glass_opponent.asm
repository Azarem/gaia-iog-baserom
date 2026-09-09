!joypadMaskStd                  065A
!jewelsCollected                0AB0

---------------------------------------------

wa7D_glass_opponent [
  actor-def < #2C, #00, #10, {

  code_078D74:
    COP [BranchIfFlagByte] ( #95, #01, &code_078DB3 )
    COP [BranchIfFlagByte] ( #97, #01, &code_078D8F )
    COP [BranchIfFlagByte] ( #96, #01, &code_078DB3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_078DFC )
    COP [SetEntryContinue]
    RTL 
} >
]

code_078D8F {
    COP [SetFlagByte] ( #95 )
    LDA #$2000
    TSB $10
    COP [SetTilePos] ( #00, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_078E2D )
    COP [GiveItem] ( #18, &code_078DB5 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_078DB3 {
    COP [Die]
}

code_078DB5 {
    COP [BranchIfNoItem] ( #01, &code_078DBF )
    COP [BranchIfNoItem] ( #06, &code_078DE8 )
}

code_078DBF {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [RemoveItem] ( #01 )
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    COP [GiveItem] ( #18, &code_078DDC )
}

code_078DDC {
    COP [PrintWideString] ( &widestring_078F0B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_078DE8 {
    COP [RemoveItem] ( #06 )
    COP [GiveItem] ( #18, &code_078DF0 )
}

code_078DF0 {
    COP [PrintWideString] ( &widestring_078F69 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_078DFC {
    COP [PrintWideString] ( &widestring_078E01 )
    RTL 
}

widestring_078E01 `[TPL:A]Man: Cough, cough.[N]I seem to have caught[N]a little cold.[END]`

widestring_078E2D `[TPL:B]Woman:[N]You're the Russian[N]Glass player.[FIN]My husband said that once [N]he found a job we would be[N]OK, but I was surprised [N]at what he did. [FIN]This is my husband's [N]will. It says here [N]"To My Opponentˮ. [N]Please read it. [FIN]There are four Kruks[N]outside. [N]Please use them. [END]`

widestring_078F0B `[TPL:B]Woman: Oh. Your[N]inventory is full.[FIN]I'll hold on to one of[N]your Red Jewels. Don't[N]worry, I'll take it[N]to the jeweler.[END]`

widestring_078F69 `[TPL:B]Woman: Oh. Your[N]inventory is full.[FIN]I'll hold on to one of[N]your Red Jewels. Don't[N]worry, I'll take it[N]to the jeweler.[END]`