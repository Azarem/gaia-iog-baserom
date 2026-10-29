; Called with JSL by cutscene actors (17 call sites in 14 actor files: st68_lily, dc31_kara, it15_lola, it15_lily, av74_kara, btDF_kara, btDE_olman, btDE_monologue, ir1C_lily, na4B_lily, sc06_lily, sc06_kara, dm43_elevator, sc02_seth) to put the player into an idle pose facing a chosen direction before scripted movement.
; 
; Input: A (16-bit) = facing index 0 South, 1 North, 2 West, 3 East (the order of player_idle_entry_table and of GetPlayerFacingDirection); there is no range check. X is set to the player actor slot from $playerActor ($09AA). The routine writes the entry pointer of that actor: $0000,X = the IdleStand* word from the table, $0002,X = the bank byte of IdleStandSouth. The player's script therefore resumes in the idle pose on its next run. It also zeroes the wait counter $0008 and the movement scratch words $002C / $002E, both in the actor's DP page and in the extended data ($7F002C / $7F002E).
; 
; The caller's X is saved with PHX / PLX; Y is untouched; A is clobbered. docs/code/bank00/data-tables-memory.md says the table is selected 'based on body form and scene context'; the routine looks only at A (the IdleStand* handlers themselves branch on the Shadow flag byte #00).
---------------------------------------------

?INCLUDE 'player_character'

!playerActor                    09AA
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Sets the player actor's script entry to IdleStandSouth / North / West / East chosen by A (0..3), resets the wait counter and the movement scratch words, and returns with RTL. See the block note.

SetPlayerIdleFacing {
    PHX                   ; Save the caller's X (its own actor slot, needed for its next COP)
    ASL                   ; A = facing index 0..3 (South, North, West, East) -> word offset; no range check
    TAX 
    LDA $@player_idle_entry_table, X ; Entry address of the IdleStand* handler for that facing
    LDX $playerActor      ; X = player actor slot ($09AA)
    STA $0000, X          ; Player actor entry pointer (low word): its script resumes at IdleStand* on the next run
    SEP #$20
    LDA #$^player_character.IdleStandSouth ; Bank byte of the entry (all four IdleStand* handlers share a bank)
    STA $0002, X
    REP #$20
    STZ $0008, X          ; Wait counter = 0
    STZ $002C, X          ; Clear movement scratch $2C in the actor's DP page
    STZ $002E, X          ; Clear movement scratch $2E in the actor's DP page
    LDA #$0000
    STA $moveScratch1, X  ; Same two words in the extended data ($7F002C / $7F002E)
    STA $moveScratch2, X
    PLX                   ; Restore the caller's X
    RTL 
}

---------------------------------------------
; Four word entries (50960-50967) indexed by A * 2: IdleStandSouth, IdleStandNorth, IdleStandWest, IdleStandEast (the same order as GetPlayerFacingDirection: 0 down, 1 up, 2 left, 3 right). Read with a long-indexed load; all four handlers share one bank.

player_idle_entry_table [
  &player_character.IdleStandSouth   ;00
  &player_character.IdleStandNorth   ;01
  &player_character.IdleStandWest   ;02
  &player_character.IdleStandEast   ;03
]