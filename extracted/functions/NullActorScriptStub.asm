; Minimal actor script that immediately executes COP Die.
; 
; Assigned as the entry point for NPC actors after successful item give or dialogue interaction in combat_collision's InteractionDamage_NPCChat, preventing re-interaction. Converts interacted NPCs into inert dead stubs without removing them from the actor list.
---------------------------------------------

---------------------------------------------

NullActorScriptStub {
    COP [Die]
}