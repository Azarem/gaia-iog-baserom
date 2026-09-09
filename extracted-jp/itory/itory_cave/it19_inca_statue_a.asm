---------------------------------------------

h_it19_inca_statue_a [
  actor-def < #00, #00, #30, {

  code_04EAF9:
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04EB10 )
    COP [ExitIfFlagByte] ( #2D, #01 )
    COP [StageBgChange] ( #1B )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$011B )
    COP [Die]
} >
]

code_04EB10 {
    COP [GiveItem] ( #03, &code_04EB25 )
    COP [SetFlagByte] ( #2D )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_04EB2A )
    RTL 
}

code_04EB25 {
    COP [PrintWideString] ( &widestring_04EB46 )
    RTL 
}

widestring_04EB2A `[TPL:A][SFX:0][DLY:9]インカの像Aを 手に入れた.[PAU:FF][END]`

widestring_04EB46 `[TPL:A]インカの像Aを 見つけた![N]しかし 持ち物が いっぱいだった.[END]`