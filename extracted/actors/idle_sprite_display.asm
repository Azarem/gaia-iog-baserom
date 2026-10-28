; Static 5-gem pickup actor: shows spriteset_enemies frame #06 and carries item ID $85 in chatPtr. No scene actor list or COP spawn in extracted/ refers to it by name (OQ-I034-3).
; 
; Header bytes: animation state 0 and flags word $0020 (ORed with $4000 by InitActorFromSceneData, so $4020). Bit $0020 marks the actor friendly: when the player overlaps it ApplyInteractionDamage routes to InteractionDamage_NPCChat, which calls GiveItemToPlayer(chatPtr). Item $85 is '+5 gems' (cap 999, SFX #22); DarkGemDropAnimVariantA spawns the same $85 with the same frame #06, so this is the stationary version of that gem. The older header called it a static NPC / decoration and the chatPtr a dialog bank pointer; neither is supported (the interaction path is UNVERIFIED-RUNTIME).
; 
; Pass structure: init stores chatPtr and the metasprite, SetEntryHere marks the re-entry address, then StageSpriteFrame #06 and AnimOnce run on every pass. No SetSpritePalette is issued here, unlike the gem spawners, which use palette #00.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!chatPtr                        7F000A

---------------------------------------------

idle_sprite_display [
  actor-def < #00, #20, #00, {

  IdleSpriteDisplayInit:
    LDA #$0085            ; chatPtr = $0085: item ID for GiveItemToPlayer (+5 gems), not a dialog pointer; same value as DarkGemDropAnimVariantA
    STA $chatPtr, X
    COP [SetMetasprite] ( @spriteset_enemies ) ; Enemy sprite sheet; frame #06 below is the frame DarkGemDropAnimVariantA stages for item $85
    COP [SetEntryHere]    ; Re-entry address: later passes resume here and restage the frame
    COP [StageSpriteFrame] ( #06 ) ; Static frame #06 (the 5-gem frame; see DarkGemDropAnimVariantA)
    COP [AnimOnce]        ; Animate once, then RTL ends this pass
    RTL 
} >
]