; Freed ship crew member — manages an item exchange.
; 
; Solid NPC. Checks if player has item #38 — if so, locks joypad,
; removes the item, and plays an exchange sequence. Provides
; dialog about the crew's situation.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

gs2E_crew2 [
  actor-def < #04, #00, #10, {

  code_0588E8:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05893B )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #38, &code_0588F6 )
    RTL 
} >
]

code_0588F6 {
    LDA #$FFF0
    TSB $joypadMaskStd
    LDA #$1000
    TRB $10
    COP [WaitByte] ( #01 )
    COP [RemoveItem] ( #38 )
    COP [WriteApuIo0] ( #7F )
    LDA #$0000
    STA $0AAC
    LDA #$002E
    STA $0B12
    LDA #$0025
    STA $0B08
    STA $0B0A
    LDA #$001A
    STA $0B0C
    STA $0B0E
    LDA #$2310
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_05893B {
    COP [PrintDialogString] ( &dialogstring_058940 )
    RTL 
}

dialogstring_058940 `[TPL:A]The Mystic Statue is [N]in this box. [FIN]Preparations are being[N]made to set sail.[FIN]Well? Are you going to [N]the crow's nest? You can[N]watch the ship set sail.[END]`