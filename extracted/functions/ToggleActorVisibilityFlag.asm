---------------------------------------------

ToggleActorVisibilityFlag {
    LDY $24
    LDA $0010, Y
    EOR #$2000
    STA $0010, Y
    RTL 
}