!playerActor                    09AA

---------------------------------------------

SetPlayerGameOverFlag {
    LDY $playerActor
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}