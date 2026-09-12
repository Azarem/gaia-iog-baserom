---------------------------------------------

fr32_slap [
  actor-def < #02, #00, #10, {

  code_05B57F:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #08, #04 )
    COP [SetOnInteract] ( &code_05B58E )
    COP [WaitWhileOffscreen] ( #08 )
    RTL 
} >
]

code_05B58E {
    COP [PrintDialogString] ( &dialogstring_05B59B )
    COP [PlaySoundBoth] ( #$0505 )
    COP [PrintDialogString] ( &dialogstring_05B60C )
    RTL 
}

dialogstring_05B59B `[DEF]I was startled....[N]Someone dropped[N]from the ceiling.[FIN]Thanks for showing [N]me that impressive  [N]dive. I will give [N]you something. [FIN]`

dialogstring_05B60C `[CLR][TPL:7]"Slap!!!!!!ˮ[FIN][PAL:0]Kids! If you do [N]something this dangerous [N]again, you'll be in [N]big trouble!!! [END]`