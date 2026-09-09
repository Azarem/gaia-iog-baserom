!playerMaxHp                    0ACA

---------------------------------------------

fr32_hp_jewel [
  actor-def < #25, #00, #10, {

  code_05CF88:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05CF96 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05CF96 {
    COP [BranchIfFlagByte] ( #54, #01, &code_05CFA6 )
    COP [SetFlagByte] ( #54 )
    COP [PrintWideString] ( &widestring_05CFA7 )
    INC $playerMaxHp
}

code_05CFA6 {
    RTL 
}

widestring_05CFA7 `[DEF]You found the HP jewel![END]`