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


HudTilemapData! [
  #$2CCE   ;06
  #$2CCF   ;07
  #$0000   ;08
  #$0008   ;09
  #$ECEF   ;0A
  #$2CDA   ;0B
  #$2CDB   ;0C
  #$2CDC   ;0D
  #$2CDD   ;0D
  #$ACE9   ;0D
  #$ECE9   ;0D
  #$6CDD   ;0D
  #$6CDC   ;10
  #$6CDB   ;11
  #$6CDA   ;12
  #$ACEF   ;13
  #$0000   ;14
  #$0008   ;15
  #$6CCF   ;16
  #$6CCE   ;17
  #$2CDE   ;1A
  #$0000   ;1B
  #$000A   ;1C
  #$2CEA   ;1D
  #$2CD9   ;1E
  #$0000   ;1F
  #$0001   ;20
  #$2CED   ;21
  #$0000   ;1F
  #$0002   ;20
  #$6CED   ;22
  #$0000   ;23
  #$0002   ;24
  #$6CEA   ;25
  #$0000   ;26
  #$000A   ;27
  #$6CDE   ;28
  #$2CEE   ;2B
  #$0000   ;2C
  #$000A   ;2D
  #$2CFA   ;2E
  #$2CFB   ;2F
  #$2CFC   ;30
  #$2CFD   ;31
  #$2CE9   ;33
  #$6CE9   ;33
  #$6CFD   ;32
  #$6CFC   ;32
  #$6CFB   ;34
  #$6CFA   ;35
  #$0000   ;36
  #$000A   ;37
  #$6CEE   ;38
  #$0000   ;39
  #$0000   ;3A
]



------------------------------------------------

;DMA size
loc_02B06D! {
    AND #$DF
    STA $09EC
    LDX #$00C0  ;Three lines of tiles
    STX $DAS0L
}

----------------------------------------------

;VRAM DMA arguments (when copying BG3 layer)
loc_02B078! {
    LDX #$7820
    STX $VMADDL
    LDX #$0240
    STX $A1T0L
}

---------------------------------------------

ClearVramBufferPartial! {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$00C0
    BRA loc_02F07E
}

consolestring_01E7F6! |[POS:42,0][PAL:8][HP][POS:5A,0][PAL:14][BCD:1,AD8][POS:64,0][NUM:AD6]|

consolestring_01E818! |[PAL:4][POS:6A,0][HE]|


-------------------------------------------------
;Prevent unequipped message
UseItem_None! {
    RTS 
}

------------------------------------------------
;Disable continue option when saving

GaiaSaveConfirm! {
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
    BRA GaiaDontRecord
}

-----------------------------------------------
;Disable region protection

BootLogoPalTextFallback! {
    BRA loc_0BC8EA
}

-----------------------------------------------
?INCLUDE 'sF7_credits'

dialogstring_09F2FA! `[PAL:0][DLG:44,1]     Built With GaiaLabs[N][PAL:4]         By Kassiven[N][PAL:0]            Ǫįņţ[N]            ęťĔŇ[END]`!


--------------------------------------------
?INCLUDE 'inventory_menu'
--------------------------------------------
;Force some palette colors for cleaner font
InventoryMenuInit- [
    LDA #$4063
    STA $7F0A06
    LDA #$2180
    STA $7F0A2E
]

;Make flashing cursor show blank when hidden
YesNoClearCursor! {
    LDA #$0001
    TSB $09EC
    LDA #$2060
    STA $7F0896
    STA $7F0916
    RTS 
}

;Make flashing cursor show blank when hidden
TabClearCursor! {
    LDA #$0001
    TSB $09EC
    LDA #$2060
    STA $7F0784
    STA $7F0804
    STA $7F0884
    STA $7F0904
    RTS 
}
