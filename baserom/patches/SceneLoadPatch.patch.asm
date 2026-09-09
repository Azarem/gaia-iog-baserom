?BANK 02

?INCLUDE 'scene_script'
?INCLUDE 'scene_meta'

!scene_current                  0644

----------------------------------------

FindCurrentScene! {
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

  loc_028CF5!:
  loc_028CFF!:
  loc_028D34!:
  loc_028D35!:
  loc_028D36!:
  loc_028D37!:
  loc_028D38!:
  loc_028D39!:
  loc_028D3A!:
}

-----------------------------------------
;Utilize the new label jump table

SkipScriptCommands! {
    JSR $&ReadScriptByte
    REP #$20
    ASL
    TAX
    LDA $@label_list, X
    SEC
    SBC $3A
    TAY
    SEP #$20
    RTS

  loc_028D44!:
  loc_028D46!:
  loc_028D8D!:
}

