; ==============================================================================
; Scene script meta tables - indexed scene and label lookup
; ==============================================================================
; What it does: FindCurrentScene uses scene_meta_list[sceneCurrent] instead of
;   scanning packed [id][commands] records; SkipScriptCommands uses
;   meta_label_list[label id] instead of scanning forward by opcode sizes.
; Vanilla behavior: Linear scan in WRAM script blob at [$3A], comparing u16 scene
;   ids and skipping variable-length opcodes; jump/branch targets found by scan.
; Hooks (overrides): scene_script.FindCurrentScene (+ stub loc_028CF5-028D3A
;   labels retained for merge), SkipScriptCommands (+ loc_028D44/046/08D stubs).
; Depends on: ?INCLUDE scene_script, scene_meta; ReadScriptByte; tables in
;   scene_meta (scene_meta_list, meta_label_list).
; State: sceneCurrent $0644; script base pointer DP $3A/$3C (engine init).
; Hazards/notes: Bank $02; stub colon-label overrides are intentional no-ops for
;   excised vanilla scan loops; Y must hold stream offset on RTS.
; ==============================================================================
?BANK 02

?INCLUDE 'scene_script'
?INCLUDE 'scene_meta'

!scene_current                  0644

----------------------------------------

scene_script.FindCurrentScene! {
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

  scene_script.loc_028CF5!:
  scene_script.loc_028CFF!:
  scene_script.loc_028D34!:
  scene_script.loc_028D35!:
  scene_script.loc_028D36!:
  scene_script.loc_028D37!:
  scene_script.loc_028D38!:
  scene_script.loc_028D39!:
  scene_script.loc_028D3A!:
}

-----------------------------------------
;Utilize the new label jump table

scene_script.SkipScriptCommands! {
    JSR $&ReadScriptByte
    REP #$20
    ASL
    TAX
    LDA $@meta_label_list, X
    SEC
    SBC $3A
    TAY
    SEP #$20
    RTS

  scene_script.loc_028D44!:
  scene_script.loc_028D46!:
  scene_script.loc_028D8D!:
}

