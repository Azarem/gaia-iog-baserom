; Danger slide controller — automated slide section in the Pyramid (~159 lines).
; 
; Manages the dangerous slide passages where the player is
; carried along a path at speed. Handles slide direction,
; speed acceleration, branching paths, and obstacle collision.
; Player must make timed directional inputs to avoid hazards.
---------------------------------------------

?INCLUDE 'camera_drift'
?INCLUDE 'spriteset_enemies'

!sceneCurrent                   0644
!playerActor                    09AA

---------------------------------------------

pyD9_dangerslide_controller [
  actor-def < #00, #00, #30, {

  code_08C5CD:
    COP [SpawnAfterFlags] ( @code_08C607, #$2000 )

  loc_08C5D4:
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    CMP #$0060
    BEQ loc_08C5E9
    INC 
    STA $0026, Y
    RTL 

  loc_08C5E9:
    COP [WaitByte] ( #3B )
    COP [SetEntryContinue]
    LDY #$1060
    LDA $0026, Y
    BEQ loc_08C5FB
    DEC 
    STA $0026, Y
    RTL 

  loc_08C5FB:
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnAfterFlags] ( @camera_drift.CameraDriftPatterned, #$2000 )
    BRA loc_08C5D4
} >
]

code_08C607 {
    PHX 
    LDY $playerActor
    LDA $0014, Y
    STA $0000
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $0002
    LDY #$1060
    LDA $0026, Y
    CLC 
    ADC $0002
    STA $0002
    LDX #$0000

  code_08C62B:
    LDA $@zone_trigger_08C6BC, X
    AND #$00FF
    CMP #$00FF
    BNE loc_08C63A
    JMP $&code_08C6BA

  loc_08C63A:
    CMP $sceneCurrent
    BNE code_08C6B1
    LDA $@zone_trigger_08C6BC+1, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCS code_08C6B1
    LDA $@zone_trigger_08C6BC+2, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0002
    BCS code_08C6B1
    LDA $@zone_trigger_08C6BC+3, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCC code_08C6B1
    LDA $@zone_trigger_08C6BC+4, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0008
    CMP $0002
    BCC code_08C6B1
    TXA 
    TYX 
    TAY 
    PLX 
    PHY 
    COP [SpawnAfterFlags] ( @code_08C697, #$0200 )
    PLY 
    PHX 
    TXA 
    TYX 
    TAY 
    JMP $&code_08C6B1
}

code_08C697 {
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #00 )
    COP [WaitByte] ( #01 )
    COP [Die]
}

code_08C6B1 {
    TXA 
    CLC 
    ADC #$0005
    TAX 
    JMP $&code_08C62B
}

code_08C6BA {
    PLX 
    RTL 
}

zone_trigger_08C6BC [
  zone-trigger < #D9, #20, #01, #28, #0D >   ;00
  zone-trigger < #D9, #30, #01, #38, #0C >   ;01
  zone-trigger < #D9, #40, #01, #44, #0D >   ;02
  zone-trigger < #D9, #50, #01, #5E, #0D >   ;03
  zone-trigger < #D9, #66, #01, #6A, #0D >   ;04
  zone-trigger < #DB, #1C, #01, #38, #0D >   ;05
  zone-trigger < #DB, #40, #01, #48, #0D >   ;06
  zone-trigger < #DB, #50, #01, #60, #11 >   ;07
  zone-trigger < #DB, #66, #01, #6C, #0F >   ;08
]