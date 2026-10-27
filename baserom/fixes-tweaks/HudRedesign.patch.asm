

HudTilemapData! [
  #$2CCE   ;06
  #$2CCF   ;07
  #$0000   ;08
  #$0008   ;09
  #$ECEF   ;0A
  #$2CDA   ;0B
  #$2CDB   ;0C
  #$2CDC   ;0D
  #$2CDD   ;0D
  #$ACE9   ;0D
  #$ECE9   ;0D
  #$6CDD   ;0D
  #$6CDC   ;10
  #$6CDB   ;11
  #$6CDA   ;12
  #$ACEF   ;13
  #$0000   ;14
  #$0008   ;15
  #$6CCF   ;16
  #$6CCE   ;17
  #$2CDE   ;1A
  #$0000   ;1B
  #$000A   ;1C
  #$2CEA   ;1D
  #$2CD9   ;1E
  #$0000   ;1F
  #$0001   ;20
  #$2CED   ;21
  #$0000   ;1F
  #$0002   ;20
  #$6CED   ;22
  #$0000   ;23
  #$0002   ;24
  #$6CEA   ;25
  #$0000   ;26
  #$000A   ;27
  #$6CDE   ;28
  #$2CEE   ;2B
  #$0000   ;2C
  #$000A   ;2D
  #$2CFA   ;2E
  #$2CFB   ;2F
  #$2CFC   ;30
  #$2CFD   ;31
  #$2CE9   ;33
  #$6CE9   ;33
  #$6CFD   ;32
  #$6CFC   ;32
  #$6CFB   ;34
  #$6CFA   ;35
  #$0000   ;36
  #$000A   ;37
  #$6CEE   ;38
  #$0000   ;39
  #$0000   ;3A
]



------------------------------------------------

;DMA size
loc_02B06D! {
    AND #$DF
    STA $09EC
    LDX #$00C0  ;Three lines of tiles
    STX $DAS0L
}

----------------------------------------------

;VRAM DMA arguments (when copying BG3 layer)
loc_02B078! {
    LDX #$7820
    STX $VMADDL
    LDX #$0240
    STX $A1T0L
}

---------------------------------------------

ClearVramBufferPartial! {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$00C0
    BRA loc_02F07E
}

consolestring_01E7F6! |[POS:42,0][PAL:8][HP][POS:5A,0][PAL:14][BCD:1,AD8][POS:64,0][NUM:AD6]|

consolestring_01E818! |[PAL:4][POS:6A,0][HE]|

