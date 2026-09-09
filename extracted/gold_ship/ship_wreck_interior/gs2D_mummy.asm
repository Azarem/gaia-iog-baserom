?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A

---------------------------------------------

gs2D_mummy [
  actor-def < #00, #00, #10, {

  code_058B1E:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_058B38 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058B38 {
    COP [BranchIfFlagByte] ( #01, #01, &code_058B47 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #01 )
}

code_058B47 {
    COP [PrintWideString] ( &widestring_058B4F )
    COP [SetFlagByte] ( #02 )
    RTL 
}

widestring_058B4F `[TPL:A][TPL:0]The Queen's mummy[N]sleeps silently.[FIN]There's a gold ring [N]on her long, slender, [N]bony finger...[PAL:0][END]`