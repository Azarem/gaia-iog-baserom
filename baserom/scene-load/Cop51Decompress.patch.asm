; ==============================================================================
; COP #51 Decompress - raw copy and negative-size MVN paths
; ==============================================================================
; What it does: After reading source/dest operands, interprets the 2-byte size
;   header: zero triggers a $2000-byte MVN from ROM to WRAM; negative size uses
;   SEC SBC on the header then MVN (uncompressed byte count); positive still
;   runs QuintetLzDecompress then ClearActorRenderList.
; Vanilla behavior: Always treated the header as LZ decompressed byte count,
;   skipped 2 bytes, and called QuintetLzDecompress only (no MVN fast path).
; Hooks (overrides): cop_handlers_vram.Decompress (COP 51 handler; include name
;   cop_handlers_map is a legacy block key).
; Depends on: ?INCLUDE cop_handlers_map; MVN stub at $0402; QuintetLzDecompress;
;   ClearActorRenderList.
; State: COP operand pointer at stack $0A; SPTR $3E/$40, DCMP_SIZE $78, dest $7A.
; Hazards/notes: Bank $00; PHD/PLD around handler; TCD zeros DP before work;
;   RTI restores X from Y (vanilla pattern).
; ==============================================================================
?BANK 00

?INCLUDE 'cop_handlers_map'

!SPTR		$3E
!DCMP_SIZE	$78

--------------------------------------------

cop_handlers_vram.Decompress!:
  PHY 
  PHD 
  LDA [$0A]
  INC $0A
  INC $0A
  STA $003E
  LDA [$0A]
  INC $0A
  AND #$00FF
  SEP #$20
  STA $0040
  REP #$20
  LDA [$0A]
  INC $0A
  INC $0A
  STA $007A
  LDA [$0A]
  INC $0A
  AND #$00FF
  LDA #$0000
  TCD

cop51_main:
  LDA [SPTR]
  BMI cop51_minus
  BEQ cop51_zero
  STA DCMP_SIZE
  INC SPTR
  INC SPTR
  JSL $@QuintetLzDecompress
  JSL $@ClearActorRenderList
  BRA cop51_end

cop51_zero:
  LDA #$2000
  BRA cop51_domvn

cop51_minus:
  LDA #$0000
  SEC
  SBC [SPTR]

cop51_domvn:
  INC SPTR
  INC SPTR

  SEC
  SBC #$0001
  PHA

  SEP #$20
  LDA #$7E
  STA $0404
  LDA SPTR+2
  STA $0405
  REP #$20

  LDX SPTR
  LDY $7A

  PLA
  JSR $0402

cop51_end:
  PLD 
  PLY 
  TYX
  LDA $0A
  STA $02, S
  RTI 

