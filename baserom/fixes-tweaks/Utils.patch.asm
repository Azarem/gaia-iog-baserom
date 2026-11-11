; ==============================================================================
; Misc engine tweaks - boot, save, HUD font, credits string
; ==============================================================================
; What it does: Skips PAL boot lockout, silences empty-slot item message,
;   removes continue from Gaia save confirm, retitles credits, tints inventory
;   menu palette RAM at init.
; Vanilla behavior: PAL shows region warning; UseItem_None prints text;
;   GaiaSaveConfirm offers continue; licensed Nintendo credits string.
; Hooks (overrides): sFB_boot_logo BootLogoPalLockout; item_use_system UseItem_None;
;   sE6_gaia GaiaSaveConfirm; sF7_credits dialogstring_09F2FA; inventory_menu
;   InventoryMenuInit prepend (palette stores).
; Depends on: chunk includes listed below, SaveGameState_Scene JSL.
; Hazards/notes: GaiaSaveConfirm masks joypad $FFF0 during COP DA; boot patch
;   is unconditional BRA to NTSC path.
; ==============================================================================

?BANK 03

?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_03BAE1'
?INCLUDE 'system_strings'
?INCLUDE 'sE6_gaia'
?INCLUDE 'sFB_actor_0BC8BA'

!token                          00E6
!joypad_mask_std                065A
!camera_offset_x                06D6
!camera_offset_y                06D8
!camera_bounds_x                06DA
!camera_bounds_y                06DC
!VMADDL                         2116
!A1T0L                          4302
!DAS0L                          4305

------------------------------------------------

;Button flags
;8000 - (B) Attack/Talk
;4000 - (Y) Item/Cancel
;2000 - (SEL) Menu
;1000 - (STA) Pause
;0800 - UP
;0400 - DOWN
;0200 - LEFT
;0100 - RIGHT
;0080 - (A) Nothing
;0040 - (X) Nothing
;0020 - (L) Spin
;0010 - (R) Spin


---------------------------------------------------------

;Prevent drawing of HUD BG layers
;code_03DED5 {
;    PHP
;    REP #$20
;    LDA #$0001
;    TSB $09EC
;    PLP
;    RTL
;}

-------------------------------------------------
;Prevent unequipped message
item_use_system.UseItem_None! {
    RTS 
}

------------------------------------------------
;Disable continue option when saving

sE6_gaia.GaiaSaveConfirm! {
    LDA $0D8C
    JSL $@SaveGameState_Scene
    COP [07] ( #29 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [DA] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    ;COP [BF] ( &dialogstring_08DDFE )
    ;COP [BE] ( #02, #01, &code_list_08DBD4 )
    BRA GaiaThenGo
}

-----------------------------------------------
;Disable region protection

sFB_boot_logo.BootLogoPalLockout! {
    BRA BootLogoNtsc
}

-----------------------------------------------
?INCLUDE 'sF7_credits'

sF7_credits.dialogstring_09F2FA! `[PAL:0][DLG:44,1]     Built With GaiaLabs[N][PAL:4]         By Kassiven[N][PAL:0]            Ǫįņţ[N]            ęťĔŇ[END]`!


--------------------------------------------
?INCLUDE 'inventory_menu'
--------------------------------------------
;Force some palette colors for cleaner font
inventory_menu.InventoryMenuInit- [
    LDA #$4063
    STA $7F0A06
    LDA #$2180
    STA $7F0A2E
]

