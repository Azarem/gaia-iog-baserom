; Per-actor event callback registration COP handlers (39527–39657, Bank 00).
; 
; Each handler reads its operand from the script stream ($0A), stores it in an actor-slot-indexed table in bank $7F (X = slot, from TYX), and returns by writing the advanced script address to the COP frame ($02,S) and RTI.
; 
; Callback slots (addresses are bases; the actor slot id is added): onHitCallback +0 (#58), onDodgeCallback +2 (#59), onDeathCallback +4 (#57, plus a bank byte at +6, so death hooks can live in another bank), onCollideCallback +8 (#5A), custom callback +$16 (#5E, labelled scratch1010+6). Consumers: hit_stagger_controller and combat_collision dispatch the hit, dodge, death and collide hooks; actor_pool clears them when a slot is initialised. The custom slot is read by combat_collision as an interaction handler for push hits (it overwrites the victim's entry point); other actors reuse the word for their own purposes (the mummy queen stores a different value there, read back by pyDD_queen_spirit_attack).
; 
; OrExtraFlags (#5B) and AndExtraFlags (#5C) edit the actor's extendedFlags word ($7F002A). AndExtraFlags keeps only the bits in its mask (it does not clear them). Bits identified from their readers: $0002 moving, $0004 run after the actor list, $0008 ClearSolidHere on defeat, $0020 skip hit-stun, $0080 boss.
---------------------------------------------

?BANK 00

!extendedFlags                  7F002A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onDeathCallbackBank            7F1006
!onCollideCallback              7F1008
!scratch1010                    7F1010

---------------------------------------------

; COP #57 with an @Code far-pointer operand (word + bank byte, 3 bytes). Stores the word in onDeathCallback ($7F1004) and the bank in the following word ($7F1006), both indexed by actor slot, for the death script hook.

SetDeathCallback {
    TYX 
    LDA [$0A]             ; SetDeathCallback: read pointer word
    INC $0A
    INC $0A
    STA $onDeathCallback, X ; Store to onDeathCallback ($7F1004)
    LDA [$0A]             ; Read bank byte for death callback
    INC $0A
    AND #$00FF
    STA $onDeathCallbackBank, X ; Store bank to $7F1006
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #58 with one &Code operand. Stores the script pointer in onHitCallback ($7F1000) for hit-event dispatch.

SetHitCallback {
    TYX 
    LDA [$0A]             ; Read hit callback pointer and store to $7F1000
    INC $0A
    INC $0A
    STA $onHitCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #59 with one &Code operand. Stores the script pointer in onDodgeCallback ($7F1002) for dodge-event dispatch.

SetDodgeCallback {
    TYX 
    LDA [$0A]             ; Read dodge callback pointer and store to $7F1002
    INC $0A
    INC $0A
    STA $onDodgeCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5A with one &Code operand. Stores the script pointer in onCollideCallback ($7F1008) for collision-event dispatch.

SetCollideCallback {
    TYX 
    LDA [$0A]             ; Read collide callback pointer and store to $7F1008
    INC $0A
    INC $0A
    STA $onCollideCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5E with one &Code operand. Stores the script pointer in the custom-callback word ($7F1016, written as scratch1010+6) of the actor's slot. combat_collision runs it as the interaction handler for push hits; some actors reuse the word for other data.

SetCustomCallback {
    TYX 
    LDA [$0A]             ; Read custom callback pointer and store to $7F1016
    INC $0A
    INC $0A
    STA $scratch1010+6, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5B with one word operand. ORs the value into the actor's extendedFlags word at $7F002A.

OrExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and OR into extendedFlags ($7F002A)
    INC $0A
    INC $0A
    ORA $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5C with one word operand. ANDs the actor's extendedFlags word ($7F002A) with the operand, so the operand is a mask of bits to KEEP (e.g. #$FFF7 clears bit 3).

AndExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and AND with extendedFlags ($7F002A)
    INC $0A
    INC $0A
    AND $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}