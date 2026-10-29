; Jeweler Gem: the Red Jewel collector NPC (Bank 08, 577187-577682). Placed with spawn parameter #01 in scenes $01 (South Cape), $32 (Freejia), $6B, $7B, $9B and $C3, one record each; every placement runs this same code.
; 
; === SPAWN (code_08CEA3) ===
; 
; Event flag $E8 is the Solid Arm flag: sEA_solid_arm sets it, so after that optional fight Gem no longer appears (JewelerDie). The old header called it 'game complete'. Otherwise the spawn parameter in $0E picks an 8-frame animation group (all six records pass #01, which gives group 0): the animation index $28 is set to group x 8 + 2 (it is an animation index, not a sprite frame). $0E is then replaced by $3000, the OAM attribute word. Gem marks his tile solid, registers JewelerInteract as his chatPtr and idles on a bare RTL; the shared talk handler in global_ambient_dispatcher runs JewelerInteract when the player presses the interact button (A in this build) facing him.
; 
; === REWARD TIERS (JewelerInteract, JewelerCheck*) ===
; 
; JewelerInteract greets, prints the stored jewel count if it is non-zero and then walks the tiers in ascending order. A tier pays out when its 'given' flag is clear and jewelsCollected ($0AB0, a BCD value) has reached the threshold; each reward sets its flag and jumps to the next tier's check, so one talk can pay several tiers:
;   3 jewels (flag $E9): Herb, item #06. If GiveItem fails the inventory-full text is printed and the talk ends without setting the flag.
;   5 (flag $EA): playerDef + 1.
;   8 (flag $EB): playerMaxHp + 1 and hpToHeal = 1, so UpdateHUD adds one current HP and the new point is filled. It is not an HP-bar flash.
;   12 (flag $EC): playerStr + 1.
;   20 (flag $ED): $0B16 = 1, the Psycho Dash upgrade level (attack_ability_system reads it: damage 5 at level 0, 10 at level 1).
;   30 (flag $EE): $0B1C = 2, the Dark Friar upgrade level (damage 5 / 8 / 12; level 2 is the fully upgraded form).
;   50 (no flag): warp to scene $E9, the sE9_mansion_intro scene that leads to the optional Solid Arm fight. There is no 'given' flag, so every talk with 50 or more jewels warps again; the jewels are not consumed and the menu below is never reached.
; The dialogue string for the 8-jewel tier says 'Your Life Power will be raised' and then 'Your Strength is raised by one'; the code raises max HP, so the second sentence is a text inconsistency.
; 
; === MENU AND JEWEL COUNTING ===
; 
; After the cascade (and any payouts) Gem shows the three-option menu: Just wanted to see you / Give you Red Jewels / See your inventory. The DialogueOptions result table is indexed 0 = B cancel, 1..3 = the options in order, so cancel and option 1 share JewelerCancelReply. 'Give you Red Jewels' (JewelerGiveJewelsOption) needs at least one item #01 in the inventory; JewelerCountJewels then counts the item #01 entries of the 16 inventory slots ($0AB4) with a BCD counter held in the absolute word $0000 (WRAM $7E:0000, scratch; not the actor's own DP $00), adds it to jewelsCollected in decimal mode, removes every jewel with RemoveItem in a loop and re-runs the tier check. 'See your inventory' prints the reward list and highlights (palette 4) each tier whose flag is set.
; 
; JewelerGoodbye_unused ('Well, see ya. Somewhere.') and its dialogue string have no reference anywhere: dead code.
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!hpToHeal                       0B22

---------------------------------------------

jeweler_gem [
  actor-def < #02, #00, #10, {

  code_08CEA3:
    COP [BranchOnFlagByte] ( #E8, #01, &JewelerDie ) ; Flag $E8 (set by sEA_solid_arm after the Solid Arm fight): Gem is gone, die
    LDA $0E               ; Spawn parameter (all six records pass #01, which gives 0): selects the 8-frame animation group
    ASL 
    ASL 
    ASL                   ; ×8
    CLC 
    ADC #$0002            ; +2: first animation index of the group ($28 is an animation index, not a sprite frame)
    STA $28               ; $28 = animation index; the frame counter $2A is cleared next
    STZ $002A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$3000            ; $0E = $3000: the OAM attribute word (replaces the spawn parameter)
    STA $0E
    COP [MarkSolidHere]   ; Make Gem's tile solid so the player cannot walk through him
    COP [SetInteractHandler] ( &JewelerInteract ) ; chatPtr = JewelerInteract: run by the talk handler in global_ambient_dispatcher when the player presses the interact button (A in this build) facing Gem
    COP [SetEntryHere]    ; Idle: every later frame re-enters here and returns; Gem only reacts through the chatPtr
    RTL 
} >
]

---------------------------------------------
; Talk entry (the chatPtr): greeting, the jewel count if non-zero, then the tier cascade starting at code_08CED6.

JewelerInteract {
    COP [PrintDialogString] ( &dialogstring_08D094 ) ; "I am the Jeweler Gem"
    LDA $jewelsCollected  ; jewelsCollected ($0AB0): Red Jewels handed in so far, a BCD value
    BEQ code_08CED6       ; Skip count display if 0
    COP [PrintDialogString] ( &dialogstring_08D0C8 ) ; "I'm holding [count] Red Jewels"

; Reward threshold cascade — checks each tier in ascending order

  code_08CED6:
    COP [BranchOnFlagByte] ( #E9, #01, &JewelerCheck5 ) ; 3-jewel reward already given?
    LDA $jewelsCollected
    CMP #$0003            ; Need ≥ 3 jewels
    BCC JewelerCheck5
    JMP $&JewelerRewardHerb ; → Give Herb
}

JewelerCheck5 {
    COP [BranchOnFlagByte] ( #EA, #01, &JewelerCheck8 ) ; 5-jewel reward given?
    LDA $jewelsCollected
    CMP #$0005            ; Need ≥ 5 jewels
    BCC JewelerCheck8
    JMP $&JewelerRewardDef ; → DEF +1
}

JewelerCheck8 {
    COP [BranchOnFlagByte] ( #EB, #01, &JewelerCheck12 ) ; 8-jewel reward given?
    LDA $jewelsCollected
    CMP #$0008            ; Need ≥ 8 jewels
    BCC JewelerCheck12
    JMP $&JewelerRewardHp ; → MaxHP +1
}

JewelerCheck12 {
    COP [BranchOnFlagByte] ( #EC, #01, &JewelerCheck20 ) ; 12-jewel reward given?
    LDA $jewelsCollected
    CMP #$0012            ; Need ≥ 12 jewels (BCD)
    BCC JewelerCheck20
    JMP $&JewelerRewardStr ; → STR +1
}

JewelerCheck20 {
    COP [BranchOnFlagByte] ( #ED, #01, &JewelerCheck30 ) ; 20-jewel reward given?
    LDA $jewelsCollected
    CMP #$0020            ; Need ≥ 20 jewels (BCD)
    BCC JewelerCheck30
    JMP $&JewelerRewardPsychoDash ; → Psycho Dash upgrade
}

JewelerCheck30 {
    COP [BranchOnFlagByte] ( #EE, #01, &JewelerCheck50 ) ; 30-jewel reward given?
    LDA $jewelsCollected
    CMP #$0030            ; Need ≥ 30 jewels (BCD)
    BCC JewelerCheck50
    JMP $&JewelerRewardDarkFriar ; → Dark Friar upgrade
}

---------------------------------------------
; 50-jewel tier: no 'given' flag, so with 50 or more jewels every talk warps to scene $E9 and never reaches the menu below.

JewelerCheck50 {
    LDA $jewelsCollected  ; Last tier has no 'given' flag: with 50 or more jewels every talk warps and the menu is never reached
    CMP #$0050            ; Need ≥ 50 jewels (BCD)
    BCC loc_08CF47
    JMP $&JewelerSecretRoom ; → Warp to Gem's secret room

  loc_08CF47:
    COP [PrintDialogString] ( &dialogstring_08D0F1+M ) ; "What's your business?"

  code_08CF4B:
    COP [DialogueOptions] ( #03, #01, &JewelerMenuTable ) ; Menu: Just wanted to see you / Give you Red Jewels / See your inventory; result index 0 = B cancel
}

---------------------------------------------
; DialogueOptions result table: index 0 = B cancel, 1 = 'Just wanted to see you', 2 = 'Give you Red Jewels', 3 = 'See your inventory'.

JewelerMenuTable [
  &JewelerCancelReply   ;00
  &JewelerCancelReply   ;01
  &JewelerGiveJewelsOption   ;02
  &JewelerShowInventory   ;03
]

---------------------------------------------
; Reply for cancel and for 'Just wanted to see you': a short farewell text, then the talk ends.

JewelerCancelReply {
    COP [PrintDialogString] ( &dialogstring_08D139 ) ; Farewell text for cancel and 'Just wanted to see you'
    RTL 
}

---------------------------------------------
; 'Give you Red Jewels': continue at JewelerCountJewels if the inventory holds an item #01, otherwise say there are none and end the talk.

JewelerGiveJewelsOption {
    COP [BranchIfHasItem] ( #01, &JewelerCountJewels ) ; Has jewel items?
    COP [PrintDialogString] ( &dialogstring_08D1E0 ) ; "But you don't have any"
    RTL 
}

---------------------------------------------
; BCD jewel counting: count the item #01 entries of the 16 inventory slots in the absolute scratch word $0000, add the count to jewelsCollected in decimal mode, remove every jewel and re-run the tier check.

JewelerCountJewels {
    SED                   ; Enter BCD mode for decimal counting
    STZ $0000             ; Counter in the absolute word $0000 (WRAM $7E:0000 scratch), not the actor's DP $00; reset to 0
    LDA #$0001            ; Item ID to search for
    SEP #$20              ; 8-bit accumulator for item comparison
    LDY #$0000

  loc_08CF74:
    CMP $inventorySlots, Y ; Check slot Y for Red Jewel
    BNE loc_08CF84        ; Not a match — skip
    PHA 
    LDA $0000             ; BCD increment of the counter (decimal mode is on; at most 16 slots, so at most $16)
    CLC 
    ADC #$01
    STA $0000
    PLA 

  loc_08CF84:
    INY 
    CPY #$0010            ; 16 inventory slots
    BNE loc_08CF74
    REP #$20              ; 16-bit mode
    LDA $0000             ; Counter value; the ADC below runs in decimal mode and adds it to jewelsCollected
    CLC 
    ADC $jewelsCollected
    STA $jewelsCollected
    CLD                   ; Exit BCD mode

  code_08CF97:
    COP [RemoveItem] ( #01 ) ; Remove one jewel item per call; the loop repeats while one is left
    COP [BranchIfHasItem] ( #01, &code_08CF97 ) ; More jewels left: remove the next one
    COP [PrintDialogString] ( &dialogstring_08D20F ) ; "This is a rare jewel"
    JMP $&code_08CED6     ; Re-check reward thresholds
}

---------------------------------------------
; "See your inventory" — display reward list with completion markers

JewelerShowInventory {
    COP [PrintDialogString] ( &dialogstring_08D267 ) ; "I will give you goods..."
    COP [PrintDialogString] ( &dialogstring_08D617 ) ; Set up list display format
    COP [BranchOnFlagByte] ( #E9, #00, &code_08CFB8 ) ; Herb (3 jewels) — claimed?
    COP [PrintDialogString] ( &dialogstring_08D611 ) ; Highlight color (claimed)
}

code_08CFB8 {
    COP [PrintDialogString] ( &dialogstring_08D621 )
    COP [BranchOnFlagByte] ( #EA, #00, &code_08CFC6 )
    COP [PrintDialogString] ( &dialogstring_08D611 )
}

code_08CFC6 {
    COP [PrintDialogString] ( &dialogstring_08D636 )
    COP [BranchOnFlagByte] ( #EB, #00, &code_08CFD4 )
    COP [PrintDialogString] ( &dialogstring_08D611 )
}

code_08CFD4 {
    COP [PrintDialogString] ( &dialogstring_08D64A )
    COP [BranchOnFlagByte] ( #EC, #00, &code_08CFE2 )
    COP [PrintDialogString] ( &dialogstring_08D611 )
}

code_08CFE2 {
    COP [PrintDialogString] ( &dialogstring_08D65E )
    COP [BranchOnFlagByte] ( #ED, #00, &code_08CFF0 )
    COP [PrintDialogString] ( &dialogstring_08D611 )
}

code_08CFF0 {
    COP [PrintDialogString] ( &dialogstring_08D672 )
    COP [BranchOnFlagByte] ( #EE, #00, &code_08CFFE )
    COP [PrintDialogString] ( &dialogstring_08D611 )
}

code_08CFFE {
    COP [PrintDialogString] ( &dialogstring_08D67D )
    COP [PrintDialogString] ( &dialogstring_08D68A )
    COP [PrintDialogString] ( &dialogstring_08D0F1 )
    JMP $&code_08CF4B
}

---------------------------------------------
; Unreferenced: prints 'Well, see ya. Somewhere.' and returns. Dead code.

JewelerGoodbye_unused {
    COP [PrintDialogString] ( &dialogstring_08D292 )
    RTL 
}

---------------------------------------------
; Target of the Herb GiveItem failure branch: prints 'Your inventory seems to be full' and ends the talk (the flag stays clear, so the next talk retries).

JewelerInventoryFull {
    COP [PrintDialogString] ( &dialogstring_08D2AA )
    RTL 
}

---------------------------------------------
; Reward: 3 jewels → Herb

JewelerRewardHerb {
    COP [PrintDialogString] ( &dialogstring_08D2D0 ) ; Message: "You've collected more than three Jewels!", then "According to the list, you get the herb!"
    COP [GiveItem] ( #06, &JewelerInventoryFull ) ; Give Herb (item #06)
    COP [PrintDialogString] ( &dialogstring_08D31A ) ; "You received the herb!"
    COP [SetFlagByte] ( #E9 ) ; Mark 3-jewel reward given
    JMP $&JewelerCheck5   ; Check next tier
}

---------------------------------------------
; Reward: 5 jewels → DEF +1

JewelerRewardDef {
    INC $playerDef
    COP [SetFlagByte] ( #EA )
    COP [PrintDialogString] ( &dialogstring_08D332 )
    JMP $&JewelerCheck8
}

---------------------------------------------
; Reward: 8 jewels -> max HP + 1 and hpToHeal = 1 (one HP restored), flag $EB.

JewelerRewardHp {
    INC $playerMaxHp
    LDA #$0001
    STA $hpToHeal         ; hpToHeal = 1: UpdateHUD adds one current HP (fills the new max-HP point); not an HP-bar flash
    COP [SetFlagByte] ( #EB )
    COP [PrintDialogString] ( &dialogstring_08D395 ) ; Text says Life Power, then 'Your Strength is raised by one' (inconsistent: the code raised max HP)
    JMP $&JewelerCheck12
}

---------------------------------------------
; Reward: 12 jewels → STR +1

JewelerRewardStr {
    INC $playerStr
    COP [SetFlagByte] ( #EC )
    COP [PrintDialogString] ( &dialogstring_08D3F9 )
    JMP $&JewelerCheck20
}

---------------------------------------------
; Reward: 20 jewels -> Psycho Dash upgrade level $0B16 = 1, flag $ED.

JewelerRewardPsychoDash {
    LDA #$0001            ; Level 1 (the base level is 0)
    STA $0B16             ; $0B16 = Psycho Dash upgrade level word (read by attack_ability_system)
    COP [SetFlagByte] ( #ED )
    COP [PrintDialogString] ( &dialogstring_08D459 )
    JMP $&JewelerCheck30
}

---------------------------------------------
; Reward: 30 jewels -> Dark Friar upgrade level $0B1C = 2, flag $EE.

JewelerRewardDarkFriar {
    LDA #$0002            ; Dark Friar power level 2
    STA $0B1C             ; $0B1C = Dark Friar upgrade level (2 = fully upgraded; read by attack_ability_system)
    COP [SetFlagByte] ( #EE )
    COP [PrintDialogString] ( &dialogstring_08D4E3 )
    JMP $&JewelerCheck50
}

---------------------------------------------
; Reward: 50 jewels -> queue a map change to scene $E9 (sE9_mansion_intro, the entrance to the optional Solid Arm fight). No flag is set.

JewelerSecretRoom {
    COP [PrintDialogString] ( &dialogstring_08D5AE ) ; "50... Follow me!!"
    LDA #$0202            ; Configure gfx cache for secret room
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E9, #$0330, #$03D0, #80, #$4400 ) ; Queue a map change to scene $E9 (sE9_mansion_intro) with spawn X $0330, Y $03D0
    RTL 
}

---------------------------------------------
; Flag $E8 (set by sEA_solid_arm; the old note said 'game complete'): Gem leaves the scene.

JewelerDie {
    COP [Die]             ; Flag $E8 was set: remove Gem from the scene
}

dialogstring_08D094 `[DEF]I am the Jeweler Gem. [N]I control the Seven[N]Seas. [FIN]`

dialogstring_08D0C8 `I'm holding [BCD:2,AB0] of the[N]Red Jewels for you.[FIN]`

dialogstring_08D0F1 `[DEF][PAL:0][::][CLR]What's your business?[N] Just wanted to see you[N] Give you Red Jewels[N] See your inventory`

dialogstring_08D139 `[CLR]Is that right.[N]How do you do.[FIN]Once you hold up the [N]Red Jewels, you'll [N]have to come running [N]to my place. [FIN]I am a famous master of [N]disguises. If you saw [N]me in another town, [N]you wouldn't know me. [END]`

dialogstring_08D1E0 `[CLR]But you don't have any[N]Jewels. Let me give[N]you some.[END]`

dialogstring_08D20F `[CLR]Mmm...This is a rare [N]jewel. Let me hold [N]it for you. [FIN]There are now[N][BCD:2,AB0]Jewels in the room.[FIN]`

dialogstring_08D267 `[CLR]I will give you goods[N]for your Jewels as[N]written on the list.[END]`

dialogstring_08D292 `[CLD][DEF][CLR]Well, see ya.[N]Somewhere.[END]`

dialogstring_08D2AA `[CLR]Your inventory seems[N]to be full....[N]Come back again!![END]`

dialogstring_08D2D0 `[CLR]You've collected more [N]than three Jewels![FIN]According to the list,[N]you get the herb![FIN]`

dialogstring_08D31A `You received the herb![FIN]`

dialogstring_08D332 `[CLR]You've collected over [N]five Jewels! According to[N]the list, your Defense [N]Power will be raised. [FIN]Your Defense Power is[N]raised by one.[FIN]`

dialogstring_08D395 `[CLR]You've collected over, [N]eight Jewels! According to[N]the list, your Life [N]Power will be raised. [FIN]Your Strength is[N]raised by one.[FIN]`

dialogstring_08D3F9 `[CLR]You've collected over [N]12 Jewels! According to [N]the list, your Strength [N]will be raised. [FIN]Your Attack Power is[N]raised by one.[FIN]`

dialogstring_08D459 `[CLR]You've collected over [N]20 Jewels! According to [N]the list, your Psycho [N]Power will be raised. [FIN]It's a mysterious power[N]given by the spirit.[FIN]Your Psycho Dash Power[N]is increased.[FIN]`

dialogstring_08D4E3 `[CLR]You've collected over [N]30 Jewels! According to [N]the list, your Dark [N]Power will be raised. [FIN]It's a mysterious power[N]given by the spirit.[FIN]The Dark Friar's power[N]is increased.[FIN]Try pushing the[N]Attack Button once more[N]when the Dark Friar[N]is flying.[FIN]`

dialogstring_08D5AE `[CLR]50... Suddenly[N]you've gathered[N]50 Red Jewels...[FIN]The time has come to[N]tell you some of[N]my secrets.[FIN]Follow me!![END]`

dialogstring_08D611 `[PAL:4]`

dialogstring_08D614 `[PAL:0]`

dialogstring_08D617 `[DLG:3,B][SIZ:8,7][CLR][SFX:0]`

dialogstring_08D621 `[CLR]Herb           3[N][PAL:0]`

dialogstring_08D636 `Defense Force  5[N][PAL:0]`

dialogstring_08D64A `Life Force     8[N][PAL:0]`

dialogstring_08D65E `Strength      12[N][PAL:0]`

dialogstring_08D672 `Psycho Power  20[N][PAL:0]`

dialogstring_08D67D `Dark Power    30[N][PAL:0]`

dialogstring_08D68A `My secrets    50[END]`