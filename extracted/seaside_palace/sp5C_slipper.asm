; Slipper enemy — fast sliding creature in the Seaside Palace (~349 lines).
; 
; High-speed enemy that slides along floors and walls.
; Rapid direction changes make it unpredictable. Uses
; momentum-based movement with quick turns. Complements
; the slower Skuddle as a speed-based threat.
---------------------------------------------

!sceneCurrent                   0644

---------------------------------------------

sp5C_slipper [
  actor-def < #19, #00, #03, {

  code_0AE45F:
    COP [BranchIfSolidHere] ( &code_0AE473 )
    LDA $sceneCurrent
    CMP #$005C
    BNE code_0AE47B
    COP [BranchOnFlagByte] ( #70, #00, &code_0AE47B )
    COP [Die]
} >
]

code_0AE473 {
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    RTL 
}

code_0AE47B {
    COP [NudgePosition] ( #F8, #00 )
    LDA #$0080
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )

  code_0AE487:
    COP [BranchIfPlayerNear] ( #05, &code_0AE4A5 )
    LDA #$0009
    STA $08
    RTL 
}

code_0AE492 {
    COP [SetDodgeCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    LDA #$0300
    TSB $10
    COP [JumpNextFrame] ( @code_0AE487 )
}

code_0AE4A5 {
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]

  code_0AE4AF:
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE code_0AE492
    COP [BranchIfPlayerNear] ( #03, &code_0AE4F0 )
    COP [BranchIfPlayerNear] ( #06, &code_0AE4DF )
    COP [SetSavedPtr] ( &code_0AE4AF )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE4D7 )
}

code_list_0AE4D7 [
  &code_0AE5C8   ;00
  &code_0AE611   ;01
  &code_0AE641   ;02
  &code_0AE692   ;03
]

code_0AE4DF {
    COP [SetDodgeCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #20, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #27 )
    INC $24
    BRA loc_0AE4F6
}

code_0AE4F0 {
    COP [SetDodgeCallback] ( &code_0AE539 )
    STZ $24

  loc_0AE4F6:
    COP [RngByte]
    AND #$0003
    BNE loc_0AE505
    LDA $0411
    LSR 
    BCS code_0AE521
    BRA code_0AE50B

  loc_0AE505:
    COP [BranchNearerAxis] ( &code_0AE50B, &code_0AE521 )
}

code_0AE50B {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE515, &code_0AE515, &code_0AE51B )
}

code_0AE515 {
    COP [CallNear] ( &code_0AE5C8 )
    BRA code_0AE4AF
}

code_0AE51B {
    COP [CallNear] ( &code_0AE611 )
    BRA code_0AE4AF
}

code_0AE521 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE52B, &code_0AE52B, &code_0AE532 )
}

code_0AE52B {
    COP [CallNear] ( &code_0AE641 )
    JMP $&code_0AE4AF
}

code_0AE532 {
    COP [CallNear] ( &code_0AE692 )
    JMP $&code_0AE4AF
}

code_0AE539 {
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE545 )
    JMP $&code_0AE4AF
}

code_0AE545 {
    COP [CardinalToPlayer]
    CMP #$0000
    BNE loc_0AE56C
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0AE562 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE562 )
    COP [StageMoveY] ( #11 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
}

code_0AE562 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallNear] ( &code_0AE674 )
    JMP $&code_0AE4AF

  loc_0AE56C:
    DEC 
    BNE loc_0AE58B
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE581 )
    COP [StageMoveX] ( #12 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
}

code_0AE581 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallNear] ( &code_0AE629 )
    JMP $&code_0AE4AF

  loc_0AE58B:
    DEC 
    BNE loc_0AE5AE
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AE5A4 )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE5A4 )
    COP [StageMoveY] ( #12 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
}

code_0AE5A4 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallNear] ( &code_0AE6B0 )
    JMP $&code_0AE4AF

  loc_0AE5AE:
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AE5BE )
    COP [StageMoveX] ( #11 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [LoopEnd]
}

code_0AE5BE {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallNear] ( &code_0AE5F7 )
    JMP $&code_0AE4AF
}

code_0AE5C8 {
    LDA $24
    BNE code_0AE5F7
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE5E0 )
    COP [StageMoveX] ( #12 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE5C8 )
    COP [RestoreSavedPtr]
}

code_0AE5E0 {
    STZ $2C
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0003
    BEQ loc_0AE5F5
    COP [BranchOnPlayerY] ( #$0000, &code_0AE641, &code_0AE641, &code_0AE692 )

  loc_0AE5F5:
    COP [RestoreSavedPtr]
}

code_0AE5F7 {
    STZ $24
    COP [SetEntryHereAndYield]
    COP [StageMoveX] ( #08 )
    COP [LoopStart] ( #04 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE60D )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
}

code_0AE60D {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AE611 {
    LDA $24
    BNE code_0AE629
    COP [BranchIfSolidEast] ( &code_0AE627 )
    COP [StageMoveX] ( #11 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE611 )
    COP [RestoreSavedPtr]
}

code_0AE627 {
    BRA code_0AE5E0
}

code_0AE629 {
    STZ $24
    COP [SetEntryHereAndYield]
    COP [StageMoveX] ( #07 )
    COP [LoopStart] ( #04 )
    COP [BranchIfSolidEast] ( &code_0AE63D )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
}

code_0AE63D {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AE641 {
    LDA $24
    BNE code_0AE674
    COP [BranchIfSolidNorth] ( &code_0AE65D )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE65D )
    COP [StageMoveY] ( #12 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE641 )
    COP [RestoreSavedPtr]
}

code_0AE65D {
    STZ $2E
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0003
    BEQ loc_0AE672
    COP [BranchOnPlayerX] ( #$0000, &code_0AE5C8, &code_0AE5C8, &code_0AE611 )

  loc_0AE672:
    COP [RestoreSavedPtr]
}

code_0AE674 {
    STZ $24
    COP [SetEntryHereAndYield]
    COP [StageMoveY] ( #08 )
    COP [LoopStart] ( #04 )
    COP [BranchIfSolidNorth] ( &code_0AE68E )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE68E )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
}

code_0AE68E {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AE692 {
    LDA $24
    BNE code_0AE6B0
    COP [BranchIfSolidSouth] ( &code_0AE6AE )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE6AE )
    COP [StageMoveY] ( #11 )
    COP [SetEntryHere]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE692 )
    COP [RestoreSavedPtr]
}

code_0AE6AE {
    BRA code_0AE65D
}

code_0AE6B0 {
    STZ $24
    COP [StageMoveY] ( #07 )
    COP [LoopStart] ( #04 )
    COP [BranchIfSolidSouth] ( &code_0AE6C8 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE6C8 )
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
}

code_0AE6C8 {
    STZ $2E
    COP [RestoreSavedPtr]
}