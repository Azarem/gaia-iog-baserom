; Guard blocking the Freejia back alley (scene $32).
; 
; Solid actor with a talk handler. The handler compares playerXPos ($09A2) with the guard's own X position ($14): below it prints 'Children don't come here. Go home.'; at or above it prints 'This kid! Where did you come from?! Go home! Go home!!' and sets scratch flag $01, on which the guard's main script clears its solid mark, writes $FFFB to playerSpeedEw ($09B2), waits #1D, clears the flag and marks itself solid again. No story flag is tested.
---------------------------------------------

!playerXPos                     09A2
!playerSpeedEw                  09B2

---------------------------------------------

fr32_alley_guard [
  actor-def < #04, #00, #10, {

  code_05B79C:
    COP [SetInteractHandler] ( &code_05B7B6 )

  loc_05B7A0:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    LDA #$FFFB
    STA $playerSpeedEw
    COP [WaitByte] ( #1D )
    COP [ClearFlagByte] ( #01 )
    BRA loc_05B7A0
} >
]

code_05B7B6 {
    LDA $playerXPos
    CMP $14
    BCS loc_05B7C2
    COP [PrintDialogString] ( &dialogstring_05B7CA )
    RTL 

  loc_05B7C2:
    COP [PrintDialogString] ( &dialogstring_05B7E6 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_05B7CA `[DEF]Children don't come[N]here. Go home.[END]`

dialogstring_05B7E6 `[DEF]This kid! Where did [N]you come from?! [N]Go home! Go home!! [END]`