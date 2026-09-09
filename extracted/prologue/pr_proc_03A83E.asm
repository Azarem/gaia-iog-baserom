!sineTableA                     7E8900
!sineTableB                     7E8B00
!S_sineTableB                   8B00

---------------------------------------------

e_pr_proc_03A83E {
    LDA #$0000
    STA $7F2104, X
    JSR $&sub_03A90B
    COP [SetEntryContinue]
    LDA $0D58
    BEQ loc_03A85B
    LDA $0D5A
    BNE loc_03A85B
    JSR $&sub_03A8A6
    JSR $&sub_03A886
    RTL 

  loc_03A85B:
    COP [LoopInit] ( #02 )
    JSR $&sub_03A8A6
    JSR $&sub_03A886
    COP [LoopNext]
    COP [LoopInit] ( #28 )
    LDA $7F2104, X
    CLC 
    ADC #$0002
    STA $7F2104, X
    JSR $&sub_03A8A6
    JSR $&sub_03A886
    COP [LoopNext]
    COP [SetEntryContinue]
    JSR $&sub_03A8A6
    JSR $&sub_03A886
    RTL 
}
---------------------------------------------

sub_03A886 {
    LDA $0036
    LSR 
    BCS loc_03A899
    COP [QueueDma] ( $7E8800, #05 )
    COP [QueueDma] ( $7E8A00, #32 )
    RTS 

  loc_03A899:
    COP [QueueDma] ( $7E8900, #05 )
    COP [QueueDma] ( $7E8B00, #32 )
    RTS 
}
---------------------------------------------

sub_03A8A6 {
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $0036
    LSR 
    BCS loc_03A8BA
    LDY #$0000
    BRA loc_03A8BD

  loc_03A8BA:
    LDY #$0100

  loc_03A8BD:
    LDA $@binary_03A932
    STA $8800, Y
    LDA $@binary_03A939
    STA $8A00, Y
    SEP #$20
    LDA $@binary_03A932+2
    CLC 
    ADC $7F2104, X
    STA $8802, Y
    LDA $@binary_03A932+3
    STA $8803, Y
    LDA $@binary_03A939+2
    CLC 
    ADC $7F2104, X
    STA $8A02, Y
    LDA $@binary_03A939+3
    STA $8A03, Y
    REP #$20
    LDA $@binary_03A932+4
    STA $8804, Y
    LDA $@binary_03A939+4
    STA $8A04, Y
    LDA #$0000
    STA $8806, Y
    PLB 
    RTS 
}
---------------------------------------------

sub_03A90B {
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDY #$0000
    LDA #$01FF

  loc_03A91A:
    STA $8A00, Y
    STA $S_sineTableB, Y
    INY 
    INY 
    CPY #$0098
    BCC loc_03A91A
    LDA #$0000
    STA $8A00, Y
    STA $S_sineTableB, Y
    PLB 
    RTS 
}
---------------------------------------------

binary_03A932 #7F071807010900
---------------------------------------------

binary_03A939 #7F00180001FF00