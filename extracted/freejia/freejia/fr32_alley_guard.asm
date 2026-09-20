; Guard blocking the Freejia back alley — denies access to children.
; 
; Positioned to block passage. Two dialog states based on flags:
; initially warns "Children don't come here. Go home.", later
; becomes more aggressive: "This kid! Where did you come from?!"
; Prevents access to the slave market area until story progression.
---------------------------------------------

!playerXPos                     09A2
!playerSpeedEw                  09B2

---------------------------------------------

fr32_alley_guard [
  actor-def < #04, #00, #10, {

  code_05B79C:
    COP [SetOnInteract] ( &code_05B7B6 )

  loc_05B7A0:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
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