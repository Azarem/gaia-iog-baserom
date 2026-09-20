; Bouncing crystal object in the Angkor Wat shrine.
; 
; Animated crystal that bounces with physics-based movement
; (~62 lines). Part of the shrine visual effects. Creates
; the mystical atmosphere of the crystal shrine room.
---------------------------------------------

?INCLUDE 'sp5D_fountain'

!cameraBoundsX                  06DA
!cameraBoundsY                  06DC

---------------------------------------------

awBC_bouncing_crystal [
  actor-def < #31, #02, #0B, {

  code_089F2F:
    COP [SpawnAfterFlags] ( @sp5D_fountain.code_069502, #$2800 )
    LDA #$FFFF
    STA $24
    STA $26
    COP [SetEntryContinue]
    LDA $14
    BMI loc_089F60
    CMP $cameraBoundsX
    BCS loc_089F67
    LDA $16
    BMI loc_089F6E
    CMP $cameraBoundsY
    BCS loc_089F75

  loc_089F51:
    LDA $14
    CLC 
    ADC $24
    STA $14
    LDA $16
    CLC 
    ADC $26
    STA $16
    RTL 

  loc_089F60:
    LDA #$0001
    STA $24
    BRA loc_089F51

  loc_089F67:
    LDA #$FFFF
    STA $24
    BRA loc_089F51

  loc_089F6E:
    LDA #$0001
    STA $26
    BRA loc_089F51

  loc_089F75:
    LDA #$FFFF
    STA $26
    BRA loc_089F51
} >
]