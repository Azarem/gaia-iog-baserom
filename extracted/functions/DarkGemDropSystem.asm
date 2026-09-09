?INCLUDE 'interaction_handlers'
?INCLUDE 'table_0EE000'

!playerMaxHp                    0ACA
!playerHp                       0ACE
!chatPtr                        7F000A

---------------------------------------------

SpawnDarkGemType1 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.collect_handler_gem, #$2700 )

  code_00DF38:
    LDA #$0083
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #04, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #96 )
    COP [AnimLoop]
    COP [Die]
}

code_00DF52 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.collect_handler_gem, #$2700 )

  code_00DF61:
    LDA #$0084
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #05, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #96 )
    COP [AnimLoop]
    COP [Die]
}

code_00DF7B {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.collect_handler_gem, #$2700 )
    LDA $playerMaxHp
    LSR 
    LSR 
    CMP $playerHp
    BCC loc_00DF99
    LDA #$0020
    BRA loc_00DFAA

  loc_00DF99:
    LDA $playerMaxHp
    LSR 
    CMP $playerHp
    BCC loc_00DFA7
    LDA #$0010
    BRA loc_00DFAA

  loc_00DFA7:
    LDA #$0000

  loc_00DFAA:
    STA $26
    COP [RngByte]
    PHX 
    LDX $26
    LDY #$0002

  loc_00DFB4:
    CMP $@gem_drop_threshold_00DFFD, X
    BCC loc_00DFC1
    INX 
    INX 
    INX 
    INX 
    DEY 
    BPL loc_00DFB4

  loc_00DFC1:
    LDA $@gem_drop_threshold_00DFFD+2, X
    DEC 
    PLX 
    PHA 
    RTS 
}

code_00DFC9 {
    LDA #$0085
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #06, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0B, #96 )
    COP [AnimLoop]
    COP [Die]

  code_00DFE3:
    LDA #$0086
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #22, #B4 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #3C )
    COP [AnimLoop]
    COP [Die]
}

gem_drop_threshold_00DFFD [
  gem-drop-threshold < #$000F, &code_00DFE3 >   ;00
  gem-drop-threshold < #$003C, &code_00DFC9 >   ;01
  gem-drop-threshold < #$0099, &code_00DF61 >   ;02
  gem-drop-threshold < #$0100, &code_00DF38 >   ;03
  gem-drop-threshold < #$0019, &code_00DFC9 >   ;04
  gem-drop-threshold < #$004C, &code_00DF38 >   ;05
  gem-drop-threshold < #$0099, &code_00DFE3 >   ;06
  gem-drop-threshold < #$0100, &code_00DF61 >   ;07
  gem-drop-threshold < #$000C, &code_00DF61 >   ;08
  gem-drop-threshold < #$0033, &code_00DF38 >   ;09
  gem-drop-threshold < #$007F, &code_00DFC9 >   ;0A
  gem-drop-threshold < #$0100, &code_00DFE3 >   ;0B
]