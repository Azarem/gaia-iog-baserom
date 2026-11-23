; Transform poses (body slot 5) use two animation ticks per update on the
; player. Finish at the first completed tick so loops and script events fire
; once. Both one-shot and repeated poses use this rule from the first visit.
?INCLUDE 'sprite_composition'
?INCLUDE 'cop_handlers_sprite'

TransformPoseTick {
    CPX $09AA
    BNE transform_tick_native
    LDA $09AE
    BPL transform_tick_native
    LDA $0AC8
    AND #$00FF
    CMP #$0005
    BNE transform_tick_native
    JSL $@sprite_composition.UpdateActorAnimation
    BCS transform_tick_done
  transform_tick_native:
    JML $@sprite_composition.UpdateActorAnimation
  transform_tick_done:
    RTL
}

cop_handlers_sprite.AnimOnce! {
    TYX
    JSL $@TransformPoseTick
    BCC loc_009FBD
    STZ $2C
    STZ $2E
    LDA $0A
    STA $02, S
    RTI
}

cop_handlers_sprite.loc_009FC1! {
    JSL $@TransformPoseTick
    BCC loc_009FDB
    LDA $7F0016, X
    DEC
    STA $7F0016, X
    BNE loc_009FC1
    STZ $2C
    STZ $2E
    LDA $0A
    STA $02, S
    RTI
}
