; ==============================================================================
; LoadPlayerGraphics - boot/continue exprite and extra skip scenes
; ==============================================================================
; What it does: Skips default player CHR upload for more scene ids; scene $FB
;   loads gfx_boot_exprite to VRAM $4200 via load_boot_exprite; scene $FA uses
;   load_continue (same VRAM target, caller-supplied source in X/A).
; Vanilla behavior: Only $F7, $FE, $8C skipped entirely; always DMA gfx_000000
;   to $4200; combat-lock bit $08 on playerFlags chose misc_fx at $4400, else
;   scene $E8 used boss projectile tiles at $4400.
; Hooks (overrides): scene_lifecycle.LoadPlayerGraphics.
; Adds: load_boot_exprite, load_continue (JML/JSL targets; X/A = source, Y = size).
; Depends on: ?INCLUDE scene_script, chunk_03BAE1; DmaWordToVram; labels
;   gfx_boot_exprite, gfx_000000, misc_fx_1CD580.
; State: sceneCurrent $0644; playerFlags $09AE bit $08; VMADDL $2116.
; Hazards/notes: load_exit/load_fb_asset are plain in-patch labels; patch removes
;   vanilla $E8 boss FX branch present in extracted scene_lifecycle.asm.
; ==============================================================================

!scene_current                  0644
!player_flags                   09AE
!VMADDL                         2116

  load_boot_exprite:
    LDX #$&gfx_boot_exprite
    LDA #$^gfx_boot_exprite
    
  load_continue:
    LDY #$4200
    STY $VMADDL
    LDY #$1C00
    JSL $@DmaWordToVram
    PLP
    RTL

------------------------------------------------
?INCLUDE 'scene_script'
?INCLUDE 'chunk_03BAE1'
------------------------------------------------

scene_lifecycle.LoadPlayerGraphics! {
    PHP 
    LDA $scene_current
    CMP #$F7
    BEQ load_exit
    CMP #$FB
    BEQ load_fb_asset
    CMP #$FA
    BEQ load_exit
    CMP #$FE
    BEQ load_exit
    CMP #$F0
    BEQ load_exit
    CMP #$90
    BEQ load_exit
    CMP #$8C
    BEQ load_exit
    CMP #$89
    BEQ load_exit
    LDX #$4200
    STX $VMADDL
    LDX #$&gfx_000000
    LDA #$^gfx_000000
    LDY #$1C00
    JSL $@DmaWordToVram
    LDA $player_flags
    BIT #$08
    BEQ loc_03E035
    LDX #$4400
    STX $VMADDL
    LDX #$&misc_fx_1CD580
    LDA #$^misc_fx_1CD580
    LDY #$0800
    JSL $@DmaWordToVram
    BRA loc_03E04E
    
  load_fb_asset:
    JML load_boot_exprite

  load_exit:
    PLP
    RTL
}
