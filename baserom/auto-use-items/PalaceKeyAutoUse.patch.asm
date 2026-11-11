; ==============================================================================
; Seaside Palace Key auto-use (scene $5A) - door actor + scene spawn
; ==============================================================================
; What it does: Adds a palace door interact actor in scene $5A. With Palace Key
;   (#10) or key_item_flags+1 bit $20 set, interact runs ItemUseStub at
;   code_03915D (vanilla keyhole use); else shows flavor dialog.
; Vanilla behavior: Palace Key use only from inventory at tiles ($08,$07)-($0A,$08)
;   in scene $5A via UseItem_PalaceKey; no standalone door actor in scene table.
; Hooks (overrides): scene_actors.scene_5A_actors+= appends sp5A_door spawn.
; Adds: sp5A_door actor-def (flag word #$0138, WaitOnFlagWord); A=#&code_03915D
;   then JML ItemUseStub on use path.
; Depends on: !key_item_flags $0B58 (collectible-system); ItemUseStub;
;   item_use_system code_03915D handler.
; State: Flag word #$0138 door opened; key_item_flags+1 $0020 Palace Key bit;
;   item #10; scene $5A spawn at (#2F,#19) slot #3B.
; Hazards/notes: COP interact path; BranchIfHasItem / flag bit mirror auto-use
;   pattern from key_item_core.
; ==============================================================================

!key_item_flags      0B58

------------------------------------------------

sp5A_door [
  actor-def < #00, #00, #30, {
    COP [BranchOnFlagWord] ( #0138, #01, &sp5A_door_die )
    COP [NudgePosition] ( #08, #08 )
    COP [SetInteractHandler] ( &sp5A_door_interact )
    COP [WaitOnFlagWord] ( #0138, #01 )

  sp5A_door_die:
    COP [Die]

  sp5A_door_interact:
    LDA $key_item_flags+1
    BIT #$0020
    BNE sp5A_door_use
    COP [BranchIfHasItem] ( #10, &sp5A_door_use )
    COP [PrintDialogString] ( &sp5A_door_interact_str )
    RTL

  sp5A_door_use:
    LDA #&code_03915D
    JML $@ItemUseStub
  } >
]

sp5A_door_interact_str `[DEF]What a strange door...[END]`

scene_actors.scene_5A_actors+= [
  actor-spawn < #2F, #19, #3B, @sp5A_door >
]