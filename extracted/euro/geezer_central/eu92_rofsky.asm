!joypadMaskStd                  065A

---------------------------------------------

eu92_rofsky [
  actor-def < #24, #00, #10, {

  code_07D5EA:
    COP [BranchIfFlagByte] ( #9E, #01, &code_07D606 )
    COP [SetFlagByte] ( #9E )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07D6C2 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07D606 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07D60F )
    COP [SetEntryContinue]
    RTL 
}

code_07D60F {
    COP [BranchIfNoItem] ( #19, &code_07D619 )
    COP [PrintWideString] ( &widestring_07D61E )
    RTL 
}

code_07D619 {
    COP [PrintWideString] ( &widestring_07D764 )
    RTL 
}

widestring_07D61E `[TPL:B][TPL:3]Rofsky:[N]There is a dispute about[N]the teapot enshrined[N]at Mt.Kress temple.[FIN]On Mt.Kress, there are [N]enshrined tears once [N]shed by a spirit. Legend[N]says they save people.[PAL:0][END]`

widestring_07D6C2 `[TPL:9][TPL:0]Two old people are[N]arguing about something.[WAI][CLD][PAU:1E][TPL:B][TPL:3]Rofsky:[N]True genius is a violent[N]thing![N]It sounds like a tempest![FIN][TPL:3][TPL:4]Erasquez:[N]You just dash off[N]packs of lies!![N]Don't brag![END]`

widestring_07D764 `[TPL:A][TPL:3]Rofsky:[N]Oh, that's the Teapot...[N]It really does exist...[PAL:0][END]`