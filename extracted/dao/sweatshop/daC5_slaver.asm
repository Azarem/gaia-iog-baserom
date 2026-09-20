; Carpet sweatshop overseer in Dao — explains the 40-year weaving.
; 
; NPC: "These women are weaving carpets. This will take almost
; 40 years to weave. This woman has worked her entire life."
; Shows the human cost of the luxury carpet trade.
---------------------------------------------

---------------------------------------------

daC5_slaver [
  actor-def < #1D, #00, #10, {

  code_08B3A5:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B3B7 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B3B7 {
    COP [PrintDialogString] ( &dialogstring_08B3BC )
    RTL 
}

dialogstring_08B3BC `[TPL:E]These women are[N]weaving carpets.[FIN]This will take almost[N]40 years to weave.[FIN]This woman has worked[N]on it continuously since[N]she was a child.[FIN]Remember, little man.[N]Some are born to[N]misfortune.[END]`