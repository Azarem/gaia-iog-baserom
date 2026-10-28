; Boot logo sequence actor - scene $FB master controller (the first scene of the game). Scene $FB is entered TWICE at power-on and shows one logo per visit; the second logo then hands over to the title screen scene $FC.
; 
; === SEQUENCE ===
; 
; 1. BootLogoInit (both visits): sets displayModeFlags bit 14 (no reader found, OQ-I034-1), clears colour 0 of the palette staging buffer, enables FastROM (MEMSEL = $01), puts only the sprite layer on the main screen (TM = $10, bit 4 = OBJ; no BG is shown), masks the joypad, then reads STAT78 bit 4: 0 = 60 Hz NTSC continues, 1 = 50 Hz PAL jumps to BootLogoPalLockout.
; 2. First visit (event flag $10 clear): nudge the actor Y -16, play sprite animation #01 (sprite_group_000112, a 96 x 48 logo on OBJ palette 3) for 2 passes of 60 ticks = 120 ticks, set event flag $10, QueueMapChange to scene $FB itself, Die.
; 3. Second visit (flag set): BootLogoSecondPhase plays animation #00 (sprite_group_000010, the Enix logo: an emblem with a wordmark under it, OBJ palettes 0, 1, 2 and 4) for 120 ticks, clears flag $10 and queues scene $FC (title screen), Die.
; Event flag $10 is not one of the flags the scene load zeroes (only $00 to $0F are), which is why it survives the reload; it is cleared again at the end because the South Cape church scripts (sc08_*) use the same flag.
; 
; The three boot_logo_enix_palette_obj* thinkers are spawned by the scene's thinker list in both visits and run the Enix logo's palette cycle on OBJ palettes 0, 1 and 2, i.e. only the second logo (see boot_logo_enix_palette_obj0).
; 
; === PAL LOCKOUT ===
; 
; A 50 Hz console never sees a logo: BootLogoPalLockout draws the region warning text (boot_title_strings) on BG3 and then yields forever at SetEntryHere + RTL. The game cannot be started on a PAL console.
; 
; === POSITION ===
; 
; The scene's actor-spawn places the actor at tile (7, 8) and InitActorFromSceneData adds 8 pixels of X for normal actors; the first NudgePosition adds another 8, so the actor ends at X = 128, the centre of the 256-pixel screen. The sprite groups are laid out around that origin. QueueMapChange's last operand $1100 is the packed camera-bounds override (InitCameraBounds).
; 
; === SPRITES (spm_boot_logos.sprite.asm) ===
; 
; The scene's spritemap card loads spm_boot_logos ($018F bytes) to $7E4000; its two entries are the animation indexes of StageSpriteLoop: #00 = sprite_set_000004 (second logo), #01 = sprite_set_00000A (first logo). Each sprite-set is one frame record (hold $003B = 60 ticks per pass, group pointer) closed by the hidden $FFFF delimiter.
; First logo, sprite_group_000112: 96 x 48 px, 16 parts of 16 x 16 in rows of 6, 6 and 4, all OBJ palette 3.
; Second logo, sprite_group_000010: 122 x 156 px, 35 parts: a 4 x 4 block (64 x 64) on OBJ palette 1 (upper two rows) and 0 (lower two rows), a 4 x 2 block below it on palette 2, and a row of 11 parts 12 px apart on palette 4. Palettes 0 to 2 are the ones the boot_logo_enix_palette_obj* thinkers animate; palette 4 is static.
; The format (pointer table, frame list, group header with its two collision boxes, 7-byte parts) is described in the spm_boot_logos block note. The palettes come from pal_boot_logos (80 colours, OBJ palettes 0 to 4, loaded at CGRAM colour 128). The second logo is the Enix logo (its palette cycle is the three boot_logo_enix_palette_obj* thinkers); which company the first logo belongs to was not checked against the tile art.
; 
; === NOTES ===
; 
; The joypad mask in the ROM is $FFFC (db-us/transforms.json rewrites $FFF0 to $FFFC for this block), which hides every pad bit including Start and Select, so no logo can be skipped. The old header said TM = $10 puts BG1 on the main screen and that the mask is $FFF0; TM bit 4 is the OBJ layer and the shipped mask is $FFFC.
---------------------------------------------

?INCLUDE 'system_strings'

!joypadMaskStd                  065A
!displayModeFlags               09EC
!TM                             212C
!STAT78                         213F
!MEMSEL                         420D
!cgramPalette                   7F0A00

---------------------------------------------

sFB_boot_logo [
  actor-def < #00, #00, #18, {

; Entry, both visits. Display set-up (bit 14 of displayModeFlags, black backdrop, FastROM, TM = OBJ only, joypad mask), then STAT78 bit 4 decides: 60 Hz falls through to BootLogoNtsc, 50 Hz jumps to BootLogoPalLockout.

  BootLogoInit:
    LDA #$4000            ; Bit 14 of displayModeFlags: no reader found (OQ-I034-1)
    TSB $displayModeFlags
    LDA #$0000
    STA $cgramPalette     ; Colour 0 of the palette staging buffer = black backdrop
    SEP #$20
    LDA #$01              ; Enable FastROM (3.58 MHz bus)
    STA $MEMSEL
    LDA #$10              ; TM = $10: only the sprite layer (bit 4 = OBJ) on the main screen, no BG
    STA $TM
    REP #$20
    LDA #$FFFC            ; Joypad mask: the ROM has $FFF0 and transforms.json widens it, hiding every pad bit incl. Start and Select
    TSB $joypadMaskStd
    SEP #$20
    LDA $STAT78           ; STAT78 ($213F): PPU2 version and refresh rate
    BIT #$10              ; Bit 4: PAL/NTSC detection (1=PAL)
    BEQ BootLogoNtsc      ; NTSC → normal sprite logo sequence
    JMP $&BootLogoPalLockout ; PAL → text-only boot screen

; NTSC path. Centres the actor (X +8), then splits on event flag $10: set = second visit (BootLogoSecondPhase); clear = first visit: Y -16, animation #01 for 2 passes, set the flag, reload scene $FB, Die.

  BootLogoNtsc:
    REP #$20
    COP [NudgePosition] ( #08, #00 ) ; X +8: with the +8 added at spawn the actor stands at X = 128, the screen centre
    COP [BranchOnFlagByte] ( #10, #01, &BootLogoSecondPhase ) ; Event flag $10 set = second visit: branch to BootLogoSecondPhase
    COP [NudgePosition] ( #00, #F0 ) ; Nudge Y −16px ($F0 signed)
    COP [StageSpriteLoop] ( #01, #02 ) ; Animation #01 (first logo): 2 passes of 60 ticks
    COP [AnimLoop]        ; Plays the loop and yields until both passes are done (120 ticks)
    COP [SetFlagByte] ( #10 ) ; Set event flag $10: it survives the scene reload
    COP [QueueMapChange] ( #FB, #$0000, #$0000, #00, #$1100 ) ; Reload scene $FB for the second logo ($1100 = camera-bounds override)
    COP [Die]
} >
]

---------------------------------------------
; Second visit: animation #00 (the emblem logo) for 2 passes of 60 ticks, clear event flag $10, QueueMapChange to scene $FC (title screen) with the same $1100 camera-bounds operand, Die.

BootLogoSecondPhase {
    COP [StageSpriteLoop] ( #00, #02 ) ; Animation #00 (second logo): 2 passes of 60 ticks
    COP [AnimLoop]
    COP [ClearFlagByte] ( #10 ) ; Clear event flag $10 again: scene loads zero only $00-$0F and the South Cape church scripts use it
    COP [QueueMapChange] ( #FC, #$0000, #$0000, #00, #$1100 ) ; Transition to title screen (scene $FC)
    COP [Die]
}
---------------------------------------------

; PAL lockout screen. Copies the first 8 colours of pal_ending_comet into staging colours 0 to 7, forces colour 0 to black, draws the region warning (boot_title_strings) on BG3 and sets TM = $04 (BG3 only). The actor then yields every frame at the SetEntryHere / RTL pair and never leaves. Only the warning is drawn: PUSH START and the copyright string belong to the title scene.

BootLogoPalLockout {
    REP #$20
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 ) ; First 8 colours of pal_ending_comet into staging colours 0-7 (the text palette)
    LDA #$0000
    STA $cgramPalette     ; Colour 0 of the palette staging buffer = black backdrop
    COP [RunBg3Script] ( @system_strings.boot_title_strings ) ; Draw the region warning text (boot_title_strings) on BG3
    SEP #$20
    LDA #$04              ; BG3 only — text layer for PAL boot
    STA $TM
    REP #$20
    COP [SetEntryHere]    ; Re-entry point is the RTL below: yields every frame, the lockout screen is never left
    RTL 
}