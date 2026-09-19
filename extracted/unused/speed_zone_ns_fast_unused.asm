; Unreferenced north-south fast speed zone actor, structurally identical to movement_speed_zones.speed_zone_ns_slow but setting playerSpeedNs to $0007 instead of $FFF9.
; 
; Would boost north-south movement in a 16×4 pixel zone. The active movement_speed_zones block includes EW slow/fast and NS slow only; this NS fast variant was never placed.
---------------------------------------------

!playerActor                    09AA
!playerSpeedNs                  09B4

---------------------------------------------

speed_zone_ns_fast_unused [
  actor-def < #00, #00, #20, {

  code_00C254:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C267
    EOR #$FFFF
    INC 

  loc_00C267:
    CMP #$0010
    BCC loc_00C26D
    RTL 

  loc_00C26D:
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_00C279
    EOR #$FFFF
    INC 

  loc_00C279:
    CMP #$0004
    BCC loc_00C27F
    RTL 

  loc_00C27F:
    LDA #$0007
    STA $playerSpeedNs
    RTL 
} >
]