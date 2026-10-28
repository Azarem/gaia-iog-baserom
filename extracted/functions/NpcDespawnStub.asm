; Minimal actor script that executes COP Die on its first run.
; 
; Its only user is combat_collision.InteractionDamage_NPCChat: after a successful item give or dialogue interaction it writes this stub's address into the NPC actor's entry point ($0000/$0002), zeroes the wait counter $08 and ORs $0700 into the actor flags $10. On its next tick the NPC runs COP Die and is removed from the actor list, so the stub is a one-tick despawn, not a long-lived inert actor (OQ-I025-6).
---------------------------------------------

---------------------------------------------

NpcDespawnStub {
    COP [Die]
}