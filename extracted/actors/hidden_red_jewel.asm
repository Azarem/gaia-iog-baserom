; Hidden Red Jewel pickup (Bank 00, 50802-50853 plus two dialog strings): a small interactable that gives item $01 (Red Jewel) once and remembers it in a persistent event flag. The same file also holds HiddenRedJewelInventoryFull, which seven NPC scripts jump into for their own 'jewel gift but inventory full' message.
; 
; === SPAWN AND FLAG ===
; 
; actor-def <#00,#00,#30>. The spawn record's odd type byte is shifted right by one into $0E (the actor never overwrites it). Sixteen placements exist, one per scene, with $0E = 0..F, so the flag index $0E + $80 runs over $80..$8F on the event-flag base $0200 (flags $0280-$028F, bytes $0A50-$0A51; chests use the lower indices of the same base):
; 
; | Scene | Area | Type byte | $0E |
; |-------|------|-----------|-----|
; | 03 | south_cape/lances_house | 01 | 0 |
; | 01 | south_cape/south_cape | 03 | 1 |
; | 13 | edward_castle/aqueduct_exit | 05 | 2 |
; | 15 | itory/itory_village | 07 | 3 |
; | 30 | freejia/oakton | 09 | 4 |
; | 39 | freejia/freejia_hotel | 0B | 5 |
; | 6C | angel_village/angel_rooms | 0D | 6 |
; | 74 | angel_village/angel_tunnel_rooms | 0F | 7 |
; | 78 | watermia/watermia | 11 | 8 |
; | 7B | watermia/gambling_house | 13 | 9 |
; | 91 | euro/euro | 15 | A |
; | 9D | euro/dark_chapel | 17 | B |
; | AE | native_village/gorgon_hut | 19 | C |
; | C3 | dao/dao | 1B | D |
; | CC | pyramid/pyramid_main | 1D | E |
; | DF | babel_tower/babel_lower_floors | 1F | F |
; 
; The flag is not tested at spawn time: the actor is always placed and simply does nothing once its flag is set.
; 
; === INTERACTION ===
; 
; The init script sets the interact handler, the metasprite (spriteset_pickups_effects), sprite and hitbox config #00 and idles with SetEntryHere + RTL. HiddenRedJewelInteract: A := $0E + $80, TestEventFlag_0200. Flag set: return silently. Flag clear: COP GiveItem ( #01, &HiddenRedJewelInventoryFull ); on success print HiddenRedJewelFoundString ('You found a Red Jewel!') and set the flag; if the inventory is full GiveItem branches to HiddenRedJewelInventoryFull, which prints HiddenRedJewelFullString and returns without setting the flag, so the jewel can be tried again later. GiveItem itself prints nothing; the dialog is this script's own.
; 
; === NPC JUMPS ===
; 
; gs2B_seth, nvAE_stone_girl2, wa79_lance, fr32_creep, eu95_ann, sc01_fisherman and ec0A_right_guard each end their gift script with JML @hidden_red_jewel.HiddenRedJewelInventoryFull when GiveItem reports a full inventory. They do not use the interact handler or the flag range above.
; 
; Whether the jewel is visible and what the metasprite looks like was not checked (OQ-I041-7).
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'spriteset_pickups_effects'

---------------------------------------------

hidden_red_jewel [
  actor-def < #00, #00, #30, {

; Actor entry (after the 3-byte header): install the interact handler, set the metasprite and hitbox, then idle. $0E (spawn type >> 1) is left untouched for the flag index.

  code_00C672:
    COP [SetInteractHandler] ( &HiddenRedJewelInteract ) ; Install the interact handler
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Metasprite spriteset_pickups_effects, sprite / hitbox config #00; $0E (spawn type >> 1) is left untouched for the flag index
    COP [StageSprAndHitbox] ( #00 )
    COP [SetEntryHere]    ; Idle: the actor only waits for the interact handler
    RTL 
} >
]

---------------------------------------------
; Interact handler. A = $0E + $80 is the event-flag index on base $0200. Flag set: return. Otherwise give item $01; on success show the found string and set the flag; on a full inventory GiveItem jumps to HiddenRedJewelInventoryFull and the flag stays clear.

HiddenRedJewelInteract {
    LDA $0E               ; Flag index = $0E + $80 ($80..$8F on event-flag base $0200); TestEventFlag_0200 returns carry set = already collected
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS HiddenRedJewelDone ; Already collected: leave without a message
    COP [GiveItem] ( #01, &HiddenRedJewelInventoryFull ) ; Give item $01 (Red Jewel); a full inventory jumps to HiddenRedJewelInventoryFull
    COP [PrintDialogString] ( &HiddenRedJewelFoundString ) ; 'You found a Red Jewel!'
    LDA $0E               ; Same flag index again: remember the pickup (SetEventFlag_0200)
    CLC 
    ADC #$0080
    JSL $@flag_helpers.SetEventFlag_0200
    RTL 
}

---------------------------------------------
; GiveItem overflow target and the shared jump target of seven NPC gift scripts: print the 'found a Jewel but your inventory is full' string, then fall into the RTL.

HiddenRedJewelInventoryFull {
    COP [PrintDialogString] ( &HiddenRedJewelFullString ) ; Inventory full text; the flag stays clear

; Shared RTL: also the exit taken when the flag is already set.

  HiddenRedJewelDone:
    RTL                   ; Shared RTL: also the exit taken when the flag was already set
}

---------------------------------------------
; Success text: 'You found a Red Jewel!'

HiddenRedJewelFoundString `[DLG:3,11][SIZ:D,3]You found a Red Jewel![END]`

---------------------------------------------
; Failure text: 'You found a Jewel but your inventory is full.'

HiddenRedJewelFullString `[DLG:3,11][SIZ:D,3]You found a Jewel but[N]your inventory is full.[END]`