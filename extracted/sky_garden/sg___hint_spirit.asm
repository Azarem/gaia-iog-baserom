; Moon Tribe hint spirit in Sky Garden — combat advice.
; 
; Simple NPC that appears and gives the hint: "Attack when the
; Crystal Bird cries." Provides the key strategy for the
; Viper boss fight.
---------------------------------------------

---------------------------------------------

sg___hint_spirit [
  actor-def < #3C, #00, #10, {

  code_05F4C4:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05F4D7 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
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