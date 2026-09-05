?BANK 02

?INCLUDE 'chunk_028000'

-- Patch for bitmap loading which adds support for no compression

!LSAMPLE	       $10
!LOOPNUM	       $12
!SPTR		         $3E
!DPTR		         $5E
!TPTR1		       $72
!TPTR2		       $75
!DCMP_SIZE	     $78


--------------------------------------------
;Main bitmap handler

loc_028503 {
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    CMP #$0001
    BMI func_028555
    CPX #$066C
    BNE loc_028520
    LDA $06EE
    BIT #$0800
    BEQ loc_028520
    JMP $&func_0285DB
}
    
func_028555 {
    CPX #$066C
    BNE func_028560
    LDA $06EE
    BIT #$0800
    BEQ func_028560
    JMP $&code_0285F3
}

-------------------------------------------
;First pass, copy palette information into VRAM from tileset


code_0285F3 {
    PHY				-- Y will be our read offset
    PHB				-- data bank will be changed

    LDA SPTR			-- init offset for temp pointers
    STA TPTR1
    CLC
    ADC #$0010
    STA TPTR2

    SEP #$20	

    LDA SPTR+2		-- init bank for temp pointers
    STA TPTR1+2
    STA TPTR2+2

    LDA #$7E			-- set data bank to $7E
    PHA
    PLB
    STZ $0E			-- ??
    LDY #$A000		-- init DPTR with WRAM offset
    STY DPTR
    JSR sub_02868C	-- this call changes SPTR to reference WRAM tileset palette data
    LDY #$0000		-- init read offset to 0. using Y because of long addressing. setting here because previous call clobbers it

  --No change here
  loc_028608:
    LDA #$07			-- init sample counter
    STA LOOPNUM

    LDA (SPTR)		-- read lookup sample and increment pointer
    STA LSAMPLE
    INC SPTR
    BNE loc_028616
    INC SPTR+1
    
  loc_028616:
    LDA [TPTR1], Y
    STA $00
    LDA [TPTR2], Y
    STA $04
    INY
    LDA [TPTR1], Y
    STA $02
    LDA [TPTR2], Y
    STA $06
    INY

    LDX #$0007		-- init rotate counter

  --No change
  loc_02862D:
    LDA #$00
    ROL $06
    ROL
    ROL $04
    ROL
    ROL $02
    ROL
    ROL $00
    ROL
    ORA LSAMPLE

    STA (DPTR)		-- store result and increment pointer
    INC DPTR
    BNE loc_028645
    INC DPTR+1

  loc_028645:
    DEX
    BPL loc_02862D	-- continue rotate (8 times)

    DEC LOOPNUM
    BPL loc_028616	-- continue sample (8 times)

    REP #$20			-- increment read counter by $10
    TYA
    CLC
    ADC #$0010
    TAY
    SEP #$20

    CPY #$2000
    BCC loc_028608	-- continue read ($2000 bytes)

    ;Not sure if this is necessary
    STZ $0671		-- clear 'last loaded' banks so next resource loads
    STZ $067D
    STZ $0680
    STZ $0683

    PLB 

    LDX #$0000
    STX $VMADDL
    LDA #$80
    STA $VMAIN
    LDA #$00
    STA $DMAP0
    LDA #$19
    STA $BBAD0
    LDX #$A000
    STX $A1T0L
    LDA #$7E
    STA $A1B0
    LDX #$4000
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLY 
    PLP 
    RTS 
}

--------------------------------------------------

func_028592 {
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    CMP #$0001
    BMI loc_0285B2
    LDX #$7000
    STX $7A
    JSL $@func_028270
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40
}
