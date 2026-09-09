---------------------------------------------

h_it1B_inca_statue_b [
  actor-def < #00, #00, #30, {

  code_04F1E0:
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04F1F7 )
    COP [ExitIfFlagByte] ( #48, #01 )
    COP [StageBgChange] ( #1D )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011D )
    COP [Die]
} >
]

code_04F1F7 {
    COP [GiveItem] ( #04, &code_04F20C )
    COP [SetFlagByte] ( #48 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_04F211 )
    RTL 
}

code_04F20C {
    COP [PrintWideString] ( &widestring_04F232 )
    RTL 
}

widestring_04F211 `[DLG:3,6][SIZ:D,3,0][SFX:0][DLY:9]インカの像Bを 手に入れた.[PAU:FF][END]`

widestring_04F232 `[DLG:3,6][SIZ:D,3,0]インカの像Bを 見つけた![N]しかし 持ち物が いっぱいだった.[END]`