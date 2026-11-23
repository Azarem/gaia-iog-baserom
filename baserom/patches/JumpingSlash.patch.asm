; Will's jumping slash: during a swing, pressing forward or either mapped
; guard action ($0030) starts the facing-direction lunge. The redirect test
; and the Will-only form gate retain their original priority.
?INCLUDE 'player_character'

player_character.loc_02CD1E! {
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CD52
    LDA $characterForm
    BNE loc_02CD45
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0B00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0430, &RangedAttackSouth )
    DEC $24
    BMI loc_02CD1E
    RTL
}

player_character.loc_02CD9F! {
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CDD3
    LDA $characterForm
    BNE loc_02CDC6
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0700, &AttackRedirect )
    COP [BranchIfPressed] ( #$0830, &RangedAttackNorth )
    DEC $24
    BMI loc_02CD9F
    RTL
}

player_character.loc_02CE1D! {
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CE51
    LDA $characterForm
    BNE loc_02CE44
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0D00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0230, &RangedAttackWest )
    DEC $24
    BMI loc_02CE1D
    RTL
}

player_character.loc_02CE9B! {
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02CECF
    LDA $characterForm
    BNE loc_02CEC2
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0E00, &AttackRedirect )
    COP [BranchIfPressed] ( #$0130, &RangedAttackEast )
    DEC $24
    BMI loc_02CE9B
    RTL
}

