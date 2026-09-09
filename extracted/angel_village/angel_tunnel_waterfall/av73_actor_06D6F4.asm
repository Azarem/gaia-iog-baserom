!playerXTile                    09A6
!APUIO0                         2140

---------------------------------------------

av73_actor_06D6F4 [
  actor-def < #00, #00, #30, {

  code_06D6F7:
    COP [BranchIfPlayerInAbsTiles] ( #00, #00, #40, #10, &code_06D72E )
    COP [SpawnAfterFlags] ( @code_06D733, #$2000 )
    COP [SetEntryContinue]
    LDA $0036
    AND #$0003
    BEQ loc_06D711
    RTL 

  loc_06D711:
    SEP #$20
    LDA $playerXTile
    SEC 
    SBC #$2C
    BPL loc_06D71E
    EOR #$FF
    INC 

  loc_06D71E:
    ASL 
    CMP #$30
    BCC loc_06D725
    LDA #$30

  loc_06D725:
    CLC 
    ADC #$40
    STA $APUIO0
    REP #$20
    RTL 
} >
]

code_06D72E {
    COP [SetFlagByte] ( #00 )
    COP [Die]
}

code_06D733 {
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #2A, #17, #2F, #1D, &code_06D741 )
    COP [ClearFlagByte] ( #00 )
    RTL 
}

code_06D741 {
    COP [SetFlagByte] ( #00 )
    RTL 
}