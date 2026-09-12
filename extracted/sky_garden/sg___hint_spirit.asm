---------------------------------------------

sg___hint_spirit [
  actor-def < #3C, #00, #10, {

  code_05F4C4:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05F4D7 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    RTL 
} >
]

code_05F4D7 {
    COP [PrintDialogString] ( &dialogstring_05F4DC )
    RTL 
}

dialogstring_05F4DC `[DEF]Moon Tribe: [N]Attack when the Crystal [N]Bird cries. [END]`