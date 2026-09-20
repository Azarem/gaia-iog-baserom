; Tower spirits in the Babel lower floors — time distortion lore.
; 
; Multi-spirit NPCs (~88 lines). "The light released from the
; comet has a profound effect on the growth of living things."
; Also: "The passage of time is different inside the Tower
; of Babel... Time races by..." Exposition about the tower's
; temporal anomalies and the comet's biological effects.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

btDF_spirits [
  actor-def < #00, #00, #10, {

  code_099B31:
    LDA #$0200
    TSB $12
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    LDA #$2000
    TRB $10
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_099B5A )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
} >
]

code_099B5A {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_099B65 )
}

code_list_099B65 [
  &code_099B71   ;00
  &code_099B76   ;01
  &code_099B7B   ;02
  &code_099B80   ;03
  &code_099B85   ;04
  &code_099B8A   ;05
]

code_099B71 {
    COP [PrintDialogString] ( &dialogstring_099B8F )
    RTL 
}

code_099B76 {
    COP [PrintDialogString] ( &dialogstring_099C1E )
    RTL 
}

code_099B7B {
    COP [PrintDialogString] ( &dialogstring_099C95 )
    RTL 
}

code_099B80 {
    COP [PrintDialogString] ( &dialogstring_099D16 )
    RTL 
}

code_099B85 {
    COP [PrintDialogString] ( &dialogstring_099DE5 )
    RTL 
}

code_099B8A {
    COP [PrintDialogString] ( &dialogstring_099E34 )
    RTL 
}

dialogstring_099B8F `[TPL:B]The light released[N]from the comet has a[N]profound effect on the[N]growth of living things.[FIN]When the star nears[N]Earth's orbit, all[N]living things experience[N]a dramatic evolution...[END]`

dialogstring_099C1E `[TPL:B]The passage of time is[N]different inside the[N]Tower of Babel... [N]Time races by...[FIN]You're not normal human[N]beings, because[N]you can live here...[END]`

dialogstring_099C95 `[TPL:A]The evolution of living[N]things took a long time.[FIN]From insects to fish,[N]from reptiles to mammals,[N]then humans were born.[FIN]And so human beings[N]have evolved.[END]`

dialogstring_099D16 `[TPL:A]From ancient times [N]comets have been called [N]the spirits of stars,[FIN]but also the demon [N]of stars. [FIN]The one now nearing [N]the Earth is a demon [N]of stars... [FIN]The comet is the highest[N]form of consciousness.[FIN]The Earth will evolve [N]beyond imagination...[END]`

dialogstring_099DE5 `[TPL:B]In that room are demons[N]evolved by the light.[N]You must put them to[N]sleep before you go up.[END]`

dialogstring_099E34 `[TPL:B]The Earth took a wrong[N]turn on its path[N]of evolution...[FIN]Your battle will change[N]the fate of humanity.[END]`