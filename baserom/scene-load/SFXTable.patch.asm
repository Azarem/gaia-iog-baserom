; ==============================================================================
; SPC sample chunk lookup - relocated SFX pointer table (bank $02)
; ==============================================================================
; What it does: Replaces the vanilla C5:0000 sample library walk with a direct
;   index into sfx_table (60 entries, 3 bytes each: size + bank) in this bank;
;   chunk payload reads use SAMPLE_PTR instead of the library base $4A/$4C.
; Vanilla behavior: SpcNextChunkIndex reset $4A to $C5:0000 and SpcFindChunk
;   skipped variable-size chunks in ROM until the stream index matched; data
;   loop used [$4A],Y with bank byte $4C.
; Hooks (overrides): spc_transfer.SpcNextChunkIndex, SpcFindChunk,
;   SpcSendChunkData, loc_02912C (byte loop read path).
; Adds: sfx_table and sfx00-sfx3B labels (long pointers to sample blobs).
; Depends on: ?INCLUDE chunk_028000 (SPC transfer engine in bank $02);
;   SpcSendHeader, SpcChunkDone (unchanged).
; State: Stream index Y in $32; chunk index $2A; dest accumulator $2E/$2C;
;   handshake counter $30; sample pointer $4A (repurposed).
; Hazards/notes: Bank $02 table must stay LoROM-mapped; chunk index byte bit $80
;   still marks empty slots (same as vanilla).
; ==============================================================================
?BANK 02

?INCLUDE 'chunk_028000'

!SAMPLE_NUM		$2A
!SAMPLE_SIZE	$2C
!SPC_CMD		$30
!SAMPLE_PTR		$4A

--------------------------------------

sfx_table:
	#@sfx00  #@sfx01  #@sfx02  #@sfx03  #@sfx04  #@sfx05  #@sfx06  #@sfx07  
	#@sfx08  #@sfx09  #@sfx0A  #@sfx0B  #@sfx0C  #@sfx0D  #@sfx0E  #@sfx0F
	#@sfx10  #@sfx11  #@sfx12  #@sfx13  #@sfx14  #@sfx15  #@sfx16  #@sfx17
	#@sfx18  #@sfx19  #@sfx1A  #@sfx1B  #@sfx1C  #@sfx1D  #@sfx1E  #@sfx1F
	#@sfx20  #@sfx21  #@sfx22  #@sfx23  #@sfx24  #@sfx25  #@sfx26  #@sfx27
	#@sfx28  #@sfx29  #@sfx2A  #@sfx2B  #@sfx2C  #@sfx2D  #@sfx2E  #@sfx2F
	#@sfx30  #@sfx31  #@sfx32  #@sfx33  #@sfx34  #@sfx35  #@sfx36  #@sfx37
	#@sfx38  #@sfx39  #@sfx3A  #@sfx3B

	
  spc_transfer.SpcNextChunkIndex!:
    ;REP #$20
    LDX #&sfx_table
    STX SAMPLE_PTR
    SEP #$20
    LDA #^sfx_table
    STA SAMPLE_PTR+2
    LDY $32
    LDA [$46], Y
    INY 
    STY $32
    STA SAMPLE_NUM
    STZ SAMPLE_NUM+1
    BIT #$80
    BEQ loc_0290E8
    JMP $&SpcChunkDone
	
  spc_transfer.SpcFindChunk!:
	LDA  SAMPLE_NUM
	ASL
	CLC
	ADC  SAMPLE_NUM
	TAY
	LDA  [SAMPLE_PTR], Y
	TAX
	INY
	INY
	SEP  #$20
	LDA  [SAMPLE_PTR], Y
	STA  SAMPLE_PTR+2
	REP  #$20
	STZ  SAMPLE_PTR
	TXY
	LDA  [SAMPLE_PTR], Y
	STA  SAMPLE_SIZE
	STA  $34				-- ??
	INY
	INY
	SEP  #$20
	LDA  SPC_CMD
	BRA  SpcSendHeader

spc_transfer.SpcSendChunkData!:
	LDA  [SAMPLE_PTR], Y
	INY

spc_transfer.loc_02912C!:
	XBA
	LDA  [SAMPLE_PTR], Y
	INY

