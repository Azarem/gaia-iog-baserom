; Skeleton on the wrecked ship — with dialog about the shipwreck.
; 
; Solid NPC using spriteset_npc_props frame #02 (bone sprite).
; Positioned at (0, +4). When examined, provides flavor text
; about the wrecked ship's history.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

gs2B_bones [
  actor-def < #02, #00, #10, {

  code_058BB6:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_058BD2 )
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #04 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058BD2 {
    COP [PrintDialogString] ( &dialogstring_058BD7 )
    RTL 
}

dialogstring_058BD7 `[TPL:A][TPL:0]Will: [N]This is where the Inca [N]were standing...[PAL:0][END]`