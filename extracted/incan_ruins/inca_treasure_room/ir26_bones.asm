; Explorer skeleton in the Inca treasure room — charm with family letter.
; 
; Solid interactable prop. When examined, shows a multi-page dialog:
; "An explorer who sought the Incan Gold Ship..." then reveals a
; charm containing notes from family members Nana and Sabas, asking
; their father to return alive and buy a Kruk.
---------------------------------------------

---------------------------------------------

ir26_bones [
  actor-def < #2E, #01, #10, {

  code_09C79B:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_09C7A9 )
    COP [SetEntryHere]
    RTL 
} >
]

code_09C7A9 {
    COP [PrintDialogString] ( &dialogstring_09C7AE )
    RTL 
}

dialogstring_09C7AE `[DEF][TPL:0]An explorer who sought [N]the Incan Gold Ship...? [FIN]In the skeleton's hand[N]is some kind of charm.[FIN][PAU:28]Inside it is a scrap of[N]paper with this[N]written on it.[FIN][PAL:0][SFX:0]Father, please come [N]back alive. [N]               Nana  [FIN]When you find the Gold [N]Ship, buy a Kruk.[N]                 Sabas [END]`