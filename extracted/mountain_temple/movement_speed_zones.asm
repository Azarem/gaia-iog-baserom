; Movement speed zone controller for Mountain Temple (~145 lines).
; 
; Defines zones with different player movement speeds.
; Some areas slow the player (mushroom spore effect, thick
; vegetation) while others are normal. Checks player
; position against zone boundaries each frame.
---------------------------------------------

!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

; Invisible east–west slow-movement zone actor placed in Mountain Temple and related scenes.
; 
; When the player center lies within a 16×16 pixel box around the actor, writes $FFF9 (−7) to global playerSpeedEw ($09B4). Returns immediately if the player is outside the zone.

speed_zone_ew_slow [
  actor-def < #00, #00, #20, {

  code_00C1E2:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C1F5
    EOR #$FFFF
    INC 

  loc_00C1F5:
    CMP #$0010
    BCC loc_00C1FB
    RTL 

  loc_00C1FB:
    LDA $16
    CLC 
    ADC #$0008
    SEC 
    SBC $0016, Y
    BPL loc_00C20B
    EOR #$FFFF
    INC 

  loc_00C20B:
    CMP #$0010
    BCC loc_00C211
    RTL 

  loc_00C211:
    LDA #$FFF9
    STA $playerSpeedEw
    RTL 
} >
]
---------------------------------------------

; Invisible east–west fast-movement zone actor used in Kress Maze and Mountain Temple.
; 
; Uses the same 16×16 proximity test as speed_zone_ew_slow but writes $0007 (+7) to playerSpeedEw when the player is inside the zone. Paired with speed_zone_ew_slow and speed_zone_ns_slow to create directional current lanes.

speed_zone_ew_fast [
  actor-def < #00, #00, #20, {

  code_00C21B:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C22E
    EOR #$FFFF
    INC 

  loc_00C22E:
    CMP #$0010
    BCC loc_00C234
    RTL 

  loc_00C234:
    LDA $16
    CLC 
    ADC #$0008
    SEC 
    SBC $0016, Y
    BPL loc_00C244
    EOR #$FFFF
    INC 

  loc_00C244:
    CMP #$0010
    BCC loc_00C24A
    RTL 

  loc_00C24A:
    LDA #$0007
    STA $playerSpeedEw
    RTL 
} >
]
---------------------------------------------

; Invisible north–south slow-movement zone actor with a tighter vertical window than the east–west variants.
; 
; Requires the player to be within 16 pixels horizontally and within 4 pixels vertically of the actor center, then sets playerSpeedNs to $FFF9 (−7). Placed in Mountain Temple scenes alongside the EW zones.

speed_zone_ns_slow [
  actor-def < #00, #00, #20, {

  code_00C289:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C29C
    EOR #$FFFF
    INC 

  loc_00C29C:
    CMP #$0010
    BCC loc_00C2A2
    RTL 

  loc_00C2A2:
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_00C2AE
    EOR #$FFFF
    INC 

  loc_00C2AE:
    CMP #$0004
    BCC loc_00C2B4
    RTL 

  loc_00C2B4:
    LDA #$FFF9
    STA $playerSpeedNs
    RTL 
} >
]