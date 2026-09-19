?BANK 0B

!cameraTargetY                  06C2

---------------------------------------------

pyDD_queen_debris {
    COP [StageSprAndHitbox] ( #0D )
    LDA #$0002
    TSB $12
    COP [RngByte]
    PHA 
    AND #$001F
    STA $16
    PLA 
    ASL 
    STA $14

  loc_0BAD7F:
    COP [StageForceMoveX] ( #01 )
    COP [RngByte]
    LSR 
    BCC loc_0BAD8E
    LDA $12
    EOR #$4000
    STA $12

  loc_0BAD8E:
    COP [InitGravity] ( #02, #07, #05 )
    COP [SetEntryContinue]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0BAD9D
    RTL 

  loc_0BAD9D:
    COP [ToggleHFlip]
    LDA $10
    BIT #$4000
    BNE loc_0BADB3
    COP [PlaySoundCh1] ( #15 )
    LDA #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY

  loc_0BADB3:
    LDA $16
    BMI loc_0BAD7F
    CMP #$0200
    BCC loc_0BAD7F
    COP [Die]
}