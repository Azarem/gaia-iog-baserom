; Rofsky's book in Euro — readable object.
; 
; Interactive: "This is the book that Rofsky wrote about the
; future of mankind." Provides intellectual context for
; Rofsky's character and his predictions about the comet.
---------------------------------------------

---------------------------------------------

eu91_book [
  actor-def < #27, #00, #10, {

  code_07E4BF:
    LDA #$0200
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetInteractHandler] ( &code_07E4CE )
    COP [SetEntryHere]
    RTL 
} >
]

code_07E4CE {
    COP [PrintDialogString] ( &dialogstring_07E4D3 )
    RTL 
}

dialogstring_07E4D3 `[DEF]This is the book that [N]Rofsky wrote about [N]the future of mankind. [END]`