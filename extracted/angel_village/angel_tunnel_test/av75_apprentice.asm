; Ishtar's apprentice in the test scene ($75).
; 
; At spawn the actor tests the player against tiles (70,00)-(80,10), the last observation room. Inside, it sets scratch flag $00 (the byte the player code reads to select the alternate idle sprite set) and writes playerSpeedNs := $FFFF. It then places itself by $0AA6 >> 1: 1 -> tile (3A,1D), 2 -> (57,1D), 3 -> (00,71); other values keep the placed position.
; 
; The actor marks itself solid and its interact handler prints 'When you solve the puzzle of the room you may pass.'
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