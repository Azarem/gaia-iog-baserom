; Player facing direction lookup — animation-frame-to-direction mapping with form support (258250–258512, Bank 03).
; 
; Determines the player's current facing direction (0–3 = down/up/left/right, the operand order of the facing COP ops) from the player actor's animation frame index ($0028,X), so scripts and enemy AI can ask which way the player is looking. Forms that replace the body sprite use their own per-form frame tables.
; 
; === ALGORITHM ===
; 
; 1. Load playerActor and test playerFlags bit 15 ($8000). That bit is the sprite-override flag (set by SetPlayerSpriteDirect, the transformations and ability poses), not a "transformed" flag as such.
; 2. Bit clear: look up FacingDirectionLookup[$0028,X]. Values 0–3 are cardinal directions; 4 means no facing for that frame.
; 3. Bit set: take $0AC8 (the body_table index last written by SetPlayerSpriteDirect), subtract 4, and index FacingFormOffsetTable with it; the selected table is read at the same animation frame. If $0AC8 < 4 the subtraction is negative and the code falls back to FacingDirectionLookup (step 2).
; 4. Return: carry clear = valid direction (0–3 in A), carry set = no facing (value ≥ 4).
; 
; === DATA TABLES ===
; 
; FacingDirectionLookup (88 bytes): maps each animation frame of the normal body sprite to a direction 0–4.
; 
; FacingFormOffsetTable: 4 pointers, indexed by body_table index − 4, i.e. will_alt, ability_fx, freedan_fx, shadow_fx (body_table 4–7). The FacingData_* labels (Will, Freedan, Shadow_A, Shadow_B) do not match those body names; see the audit rename proposals.
; 
; FacingData_Will (27 bytes) is the first table (body 4), FacingData_Freedan (44 bytes, all zero) the second (body 5), FacingData_Shadow_A (4 bytes, all zero) the third (body 6), FacingData_Shadow_B (6 bytes, all zero) the fourth (body 7). All entries of the last three are 0, i.e. those poses always report direction 0 (down in the COP operand order).
---------------------------------------------

?BANK 03

!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

; Get the player's facing direction from animation frame.
; 
; Loads the player actor's animation frame ($0028,X) and looks up its direction in FacingDirectionLookup (or the per-form table when playerFlags bit 15 is set). Returns 0–3 with carry clear, or carry set if the table value is ≥ 4 (no facing). The caller's X is parked in Y for the call and restored before RTL; P is saved and restored too.

GetPlayerFacingDirection {
    PHP                   ; GetPlayerFacingDirection — save caller X in Y via TXY
    REP #$20
    TXY 
    LDX $playerActor      ; Load playerActor pointer into X
    LDA $playerFlags      ; Bit 15 ($8000) = sprite override → N flag → per-form table path
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
    CLC                   ; Valid direction 0–3 (down, up, left, right order): carry clear, return
    RTL 

  loc_03F0EA:
    TYX 
    PLP 
    SEC 
    RTL 
}

---------------------------------------------
; Fallback target for the sprite-override path (not an external entry point; the only reference is the BMI at 258301). Reached when playerFlags bit 15 is set but $0AC8 − 4 is negative (body_table index 0–3, the base bodies): it discards the extra pushed Y and rejoins the normal FacingDirectionLookup path at loc_03F0D6. The form-table code that follows it (loc_03F0F1) is the real sprite-override path, entered by the BMI at 258260.

GetPlayerFacing_AltEntry {
    PLY                   ; Drop the extra Y pushed at loc_03F0F1 (Y again = caller X), then use the normal lookup
    BRA loc_03F0D6

  loc_03F0F1:
    PHY 
    TXY 
    LDA $0AC8             ; body_table index last set by SetPlayerSpriteDirect
    AND #$00FF
    SEC 
    SBC #$0004            ; body index − 4 → entry in FacingFormOffsetTable (body 4–7)
    BMI GetPlayerFacing_AltEntry ; Body 0–3 → fall back to the standard FacingDirectionLookup
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