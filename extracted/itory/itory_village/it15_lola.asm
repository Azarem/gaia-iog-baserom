?INCLUDE 'InitPlayerScriptVariant'

!joypadMaskStd                  065A

---------------------------------------------

it15_lola [
  actor-def < #32, #00, #10, {

  code_04F0A6:
    COP [SetOnInteract] ( &code_04F114 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #47, #01, &code_04F0C6 )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04F0C3 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #40, #26, #42, #28, &code_04F0CC )
    RTL 
} >
]

code_04F0C3 {
    COP [SetEntryContinue]
    RTL 
}

code_04F0C6 {
    COP [SetOnInteract] ( &code_04F119 )
    BRA code_04F0C3
}

code_04F0CC {
    COP [SetFlagByte] ( #3B )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0003
    JSL $@InitPlayerScriptVariant
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04F11E )
    COP [StageSpriteLoop] ( #32, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #08 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04F1BA )
    COP [StageSpriteLoop] ( #32, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #34, #08 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04F210 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_04F114 {
    COP [PrintDialogString] ( &dialogstring_04F249 )
    RTL 
}

code_04F119 {
    COP [PrintDialogString] ( &dialogstring_04F277 )
    RTL 
}

dialogstring_04F11E `[TPL:E][TPL:3]Lola: Will! Will! [N]Over here! [FIN][TPL:4]Bill:[N]You're safe.[N]Good...good...[FIN][TPL:3]Lola:[N]A terrible thing[N]happened to us![FIN]A man called the Jackal[N]came to the house [N]with some soldiers... [FIN][TPL:4]Bill: He[N]almost got us![PAL:0][END]`

dialogstring_04F1BA `[TPL:E][TPL:3]Lola: Grandpa [N]panicked. [FIN]I destroyed their [N]digestion with a [N]poisoned marsupial pie. [FIN]Then I ran away.[PAL:0][END]`

dialogstring_04F210 `[TPL:F][TPL:3]Lola: Lilly,  [N]thank you. I didn't [N]know that Princess [N]Kara came, too.[PAL:0][END]`

dialogstring_04F249 `[TPL:F][TPL:3]Lola: I'm afraid that[N]something bad[N]is going to happen.[PAL:0][END]`

dialogstring_04F277 `[TPL:F][TPL:3]Lola:[N]There's an old legend[N]in this village.[FIN]A child with a good[N]heart who controls the[N]Dark Power will set out[N]to save the world...[FIN]At that time, a huge[N]comet will enter Earth's[N]orbit, and a Dark Power[N]will arise...[FIN]These are the words of [N]the Itory legend.[PAL:0][END]`