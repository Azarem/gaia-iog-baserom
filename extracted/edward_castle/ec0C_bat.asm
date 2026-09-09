!mapBoundsX                     0692
!mapBoundsY                     0696

---------------------------------------------

ec0C_bat [
  actor-def < #1F, #00, #00, {

  code_0A8758:
    COP [WaitWhileOffscreen] ( #0C )
    COP [SetSpritePriority] ( #30 )

  code_0A875E:
    COP [WaitWhileOffscreen] ( #01 )
    COP [SetEntryExit]

  code_0A8763:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8772
    BEQ loc_0A8786
    DEC 
    BEQ loc_0A879A
    BRA loc_0A87AE

  loc_0A8772:
    COP [BranchIfSolidSouth] ( &code_0A875E )
    LDA $16
    CMP $mapBoundsY
    BCS code_0A875E
    COP [StageSpriteMoveXY] ( #1F, #00, #11 )
    COP [AnimOnce]
    BRA code_0A8763

  loc_0A8786:
    COP [BranchIfSolidNorth] ( &code_0A875E )
    LDA $16
    CMP #$0010
    BCC code_0A875E
    COP [StageSpriteMoveXY] ( #20, #00, #12 )
    COP [AnimOnce]
    BRA code_0A8763

  loc_0A879A:
    COP [BranchIfSolidWest] ( &code_0A875E )
    LDA $14
    CMP #$0010
    BCC code_0A875E
    COP [StageSpriteMoveXY] ( #21, #12, #00 )
    COP [AnimOnce]
    BRA code_0A8763

  loc_0A87AE:
    COP [BranchIfSolidEast] ( &code_0A875E )
    LDA $14
    CMP $mapBoundsX
    BCS code_0A875E
    COP [StageSpriteMoveXY] ( #A1, #11, #00 )
    COP [AnimOnce]
    JMP $&code_0A8763
} >
]