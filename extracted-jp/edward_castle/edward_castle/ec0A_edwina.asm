---------------------------------------------

e_ec0A_edwina [
  actor-def < #2B, #00, #18, {

  code_04C0F5:
    LDA #$0200
    TSB $12
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &code_04C10C )
    COP [WaitOnFlagByte] ( #0B, #01 )
    COP [SetFlagByte] ( #0C )
    COP [SetEntryHere]
    RTL 
} >
]

code_04C10C {
    COP [PrintDialogString] ( &dialogstring_04C111 )
    RTL 
}

dialogstring_04C111 `[DEF][TPL:3]エドワード王后:[N]あなたに手紙を送ったのは 国王よ.[N]あの人に 話しかけてちょうだい.[PAL:0][END]`