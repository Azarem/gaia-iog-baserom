; Woman commenting on Freejia's city flower.
; 
; Simple NPC. Says: "The Freejia is the city flower. Smells
; good, doesn't it?" Lighthearted contrast to the slave trade
; happening behind the scenes.
---------------------------------------------

---------------------------------------------

fr32_fragrance [
  actor-def < #13, #00, #10, {

  code_05BA0F:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BA18 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05BA18 {
    COP [PrintDialogString] ( &dialogstring_05BA1D )
    RTL 
}

dialogstring_05BA1D `[DEF]The Freejia is the city[N]flower. Smells good,[N]doesn't it?[END]`