; Spiney (spiny creature) enemy for the aqueduct lockway.
; 
; Dungeon enemy with collision-based movement patterns.
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!statsPtr                       7F0020

---------------------------------------------

ec0E_spiney [
  actor-def < #3C, #10, #00, {

  code_0A8AB1:
    LDA #$&enemy_stats_table+20
    STA $statsPtr, X
    LDA $0E
    PHA 
    AND #$3FFF
    STA $0E
    PLA 
    AND #$C000
    CMP #$4000
    BEQ loc_0A8B09
    CMP #$8000
    BEQ loc_0A8AF7
    CMP #$C000
    BEQ loc_0A8AE5

  loc_0A8AD3:
    COP [BranchIfSolidWest] ( &code_0A8AD9 )
    BRA loc_0A8AEF
} >
]

code_0A8AD9 {
    COP [BranchIfSolidNorth] ( &code_0A8B0F )

  loc_0A8ADD:
    COP [StageSpriteMoveY] ( #3E, #02 )
    COP [AnimOnce]
    BRA loc_0A8AD3

  loc_0A8AE5:
    COP [BranchIfSolidSouth] ( &code_0A8AEB )
    BRA loc_0A8B01
}

code_0A8AEB {
    COP [BranchIfSolidWest] ( &code_0A8AD9 )

  loc_0A8AEF:
    COP [StageSpriteMoveX] ( #3E, #02 )
    COP [AnimOnce]
    BRA loc_0A8AE5

  loc_0A8AF7:
    COP [BranchIfSolidEast] ( &code_0A8AFD )
    BRA loc_0A8B13
}

code_0A8AFD {
    COP [BranchIfSolidSouth] ( &code_0A8AEB )

  loc_0A8B01:
    COP [StageSpriteMoveY] ( #3E, #01 )
    COP [AnimOnce]
    BRA loc_0A8AF7

  loc_0A8B09:
    COP [BranchIfSolidNorth] ( &code_0A8B0F )
    BRA loc_0A8ADD
}

code_0A8B0F {
    COP [BranchIfSolidEast] ( &code_0A8AFD )

  loc_0A8B13:
    COP [StageSpriteMoveX] ( #3E, #01 )
    COP [AnimOnce]
    BRA loc_0A8B09
}