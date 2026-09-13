; Player facing direction lookup — animation-frame-to-direction mapping with form support (258250–258512, Bank 03).
; 
; Determines the player's current facing direction (0–3 = down/up/left/right) from the actor's animation frame index ($0028,X). Supports multiple character forms (Will, Freedan, Shadow A/B) with per-form lookup tables.
; 
; === ALGORITHM ===
; 
; 1. Load playerActor and check playerFlags bit 15 (transformed flag).
; 2. If not transformed: direct lookup via FacingDirectionLookup[$0028,X]. Returns 0–3 for cardinal directions, 4 for special/invalid.
; 3. If transformed: reads form ID from $0AC8, subtracts 4 (base form offset), indexes FacingFormOffsetTable to get the form-specific data table offset, then looks up the direction from the form's table at the animation frame offset.
; 4. Return: carry clear = valid direction (0–3 in A), carry set = special/invalid direction (≥4).
; 
; === DATA TABLES ===
; 
; FacingDirectionLookup (88 bytes): Master lookup for Will's base animation frames. Maps each frame index to direction 0–4.
; 
; FacingFormOffsetTable: 4 pointers to per-form data: Will, Freedan, Shadow_A, Shadow_B.
; 
; FacingData_Will (27 bytes): Will's direction mapping per animation frame.
; FacingData_Freedan (44 bytes): Freedan's mapping (all zeros — Freedan always faces down? Or data is direction-independent).
; FacingData_Shadow_A (4 bytes), FacingData_Shadow_B (6 bytes): Shadow form mappings.
---------------------------------------------

?BANK 03

!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

; Get the player's facing direction from animation frame.
; 
; Loads playerActor's animation frame ($0028,X), looks up direction in FacingDirectionLookup table. Returns 0–3 (down/up/left/right) with carry clear. Returns carry set if direction ≥ 4 (special/invalid). Saves and restores caller's X register via Y.

GetPlayerFacingDirection {
    PHP                   ; GetPlayerFacingDirection — save caller X in Y via TXY
    REP #$20
    TXY 
    LDX $playerActor      ; Load playerActor pointer into X
    LDA $playerFlags      ; playerFlags bit 15 set → transformed form (AltEntry path)
    BMI loc_03F0F1

  loc_03F0D6:
    LDA $0028, X          ; Load animation frame from actor+$0028
    TAX 
    LDA $@FacingDirectionLookup, X ; Index FacingDirectionLookup[frame] → direction 0–3
    AND #$00FF
    CMP #$0004            ; Direction ≥4 = invalid/unknown facing (carry set on return)
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC                   ; Valid direction 0–3: CLC, RTL (0=down, 1=up, 2=left, 3=right)
    RTL 

  loc_03F0EA:
    TYX 
    PLP 
    SEC 
    RTL 
}

---------------------------------------------
; Alternate entry point for transformed player forms.
; 
; Called when playerFlags bit 15 is set (transformed). Reads form ID from $0AC8, subtracts 4 (base form offset), indexes FacingFormOffsetTable to get the form-specific lookup table, then reads direction from the form's data at the animation frame offset. Falls through to the same return logic as GetPlayerFacingDirection.

GetPlayerFacing_AltEntry {
    PLY                   ; Alt entry: restore saved X from stack, join normal lookup path
    BRA loc_03F0D6

  loc_03F0F1:
    PHY 
    TXY 
    LDA $0AC8             ; Read player form ID from $0AC8
    AND #$00FF
    SEC 
    SBC #$0004            ; Form ID − 4 → index into FacingFormOffsetTable (forms 4–7)
    BMI GetPlayerFacing_AltEntry ; Form < 4 (Will) → fall back to standard FacingDirectionLookup
    ASL 
    TAX 
    LDA $@FacingFormOffsetTable, X ; Load form-specific facing data table pointer
    SEC 
    SBC #$&FacingFormOffsetTable
    CLC 
    ADC $0028, Y          ; Index = actor animation frame ($0028,Y) into form table
    TAX 
    PLY 
    LDA $@FacingFormOffsetTable, X ; Load facing byte from form-specific table
    AND #$00FF
    CMP #$0004            ; Direction ≥4 → invalid (carry set); 0–3 → CLC success
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC 
    RTL 
}

FacingDirectionLookup #00010203000102030001020300010203000102030001020300000000000101010202020303030101000001000100010002030203020300010203000102030001020302030001020300010404040404040001020304040404

FacingFormOffsetTable [
  &FacingData_Will   ;00
  &FacingData_Freedan   ;01
  &FacingData_Shadow_A   ;02
  &FacingData_Shadow_B   ;03
]

FacingData_Will #000102030001020300010203000000010101020202030303040404

FacingData_Freedan #0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

FacingData_Shadow_A #00000000

FacingData_Shadow_B #000000000000