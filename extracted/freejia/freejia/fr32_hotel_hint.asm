; Woman near the hotel — hints about the kidnapped worker.
; 
; NPC who says: "A man working at the hotel was caught by
; a labor trader." Hints at the slave trade infiltrating
; everyday life in Freejia.
---------------------------------------------

---------------------------------------------

fr32_hotel_hint [
  actor-def < #12, #00, #10, {

  code_05B666:
    COP [SetSpritePriority] ( #10 )
    COP [SpawnAfterRelFlags] ( @code_05B67C, #$0000, #$0018, #$3000 )
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    RTL 
} >
]

code_05B67C {
    COP [SetOnInteract] ( &code_05B683 )
    COP [SetEntryContinue]
    RTL 
}

code_05B683 {
    COP [PrintDialogString] ( &dialogstring_05B688 )
    RTL 
}

dialogstring_05B688 `[DEF]Woman: A man working[N]at the hotel was caught[N]by a labor trader.[END]`