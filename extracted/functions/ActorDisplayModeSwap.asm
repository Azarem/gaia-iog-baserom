; Utility JSL (Bank 06) that actor init code calls first: it saves the actor's variant index and then puts the actor on the normal visible run path.
; 
; Effects, with the actor's own DP as D (the caller is an actor script, D = X = slot):
;   $24 = low nibble of $0E (the OAM attribute XOR word; for a scene-data actor with an odd spawn byte 2 the word is byte 2 >> 1, so the nibble is the variant index chosen in the scene's actor list). Callers read it back later, e.g. wa78_water_kid's interact handler feeds $24 to SwitchCase.
;   $0E = $2000 (attribute high byte $20 = sprite priority 2).
;   $10 (actor flags 1): bit $2000 cleared (hidden in sprite composition / script-driven run path) and bit $1000 set (display-active: processed when displayModeFlags bit 7 filters the actor list).
; 
; Of the 25 actor-def headers in the 22 caller files, 24 start with flags word $1000 or $1800 (bit $2000 already clear, $1000 already set), so for them the $10 update changes nothing and the effective work is $0E = $2000 plus the $24 save. Only eu91_shop_queue starts with $3000, where the $2000 clear is real.
; 
; The older header called $0E 'displayModeFlags' (that is the global at $09EC) and $10 a 'statusWord', and described a swap 'from display mode $2000 to $1000' as if every caller started hidden.
; 
; Requires M = 0 (16-bit A). Call sites: 23 in 22 NPC actor files: watermia (wa78_women, water_kid, moving_woman, men, children, centipede_man), angel_village (av6B_villagers1-3, ocean_ache, av6C_villagers4-5, av69_signs), seaside_palace (sp5A_villagers), euro (eu91_women1-2, men1-2, shop_queue, merchant twice, eu9D_slaves) and dao sweatshop (daC5_weaver).
---------------------------------------------

---------------------------------------------

ActorDisplayModeSwap {
    LDA $0E               ; Variant source: $0E is the OAM attribute XOR word, not displayModeFlags
    AND #$000F            ; Keep the low nibble only (the variant index)
    STA $24               ; $24 = variant index; callers use it later, e.g. as a SwitchCase index in the interact handler
    LDA #$2000
    STA $0E               ; $0E = $2000: attribute high byte $20 = sprite priority 2
    LDA #$2000
    TRB $10               ; Clear actor flag $2000 (hidden in sprite composition, script-driven run path)
    LDA #$1000
    TSB $10               ; Set actor flag $1000 (display-active: runs under the display filter)
    RTL 
}