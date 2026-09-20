; Jeweler Gem — the NPC who collects Red Jewels and grants progressive rewards.
; 
; Gem appears in multiple towns throughout the game. On interaction, he displays the
; player's current Red Jewel count and checks thresholds against event flags:
;   Flag $E9: 3 jewels → Herb (item #06)
;   Flag $EA: 5 jewels → DEF +1
;   Flag $EB: 8 jewels → MaxHP +1 (+ damageFlashTimer for HP bar flash)
;   Flag $EC: 12 jewels → STR +1
;   Flag $ED: 20 jewels → Psycho Dash upgrade ($0B16 = 1)
;   Flag $EE: 30 jewels → Dark Friar upgrade ($0B1C = 2)
;   50 jewels → Warp to Gem's secret room (map $E9)
; 
; The "Give you Red Jewels" option (code_08CF5E → JewelerCountJewels) uses BCD mode to count
; jewel items (item #01) in the 16 inventory slots, adds them to jewelsCollected, then
; removes all jewel items. The "See your inventory" option shows the reward list with
; flag-based completion markers.
; 
; If flag $E8 is set (game complete), Gem auto-dies on spawn.
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

jeweler_gem [
  actor-def < #02, #00, #10, {

  code_08CEA3:
    COP [BranchOnFlagByte] ( #E8, #01, &JewelerDie ) ; If game complete → die
    LDA $0E               ; Spawn param: appearance variant
    ASL 
    ASL 
    ASL                   ; ×8
    CLC 
    ADC #$0002            ; Sprite frame = variant×8 + 2
    STA $28
    STZ $002A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$3000
    STA $0E
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &JewelerInteract )
    COP [SetEntryHere]
    RTL 
} >
]

---------------------------------------------
; Interaction entry — greet and show jewel count if > 0

JewelerInteract {
    COP [PrintDialogString] ( &dialogstring_08D094 ) ; "I am the Jeweler Gem"
    LDA $jewelsCollected
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
; 50-jewel check — triggers warp to secret room

JewelerCheck50 {
    LDA $jewelsCollected
    CMP #$0050            ; Need ≥ 50 jewels (BCD)
    BCC loc_08CF47
    JMP $&JewelerSecretRoom ; → Warp to Gem's secret room

  loc_08CF47:
    COP [PrintDialogString] ( &dialogstring_08D0F1+M ) ; "What's your business?"

  code_08CF4B:
    COP [DialogueOptions] ( #03, #01, &code_list_08CF51 )
}

code_list_08CF51 [
  &code_08CF59   ;00
  &code_08CF59   ;01
  &code_08CF5E   ;02
  &JewelerShowInventory   ;03
]

code_08CF59 {
    COP [PrintDialogString] ( &dialogstring_08D139 )
    RTL 
}

---------------------------------------------
; "Give you Red Jewels" — check if player has jewels, then collect them

code_08CF5E {
    COP [BranchIfMissingItem] ( #01, &JewelerCountJewels ) ; Has jewel items?
    COP [PrintDialogString] ( &dialogstring_08D1E0 ) ; "But you don't have any"
    RTL 
}

---------------------------------------------
; BCD jewel counting — scan all 16 inventory slots for item #01 (Red Jewel)

JewelerCountJewels {
    SED                   ; Enter BCD mode for decimal counting
    STZ $0000             ; Counter = 0
    LDA #$0001            ; Item ID to search for
    SEP #$20              ; 8-bit accumulator for item comparison
    LDY #$0000

  loc_08CF74:
    CMP $inventorySlots, Y ; Check slot Y for Red Jewel
    BNE loc_08CF84        ; Not a match — skip
    PHA 
    LDA $0000             ; BCD increment counter
    CLC 
    ADC #$01
    STA $0000
    PLA 

  loc_08CF84:
    INY 
    CPY #$0010            ; 16 inventory slots
    BNE loc_08CF74
    REP #$20              ; 16-bit mode
    LDA $0000             ; Add BCD count to total
    CLC 
    ADC $jewelsCollected
    STA $jewelsCollected
    CLD                   ; Exit BCD mode

  code_08CF97:
    COP [RemoveItem] ( #01 ) ; Remove all jewel items from inventory
    COP [BranchIfMissingItem] ( #01, &code_08CF97 )
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

code_08D00D {
    COP [PrintDialogString] ( &dialogstring_08D292 )
    RTL 
}

code_08D012 {
    COP [PrintDialogString] ( &dialogstring_08D2AA )
    RTL 
}

---------------------------------------------
; Reward: 3 jewels → Herb

JewelerRewardHerb {
    COP [PrintDialogString] ( &dialogstring_08D2D0 ) ; "You've collected more than three!"
    COP [GiveItem] ( #06, &code_08D012 ) ; Give Herb (item #06)
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
; Reward: 8 jewels → MaxHP +1

JewelerRewardHp {
    INC $playerMaxHp
    LDA #$0001
    STA $damageFlashTimer ; Trigger HP bar flash effect
    COP [SetFlagByte] ( #EB )
    COP [PrintDialogString] ( &dialogstring_08D395 )
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
; Reward: 20 jewels → Psycho Dash upgrade

JewelerRewardPsychoDash {
    LDA #$0001            ; Enable Psycho Dash
    STA $0B16
    COP [SetFlagByte] ( #ED )
    COP [PrintDialogString] ( &dialogstring_08D459 )
    JMP $&JewelerCheck30
}

---------------------------------------------
; Reward: 30 jewels → Dark Friar upgrade

JewelerRewardDarkFriar {
    LDA #$0002            ; Dark Friar power level 2
    STA $0B1C
    COP [SetFlagByte] ( #EE )
    COP [PrintDialogString] ( &dialogstring_08D4E3 )
    JMP $&JewelerCheck50
}

---------------------------------------------
; Reward: 50 jewels → warp to Gem's secret room

JewelerSecretRoom {
    COP [PrintDialogString] ( &dialogstring_08D5AE ) ; "50... Follow me!!"
    LDA #$0202            ; Configure gfx cache for secret room
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E9, #$0330, #$03D0, #80, #$4400 ) ; Warp to secret room
    RTL 
}

---------------------------------------------
; Game complete — Gem no longer appears

JewelerDie {
    COP [Die]
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