; Ishtar's apprentice — explains the puzzle room test.
; 
; NPC: "When you solve the puzzle of the room you may pass."
; Guards the entrance to Ishtar's test chambers and provides
; the rules for the puzzle sequence.
---------------------------------------------

!playerSpeedNs                  09B4

---------------------------------------------

av75_apprentice [
  actor-def < #04, #00, #10, {

  code_06DC53:
    COP [BranchIfPlayerInAbsTiles] ( #70, #00, #80, #10, &code_06DC5D )
    BRA loc_06DC66
} >
]

code_06DC5D {
    COP [SetFlagByte] ( #00 )
    LDA #$FFFF
    STA $playerSpeedNs

  loc_06DC66:
    LDA $0AA6
    LSR 
    CMP #$0001
    BNE loc_06DC75
    COP [SetTilePos] ( #3A, #1D )
    BRA loc_06DC89

  loc_06DC75:
    CMP #$0002
    BNE loc_06DC80
    COP [SetTilePos] ( #57, #1D )
    BRA loc_06DC89

  loc_06DC80:
    CMP #$0003
    BNE loc_06DC89
    COP [SetTilePos] ( #00, #71 )

  loc_06DC89:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_06DC92 )
    COP [SetEntryHere]
    RTL 
}

code_06DC92 {
    COP [PrintDialogString] ( &dialogstring_06DC97 )
    RTL 
}

dialogstring_06DC97 `[TPL:B]Ishtar's apprentice:[N]When you solve the[N]puzzle of the room[N]you may pass.[END]`