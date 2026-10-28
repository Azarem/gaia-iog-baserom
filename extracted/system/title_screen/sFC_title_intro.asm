; Title scene $FC intro actor (Bank 0B, 772391-772487, plus the comet actor and an unreferenced palette-fade stub below it). Spawned with sFC_title_start_handler by scene_FC_actors, the title scene's actor list.
; 
; Loads the title palette, spawns TitleCometSpriteActor, shows two BG3 text strings on a timer and, after a ~42-second idle period (WaitWord $09D3 = 2516 ticks), sets event flag $F4 and queues scene $8C (the prologue). Flag $F4 is tested by pr8C_prologue1 (BranchOnFlagByte, branch when clear) and pr8C_prologue5 (branch when set) and cleared again in pr8C_prologue1, so it marks 'the prologue was started by the title's idle timeout'.
; 
; === DISPLAY LAYERS ===
; 
; TM starts at $10 (OBJ only: the comet sprites are the first thing on screen; the title picture is not on a main-screen layer yet). TitleCometSpriteActor later writes TM = $16 (BG2 + BG3 + OBJ) after its sprite animation, which brings in the title picture and the BG3 text layer.
; 
; === TEXT TIMING ===
; 
; Two BG3 text scripts are shown in sequence:
; - consolestring_01DA5E after WaitByte $B3 (180 ticks, ~3 seconds)
; - consolestring_01DA47 after WaitByte $77 more (120 ticks, ~2 seconds)
---------------------------------------------

?INCLUDE 'system_strings'

!gfxCacheIdxB                   064A
!displayModeFlags               09EC
!TM                             212C
!cgramPalette                   7F0A00

---------------------------------------------

sFC_title_intro [
  actor-def < #00, #00, #30, {

; Actor entry: set the display flags, load the palettes (pal_title over CGRAM colours 0-31, then pal_ending_comet over colours 0-7), spawn the comet, set TM = $10, then run the timed text sequence and the idle wait that ends in the queued change to the prologue scene.

  TitleIntroInit:
    LDA #$4001            ; displayModeFlags: bit 14 = HUD off, bit 0 = full BG3 upload request
    TSB $displayModeFlags
    COP [CopyPalette] ( @pal_title, #00, #00, #20 ) ; Full title palette (32 colors)
    COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 ) ; pal_ending_comet: 8 colours over CGRAM colours 0-7 (replaces the first 8 title colours)
    LDA #$0000            ; Colour 0 (backdrop) := black in the palette staging
    STA $cgramPalette
    COP [SpawnAfterAbsFlags] ( @TitleCometSpriteActor, #$0080, #$0050, #$1800 ) ; Spawn comet actor at (128,80)
    SEP #$20
    LDA #$10              ; TM = $10: OBJ only (comet sprites first)
    STA $TM
    REP #$20
    LDA #$0804            ; gfxCacheIdxB = $0804: transition speed bytes (exit $04, enter $08)
    STA $gfxCacheIdxB
    COP [WaitByte] ( #B3 ) ; WaitByte #B3 = 180 ticks (~3 sec)
    COP [RunBg3Script] ( @system_strings.consolestring_01DA5E ) ; First title text string
    COP [WaitByte] ( #77 ) ; WaitByte #77 = 120 ticks (~2 sec)
    COP [RunBg3Script] ( @system_strings.consolestring_01DA47 ) ; Second title text string
    COP [WaitWord] ( #$09D3 ) ; WaitWord #$09D3 = 2516 ticks (~42 sec idle)
    COP [SetFlagByte] ( #F4 ) ; Set event flag $F4 (read by pr8C_prologue1/5; cleared in pr8C_prologue1)
    LDA #$0804            ; Speed bytes again for the fade into the prologue (exit $04, enter $08)
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 ) ; Transition to scene $8C (prologue)
    COP [SetEntryHere]
    RTL 
} >
]

---------------------------------------------
; Title comet sprite actor (spawned by TitleIntroInit at ($80,$50)). Runs animation #00 for 240 loop cycles in place, then 64 loop cycles with X speed 2 (StageSpriteLoopMoveX), waits 60 ticks (WaitByte #3B), switches TM to $16 and parks on SetEntryHere. Its frames come from spm_title_actors.

TitleCometSpriteActor {
    COP [SetSpritePriority] ( #10 ) ; Sprite priority $10
    COP [StageSpriteLoop] ( #00, #F0 ) ; Animation #00, 240 loop cycles (held in place)
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #00, #40, #02 ) ; Animation #00, 64 loop cycles, X speed 2 (the sweep)
    COP [AnimLoop]
    COP [WaitByte] ( #3B ) ; WaitByte #3B = 60 ticks (~1 sec) after the sweep
    SEP #$20
    LDA #$16              ; TM = $16: BG2 + BG3 + OBJ (adds the title picture and the BG3 text layer)
    STA $TM
    REP #$20
    COP [SetEntryHere]    ; Persist as idle actor
    RTL 
}

---------------------------------------------
; Palette-animation stub: PaletteStart #2D (45 decimal), one PaletteStep, then Die. No spawn or pointer to it exists anywhere in extracted/ (UNVERIFIED-RUNTIME whether anything reaches it).

TitlePaletteStep_noref {
    COP [PaletteStart] ( #2D ) ; Palette animation #2D (45)
    COP [PaletteStep]     ; Step one fade frame
    COP [Die]
}