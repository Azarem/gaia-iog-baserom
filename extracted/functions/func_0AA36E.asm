!playerActor                    09AA

---------------------------------------------

func_0AA36E {
    LDY $playerActor
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}