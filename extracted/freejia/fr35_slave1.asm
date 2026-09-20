; Chained slave in the Freejia labor cells — resigned dialog.
; 
; Static NPC. Says: "Soon we will be sent away..." Represents
; one of the laborers awaiting sale in the slave market.
---------------------------------------------

---------------------------------------------

fr35_slave1 [
  actor-def < #27, #00, #10, {

  code_05C378:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C386 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C386 {
    COP [PrintDialogString] ( &dialogstring_05C38B )
    RTL 
}

dialogstring_05C38B `[TPL:9]Soon we will be sent [N]away...[END]`