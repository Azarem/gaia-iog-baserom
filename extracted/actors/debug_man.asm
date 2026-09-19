; Debug Man — an unused NPC that maxes out player stats and provides a multi-level warp menu.
; 
; On interaction, sets MaxHP/HP to 40, STR/DEF to 127, unlocks all abilities ($FF bitmask),
; then presents a cascading dialogue menu of ~35 map destinations organized by region:
;   Level 1: Others / Great Wall / LAST GAIA LOOK / EDOWA-DO
;   Level 2+: Itorie, Moon Tribe, Underground castle, Euro, Native Village, Dao, INCA,
;             Sky Garden, Palace, Mu, Angel Village, Pyramid, Watermia, Ankor Wat, etc.
; 
; Each destination calls QueueMapChange with hardcoded map ID, coordinates, and direction.
; The "Others" option at each level leads to the next submenu; "Quit" exits with a farewell message.
; Never spawned in the retail release.
---------------------------------------------

!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE

---------------------------------------------

debug_man [
  actor-def < #02, #00, #10, {

  code_0BEE23:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &DebugManInteract )
    COP [SetEntryContinue]
    RTL 
} >
]

---------------------------------------------
; Interaction handler — max stats and show warp menu

DebugManInteract {
    LDA #$0028            ; MaxHP & HP = 40
    STA $playerMaxHp
    STA $playerHp
    LDA #$007F            ; STR & DEF = 127
    STA $playerStr
    STA $playerDef
    LDA #$00FF            ; Unlock all abilities
    STA $abilityBitmask
    COP [PrintDialogString] ( &dialogstring_0BF010 ) ; "Hello! I am Debug-man!"
    COP [DialogueOptions] ( #04, #00, &code_list_0BEE4E )
}

code_list_0BEE4E [
  &DebugManQuit   ;00
  &code_0BEE58   ;01
  &code_0BEED5   ;02
  &code_0BEEF3   ;03
  &code_0BEEE4   ;04
]

code_0BEE58 {
    COP [PrintDialogString] ( &dialogstring_0BF05C )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEE62 )
}

code_list_0BEE62 [
  &DebugManQuit   ;00
  &code_0BEE6C   ;01
  &code_0BEF02   ;02
  &code_0BEF11   ;03
  &code_0BEF20   ;04
]

code_0BEE6C {
    COP [PrintDialogString] ( &dialogstring_0BF095 )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEE76 )
}

code_list_0BEE76 [
  &DebugManQuit   ;00
  &code_0BEE80   ;01
  &code_0BEF2F   ;02
  &code_0BEF3E   ;03
  &code_0BEF4D   ;04
]

code_0BEE80 {
    COP [PrintDialogString] ( &dialogstring_0BF0C3 )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEE8A )
}

code_list_0BEE8A [
  &DebugManQuit   ;00
  &code_0BEE94   ;01
  &code_0BEF5C   ;02
  &code_0BEF6B   ;03
  &code_0BEF7A   ;04
]

code_0BEE94 {
    COP [PrintDialogString] ( &dialogstring_0BF0EC )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEE9E )
}

code_list_0BEE9E [
  &DebugManQuit   ;00
  &code_0BEEA8   ;01
  &code_0BEF89   ;02
  &code_0BEF98   ;03
  &code_0BEFA7   ;04
]

code_0BEEA8 {
    COP [PrintDialogString] ( &dialogstring_0BF10D )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEEB2 )
}

code_list_0BEEB2 [
  &DebugManQuit   ;00
  &code_0BEEBC   ;01
  &code_0BEFB6   ;02
  &code_0BEFC5   ;03
  &code_0BEFD4   ;04
]

code_0BEEBC {
    COP [PrintDialogString] ( &dialogstring_0BF135 )
    COP [DialogueOptions] ( #04, #00, &code_list_0BEEC6 )
}

code_list_0BEEC6 [
  &DebugManQuit   ;00
  &DebugManQuit   ;01
  &code_0BEFE3   ;02
  &code_0BEFF2   ;03
  &code_0BF001   ;04
]

---------------------------------------------
; "Bye bye!" — quit option at every menu level

DebugManQuit {
    COP [PrintDialogString] ( &dialogstring_0BF15A )
    RTL 
}

code_0BEED5 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #82, #$0020, #$0090, #07, #$1800 ) ; Great Wall
    RTL 
}

code_0BEEE4 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #0A, #$01E3, #$00A0, #03, #$4500 ) ; Last Gaia scene
    RTL 
}

code_0BEEF3 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #E5, #$00A8, #$00A0, #00, #$1100 ) ; Edward's Castle
    RTL 
}

code_0BEF02 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #15, #$0339, #$01B0, #00, #$3500 ) ; Itory Village
    RTL 
}

code_0BEF11 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #1A, #$0110, #$00C3, #00, #$2200 ) ; Moon Tribe camp
    RTL 
}

code_0BEF20 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #0F, #$0078, #$05D0, #00, #$6100 ) ; Underground tunnel
    RTL 
}

code_0BEF2F {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #91, #$0370, #$0430, #03, #$5400 ) ; Euro
    RTL 
}

code_0BEF3E {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #07, #$2200 ) ; Natives' Village
    RTL 
}

code_0BEF4D {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #C3, #$0010, #$00E8, #07, #$2300 ) ; Dao
    RTL 
}

code_0BEF5C {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #1C, #$006C, #$0174, #07, #$2200 ) ; Inca Ruins
    RTL 
}

code_0BEF6B {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #32, #$0138, #$0360, #07, #$4500 ) ; Gold Ship
    RTL 
}

code_0BEF7A {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #3E, #$00B0, #$03D0, #07, #$4200 ) ; Diamond Coast
    RTL 
}

code_0BEF89 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #4C, #$0100, #$0136, #07, #$2200 ) ; Sky Garden
    RTL 
}

code_0BEF98 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #5A, #$0088, #$00A0, #07, #$6400 ) ; Seaside Palace
    RTL 
}

code_0BEFA7 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #5F, #$0088, #$0050, #07, #$4400 ) ; Mu
    RTL 
}

code_0BEFB6 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #69, #$02A8, #$00A0, #07, #$1300 ) ; Angel Village
    RTL 
}

code_0BEFC5 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #AC, #$01C8, #$01E0, #07, #$2200 ) ; Natives' Village (alt)
    RTL 
}

code_0BEFD4 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #C3, #$0020, #$00F0, #07, #$2300 ) ; Dao (alt)
    RTL 
}

code_0BEFE3 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #CC, #$002C, #$00E0, #07, #$4400 ) ; Pyramid
    RTL 
}

code_0BEFF2 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #78, #$027E, #$03A0, #07, #$4500 ) ; Watermia
    RTL 
}

code_0BF001 {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #B0, #$0200, #$04D0, #07, #$5400 ) ; Ankor Wat
    RTL 
}

dialogstring_0BF010 `[DEF]Hello! I am Debug-man![N]Where you go?[FIN] Others[N] Great Wall[N] LAST GAIA LOOK[N] EDOWA-DO`

dialogstring_0BF05C `[CLR] Others[N] Itorie[N] HOME OF MOON TRIBE[N] Underground castle`

dialogstring_0BF095 `[CLR] Others[N] City of Euro[N] Native's Village[N] Desert Village Dao`

dialogstring_0BF0C3 `[CLR] Others[N] INCA[N] HANANOMIYAKO[N] DAIYAMONDO`

dialogstring_0BF0EC `[CLR] Others[N] Sky Garden[N] Palace[N] Mu`

dialogstring_0BF10D `[CLR] Others[N] Angel Village[N] Native's Village[N] Dao`

dialogstring_0BF135 `[CLR] Quit[N] Pyramid[N] Watermia[N] Ankor Wat`

dialogstring_0BF15A `[CLR]Bye bye![END]`

dialogstring_0BF164 `[CLR]Ok![N]See you again![END]`