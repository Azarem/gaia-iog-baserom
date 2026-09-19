; Utility function that XORs flag $2000 on a reference actor (from $24), toggling its visibility on/off.
; 
; Spawned by Seaside Palace party member actors (Neil, Lance, Erik, Kara, phantom Ribber) to show/hide characters during palace events. Simple visibility toggle without destroying the actor.
---------------------------------------------

---------------------------------------------

ToggleActorVisibilityFlag {
    LDY $24
    LDA $0010, Y
    EOR #$2000
    STA $0010, Y
    RTL 
}