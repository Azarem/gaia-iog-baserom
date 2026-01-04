?BANK 02

?INCLUDE 'chunk_028000'

!scene_current                  0644

----------------------------------------

meta_jump_table:
  &loc_028D44
  #$0000
  &loc_028D83
  &loc_028D7D
  &loc_028D7E
  &loc_028D7D
  &loc_028D80
  #$0000
  #$0000
  #$0000
  #$0000
  #$0000
  #$0000
  #$0000
  &loc_028D81
  #$0000
  &loc_028D7E  ;10
  &loc_028D7F
  &loc_028D8D
  &loc_028D82
  &loc_028D86
  &loc_028D83


--------------------------------

sub_028CF2 {
    REP #$20
    LDA $scene_current
    ASL
    TAY
    LDA [$3A], Y
    SEC
    SBC $3A
    TAY
    SEP #$20
    RTS

  loc_028CF5:
  loc_028CFF:
  loc_028D34:
  loc_028D35:
  loc_028D36:
  loc_028D37:
  loc_028D38:
  loc_028D39:
  loc_028D3A:
}

-----------------------------------------

func_028D3D {
    JSR $&sub_028CE7
    PHX
    PHA 
    REP #$20
    LDA [$3A]
    SEC
    SBC $3A
    TAY
    SEP #$20
    LDA #$00
    XBA

  loc_028D44:
    ;INY 
    ;INY 

  loc_028D46:
    LDA [$3A], Y
    INY
    ASL
    TAX
    JMP (&meta_jump_table, X)

  loc_028D8D:
    PLA 
    PLX
    RTS 
}

