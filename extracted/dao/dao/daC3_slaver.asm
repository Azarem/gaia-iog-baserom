; Slave trader guard in Dao — hostile to spectators.
; 
; NPC: "Hey, hey. This isn't a show!! Get out of here!"
; Guards the slave area and prevents the player from
; interfering with the labor trade.
---------------------------------------------

---------------------------------------------

daC3_slaver [
  actor-def < #1D, #00, #10, {

  code_08B2F0:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B302 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B302 {
    COP [PrintDialogString] ( &dialogstring_08B307 )
    RTL 
}

dialogstring_08B307 `[DEF]Hey, hey.[N]This isn't a show!![N]Get out of here![END]`