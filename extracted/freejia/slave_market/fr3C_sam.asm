---------------------------------------------

fr3C_sam [
  actor-def < #28, #00, #10, {

  code_05C076:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05C08A )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C08C )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C08A {
    COP [Die]
}

code_05C08C {
    COP [PrintWideString] ( &widestring_05C094 )
    COP [SetFlagByte] ( #66 )
    RTL 
}

widestring_05C094 `[DEF][TPL:5]I am Sam. [FIN]We were rescued last [N]night by a man named [N]Erik who was working [N]at the hotel. [FIN]But we were caught by[N]the labor traders...[FIN]He's being held in a[N]house on the corner of[N]a back street in town.[N]Please save him.[PAL:0][END]`