?BANK 05

---------------------------------------------

dm3F_mine_collapse_trigger [
  actor-def < #00, #00, #30, {

  code_05D069:
    COP [BranchIfFlagWord] ( #$0121, #01, &code_05D08B )
    COP [SetEntryContinue]
    LDA $0A01
    AND #$00FF
    CMP #$0004
    BEQ loc_05D07E
    RTL 

  loc_05D07E:
    COP [SetFlagWord] ( #$0121 )
    COP [StageBgChange] ( #21 )
    COP [ApplyBgChange]
    COP [PlaySoundBoth] ( #$0E0E )
} >
]

code_05D08B {
    COP [MarkDeath]
    RTL 
}