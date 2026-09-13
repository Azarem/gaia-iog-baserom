; SPC700 audio processor data transfer system (168078–171490, Bank 02).
; 
; Implements the SNES-to-SPC700 data transfer protocol used to upload the game's sound engine and music data to the audio processor's 64KB RAM. The SPC700 has its own CPU and address space — all communication occurs through four shared I/O ports (APUIO0–APUIO3 at $2140–$2143).
; 
; === IPL TRANSFER PROTOCOL ===
; 
; The SPC700 boots from a 64-byte IPL ROM that implements a byte-streaming protocol:
; 1. IPL Ready: SPC writes $BBAA to APUIO0/1 when ready to receive data
; 2. Block Header: CPU writes destination address to APUIO2/3, signals via APUIO0/1
; 3. Byte Transfer: For each byte, CPU writes the data byte + incrementing counter to APUIO0/1 (16-bit write). CPU waits for SPC to echo the counter byte on APUIO0 before sending the next byte. This handshake ensures reliable transfer at the SPC's processing speed
; 4. Block End: After all bytes, CPU writes a non-zero counter offset (+3, skipping zero) to signal block completion
; 5. Multi-block: Overflow flag (V) indicates more blocks follow; clear V signals final block with execution start
; 
; === ROUTINES ===
; 
; SpcIplHandshake: Low-level single-block transfer. Reads block headers (byte count + destination) from the data stream at [$46],Y. Manages NMI state (EnableNmiOnly during transfer to prevent VBlank interruption, EnableNmiAndJoypad after if worldReadyFlag == $0F).
; 
; SpcBlockTransfer: Multi-block wrapper. Calls SpcIplHandshake for the initial block, then enters a loop processing additional blocks. Each block has a header byte — bit 7 set means finalize, bit 7 clear means more data. Uses indirect pointer $4A/$4C with bank-crossing support for large data streams.
; 
; SpcLoadBuiltinEngine: Entry point for boot-time sound engine upload. Sets [$46] to point to spc_sound_engine binary data and calls SpcIplHandshake.
; 
; === DATA FORMAT ===
; 
; The spc_sound_engine binary blob (168464–171490) contains the complete SPC700 sound engine — approximately 3KB of SPC700 machine code plus lookup tables (envelope curves, frequency tables, etc.). This is raw SPC700 binary, not 65C816 code.
; 
; SpcBlockTransfer data streams (passed via [$46]) use a structured format:
; - 2-byte destination address (SPC RAM target)
; - 1-byte block count
; - Per block: 1-byte sub-block count, then pairs of [2-byte size, data bytes]
; - Blocks reference addresses that may cross the $8000 bank boundary ($4A pointer wraps via AND #$7FFF + INC $4C)
---------------------------------------------

?BANK 02

?INCLUDE 'vblank_joypad'

!worldReadyFlag                 0654
!APUIO0                         2140
!APUIO1                         2141
!APUIO2                         2142

---------------------------------------------

; Boot-time entry point for uploading the built-in sound engine to the SPC700. Sets the data pointer [$46] to the spc_sound_engine binary blob address (both 16-bit offset and bank byte), then calls SpcIplHandshake to transfer the engine code to SPC700 RAM via the IPL protocol.

SpcLoadBuiltinEngine {
    LDX #$&spc_sound_engine ; Load spc_sound_engine address (16-bit offset within bank)
    STX $46
    LDA #$^spc_sound_engine ; Load bank byte of spc_sound_engine via ^prefix
    STA $48
    JSR $&SpcIplHandshake ; Transfer sound engine binary to SPC700 via IPL protocol
    RTL 
}

---------------------------------------------
; Multi-block SPC700 data transfer. Called by SpcMusicLoadCmd and other music loading code to upload structured music data to the SPC700. Calls SpcIplHandshake for the initial block header, then enters a multi-block processing loop.
; 
; The data stream at [$46],Y uses a structured format: first a 2-byte SPC destination address ($2E), then a block count byte ($28). Each block has a sub-block count byte — bit 7 clear means process more sub-blocks (reads 2-byte size headers from indirect pointer $4A/$4C, accumulates offsets), bit 7 set means finalize the current block. The indirect pointer $4A/$4C supports bank-crossing: when $4A exceeds $7FFF, it wraps via AND #$7FFF and increments $4C.
; 
; The actual byte transfer loop uses the SPC700 IPL handshake: writes data byte + incrementing counter to APUIO0 (16-bit write via REP #$20 STA), waits for the SPC to echo the counter byte. The XBA trick stores the counter in B accumulator, freeing A for data reads.
; 
; After each block completes: writes destination address to APUIO2, byte count indicator to APUIO1 (carry flag from CPX #$0001 → ROL gives 0 or 1), sends the continuation signal via APUIO0. NMI is set to EnableNmiOnly during transfer, then EnableNmiAndJoypad if worldReadyFlag == $0F.

SpcBlockTransfer {
    PHP                   ; Save processor state — multi-block transfer modifies all registers
    PHY 
    JSR $&SpcIplHandshake ; Transfer initial block header via IPL handshake
    DEY                   ; Back up Y past the header bytes consumed by SpcIplHandshake
    DEY 
    SEP #$20
    LDA #$FF              ; $FF → APUIO0: signal SPC that block data transfer follows
    STA $APUIO0
    LDA #$CC              ; $CC: initial counter value for the byte transfer handshake
    STA $30
    REP #$20
    LDA #$BBAA            ; $BBAA: IPL ready signal — wait for SPC to echo after initial block

  loc_0290B2:
    CMP $APUIO0           ; Poll APUIO0 until SPC echoes $BBAA (IPL ready for next phase)
    BNE loc_0290B2
    LDA [$46], Y          ; Read 2-byte SPC RAM destination address from data stream
    INY 
    INY 
    STA $2E
    LDA [$46], Y          ; Read block descriptor: low byte = sub-block count, high bits = flags
    INY 
    STY $32
    AND #$00FF            ; Mask to 8-bit block count ($28)
    STA $28
    STZ $2C

  code_0290C9:
    REP #$20              ; Begin sub-block processing loop
    LDX #$0000            ; Initialize indirect data pointer $4A to zero (start of bank $C5)
    STX $4A
    SEP #$20
    LDA #$C5              ; $C5: initial bank byte for SPC data source pointer
    STA $4C
    LDY $32
    LDA [$46], Y          ; Read sub-block header byte — bit 7 = finalize flag
    INY 
    STY $32
    STA $2A
    STZ $2B
    BIT #$80              ; Bit 7 set: this sub-block is the finalizer (jump to block end)
    BEQ loc_0290E8        ; Bit 7 clear: more sub-blocks to process
    JMP $&code_029153

  loc_0290E8:
    REP #$20
    LDA $2E               ; Accumulate destination offset: previous dest + accumulated size
    CLC 
    ADC $2C
    STA $2E

  loc_0290F1:
    LDA [$4A]             ; Read 2-byte sub-block size from indirect pointer [$4A]
    STA $2C
    STA $34
    INC $4A
    INC $4A
    LDA $2A               ; Check remaining sub-block count
    BEQ loc_029113        ; All sub-blocks consumed: begin byte transfer at current pointer
    DEC $2A
    LDA $4A               ; Advance data pointer past the 2-byte size word
    CLC 
    ADC $2C
    STA $4A
    BPL loc_0290F1        ; Check for bank boundary crossing ($4A >= $8000)
    AND #$7FFF            ; Wrap address within bank: AND #$7FFF, increment bank byte
    STA $4A
    INC $4C
    BRA loc_0290F1

  loc_029113:
    LDY $4A               ; Transfer start: Y = data pointer offset, switch to 8-bit for byte loop
    STZ $4A
    SEP #$20
    LDA $30               ; Load continuation counter from $30 (preserved across blocks)
    BRA loc_029160

  loc_02911D:
    LDA [$4A], Y          ; Read source byte from data stream at [$4A]+Y
    INY 
    BPL loc_029127        ; Check for Y overflow past $7FFF (bank boundary)
    LDY #$0000            ; Y overflowed: wrap to $0000, advance bank byte $4C
    INC $4C

  loc_029127:
    XBA                   ; XBA: stash data byte in B, load counter into A for handshake
    LDA #$00              ; #$00: first byte of block uses zero counter (initial handshake)
    BRA loc_02913E

  loc_02912C:
    XBA                   ; Swap counter back to A low byte for APUIO0 write
    LDA [$4A], Y          ; Read next source byte from data stream
    INY 
    BPL loc_029137
    LDY #$0000
    INC $4C

  loc_029137:
    XBA                   ; XBA: data in high byte, counter in low — ready for 16-bit write

  loc_029138:
    CMP $APUIO0           ; Wait for SPC to echo counter byte — handshake synchronization
    BNE loc_029138
    INC                   ; Increment counter for next byte (SPC expects monotonic counter)

  loc_02913E:
    REP #$20              ; 16-bit write: data byte (high) + counter (low) → APUIO0/1
    STA $APUIO0
    SEP #$20
    DEX                   ; Decrement remaining byte count (X)
    BNE loc_02912C

  loc_029148:
    CMP $APUIO0           ; Wait for SPC to echo final counter byte
    BNE loc_029148

  loc_02914D:
    ADC #$03              ; ADC #$03: advance counter past zero (zero = block-end signal)
    BEQ loc_02914D        ; Retry if counter accidentally landed on zero
    STA $30               ; Store updated counter for next block's continuation
}

---------------------------------------------
; Block finalization within SpcBlockTransfer. Decrements the remaining block count ($28). If blocks remain, jumps back to code_0290C9 for the next block. When all blocks are processed, clears the accumulated offset ($2C/$2D) and falls through to loc_029160 for the final transfer handshake.

code_029153 {
    DEC $28               ; Decrement remaining block count ($28)
    BEQ loc_02915A        ; All blocks done: fall through to finalization
    JMP $&code_0290C9     ; More blocks: loop back to sub-block processing

  loc_02915A:
    STZ $2C               ; Clear accumulated offset for finalization
    STZ $2D
    LDA $30

  loc_029160:
    PHA                   ; Push continuation counter — will be sent as APUIO0 start signal
    REP #$20
    LDA $2C               ; Transfer size → X for APUIO1 byte count indicator
    TAX 
    LDA $2E               ; SPC RAM destination address → APUIO2/3
    STA $APUIO2
    SEP #$20
    CPX #$0001            ; CPX #$0001: carry set if byte count > 0 (more data flag)
    LDA #$00
    ROL                   ; ROL carry into A: 0 = execute after transfer, 1 = more data follows
    STA $APUIO1           ; Write more-data flag to APUIO1
    ADC #$7F              ; ADC #$7F: sets overflow flag (V) if APUIO1 was 1 (more blocks)
    JSL $@vblank_joypad.EnableNmiOnly ; Enable NMI only (no joypad auto-read) during transfer
    PLA 
    STA $APUIO0           ; Send start/continuation signal to SPC via APUIO0

  loc_029180:
    CMP $APUIO0           ; Wait for SPC to echo APUIO0 (block transfer acknowledged)
    BNE loc_029180
    LDA $worldReadyFlag   ; Check if game is fully initialized (worldReadyFlag == $0F)
    CMP #$0F
    BNE loc_029190
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Re-enable NMI + joypad auto-read after transfer completion

  loc_029190:
    BVS loc_02911D        ; BVS: overflow set = more blocks remain (branch to byte transfer loop)
    STZ $APUIO1           ; All blocks done: clear APUIO1/2 (signal transfer complete to SPC)
    STZ $APUIO2
    PLY 
    PLP 
    RTL 
}

---------------------------------------------
; Low-level SPC700 IPL ROM transfer protocol implementation. Waits for $BBAA ready signal on APUIO0 (IPL boot complete), then enters the block transfer loop.
; 
; For each data block: reads 2-byte byte count and 2-byte destination address from [$46],Y. Writes destination to APUIO2, signals via APUIO1 (0 = more data, 1 = execute after transfer), sends start command via APUIO0, waits for echo.
; 
; Byte transfer inner loop: reads source byte from [$46],Y, writes to APUIO0 with incrementing counter via 16-bit STA. Waits for SPC to echo counter. After all bytes, advances counter by +3 (ADC #$03, skipping zero to avoid false block-end signal).
; 
; Manages NMI state: calls EnableNmiOnly before the transfer start signal (prevents VBlank from disrupting the timing-sensitive handshake), then EnableNmiAndJoypad after acknowledgment if worldReadyFlag == $0F (game is fully initialized). Uses overflow flag (BVS) to detect multi-block continuation.

SpcIplHandshake {
    PHP                   ; Save processor state — handshake modifies flags and registers
    REP #$20
    LDY #$0000            ; Y=0: start reading data from beginning of stream
    LDA #$BBAA            ; $BBAA: IPL ready signature — SPC writes this when ready to receive

  loc_0291A4:
    CMP $APUIO0           ; Poll APUIO0 until SPC700 IPL ROM signals ready ($BBAA)
    BNE loc_0291A4
    SEP #$20
    LDA #$CC              ; $CC: initial handshake counter (non-zero, non-$AA/BB to avoid confusion)
    BRA loc_0291D5

  loc_0291AF:
    LDA [$46], Y          ; Multi-block entry: read next data byte from stream
    INY 
    XBA                   ; XBA: stash data byte in B for 16-bit handshake write
    LDA #$00
    BRA loc_0291C2

  loc_0291B7:
    XBA                   ; Swap counter to low, read next data byte to high
    LDA [$46], Y
    INY 
    XBA 

  loc_0291BC:
    CMP $APUIO0           ; Wait for SPC to echo counter — byte transfer handshake
    BNE loc_0291BC
    INC                   ; Increment counter for next byte

  loc_0291C2:
    REP #$20              ; 16-bit write: data (high) + counter (low) → APUIO0/1
    STA $APUIO0
    SEP #$20
    DEX                   ; Decrement remaining byte count (X)
    BNE loc_0291B7

  loc_0291CC:
    CMP $APUIO0           ; Wait for final counter echo after block complete
    BNE loc_0291CC

  loc_0291D1:
    ADC #$03              ; ADC #$03: advance counter past zero (avoids false block-end)
    BEQ loc_0291D1

  loc_0291D5:
    PHA                   ; Push current counter — will become APUIO0 start signal
    REP #$20
    LDA [$46], Y          ; Read 2-byte transfer size (byte count for this block)
    INY 
    INY 
    TAX 
    LDA [$46], Y          ; Read 2-byte SPC RAM destination address
    INY 
    INY 
    STA $APUIO2           ; Write destination address to APUIO2/3
    SEP #$20
    JSL $@vblank_joypad.EnableNmiOnly ; Enable NMI only during timing-sensitive transfer
    CPX #$0001            ; CPX #$0001: carry = (size > 0), determines more-data flag
    LDA #$00
    ROL 
    STA $APUIO1           ; Write more-data indicator to APUIO1
    ADC #$7F              ; ADC #$7F: set V flag if APUIO1 was 1 (more blocks follow)
    PLA 
    STA $APUIO0           ; Send start command to SPC via APUIO0

  loc_0291F9:
    CMP $APUIO0           ; Wait for SPC to acknowledge start command (echo APUIO0)
    BNE loc_0291F9
    LDA $worldReadyFlag   ; Check game initialization state for NMI restore
    CMP #$0F
    BNE loc_029209
    JSL $@vblank_joypad.EnableNmiAndJoypad ; Fully initialized: re-enable NMI + joypad auto-read

  loc_029209:
    BVS loc_0291AF        ; BVS: overflow = more blocks to transfer (loop to byte send)
    STZ $APUIO2           ; Transfer complete: clear APUIO2 to signal done to SPC
    PLP 
    RTS 
}

---------------------------------------------
; Raw SPC700 machine code binary — the complete Quintet sound engine uploaded to the SPC700's 64KB RAM at boot time. Contains the audio driver, DSP register management, envelope tables, frequency lookup tables, and the music/SFX playback interpreter. This is not 65C816 code — it is SPC700 (Sony SPC-700) bytecode executed on the SNES audio coprocessor.

spc_sound_engine #CA0B000420CDCFBDE8005DAFC8F0D0FBC248BC3F760AA248E8008D0C3F06068D1C3F06068D2C3F06068D3C3F0606E8108D5D3F0606E830C4F1E810C4FAE810C4FBC453E803C4F1E43648FF244AC4388D0AAD05F007B008694D4CD00FE34C0CF6440EC4F2F64E0E5DE6C4F3FEE4CB45CB46EBFDF0FCE840CF608443C4439015E5FD0F6814F007E431F0033F870E694D4CF002AB4CE4536084F5EBFEF0FCCF608451C451B004AD00F0463F3807E431F037EB61E431CFE43ECFCB6BEB63E431CFE43ECFCB6C8D60E431CFE43ECFDDC4F78D0C3F06068D1C3F0606E430F00A8B31D0068F00043F3606CD003F04055F4304E404F012CD008F0147F4D5F0033F630D3D3D0B47D0F35F4304F404D4F4F4F474F4D0FAD4006FADCA90053F9D088DA4ADC8B0F2E41A2447D0ECDD287F6084506095F002D57D03F5A503D57C03F5A1025CE8007CD58C02E800D4ACD50001D5C802D4C009475E094745F56402D498F01EF56502D499F57802D00AF57D0380B57902D57D03F5790260957D033F0A0B3F220B8D00E41180A834B009E41180A813B006DC1C7A10DA104DE4111C8D00CD189E5DF65A0EC415F6590EC414F65C0E2DF65B0EEE9A14EB10CFDD8D007A14CB151C2B15C4142F044B157C3DC806D0F8C414CEF52802EB15CFDA16F52802EB14CF6DF52902EB14CF7A16DA16F52902EB15CFFDAE7A16DA16F5730E0802FDE4163FFE05FCE4172DE447241AAED004CBF2C4F36F8D00F7403A402DF7403A40FDAE6F8FFF308FFF31C4046F2DE5FE0FECFF0FDA3BE8005DC73B3A3BD0FAAE6FE4D5F044E800C46BC46C8FFF5C8FFF0E8F0004E8008D0C3F06068D1C3F06068D2C3F06068D3C3F0606A248E800C4D5C4D7C4D9C4DBC4DDC4DFC4E1C4E3C4E5C4E7C431E8013F760A6F8FFF0E6F3F890FC408C4046F68F0F0A768F1F08668F2F0E868FFF0E86FE4046890F0186891F018E404300F80A840900A1C1C48FFFDE8E0CFCB3E6F8F01326F8F00326FC4041CF0336802D0D13F2206E5FC0FECFD0FDA403A403A408F020CE800C4308F0031C45FC439C436C4E5C4E7C43DC4F58FE03E8F000ED248E41A48FF0E46006FCD0E8F8047E800D50503E80A3F0909D51502D5A503D5F002D56402D4ADD4C11D1D4B47D0E0C45AC468C454C450C4428F00598F20536FEB08E40068F090035F8B06C4087E00F0035FC206E404F0E78F000EE40CF05E6E0CA8FA3DF53F0B06D020FDD0098FFF3D8FFFF55FC2068B421005C4428F003D3F0B06F842F0DCDA402FD8AB3DDA168D0FF716D6D400DC10F8CD008F0147F4D5F00AF51502D005E8003F9D08E800D5B803D484D485BCD4703D3D0B47D0E0CD00D85E8F0147D844F4D5F06C9B70D0623F9308D01DF5B803F08A3F0E0AF5B8039CD5B803D0EAF53C02D4D4F53D02D4D52FDE3020D500023F930830182D9F2807FDF60013D50102AE280FFDF60813D514023F930868E090053F81082FB33F1105F50002D470FDF50102CFDDD001BCD4712F033F720C3FEA0A3D3D0B47D088E454F00BBA567A526E5402BA54DA52E468F015BA647A60DA60BA667A626E6806BA68DA60EB6ADA62E45AF00EBA5C7A586E5A02BA5ADA588FFF5ECD008F0147F4D5F0033FA90B3D3D0B47D0F36F1CFDF68A0A2DF6890A2DDD5CFDF6290BF008E7D4BBD4D002BBD5FD6FD51502EB34D011FD100680A8CA60845F4D5DF5E00FCE2F09FD100680A8CA6084398D06CFDA1460980014981215E41A2447D0384DF5730E08045D8D00F714100E281F3820480E4800094749DD2F07E4474E4900F714D8F2C4F33DFCAD04D0F4CEF714D52902FCF714D528026FD56903281FD54103E800D540036FD4852D3F9308D5680380B54103CE3F2D0BD55403DDD555036FD5A0023F9308D58D023F9308D4ADD5B502E800D5A1026FD5A1022D8D00F4ADCE9EF844D5B4026FDD80A81EFDE800DA58E431D0038FFF316FC45A3F9308C45B80A459F85A3F2D0BDA5C6FE434D004E800DA526FC4543F9308C45580A453F8543F2D0BDA566FC4506FD5F0026FD5DC023F9308D5C9023F9308D4C16FE8012F02E800D57802DDD565023F9308D564023F9308D579026FD564026FEB34F002E8B4D50503E800D504036FD4842D3F9308D52C0380B50503CE3F2D0BD51803DDD519036FD5A5036FD550023F9308D551023F9308D5B803F4D4D53C02F4D5D53D02F55002D4D4F55102D4D56FC44A3F9308E800DA603F9308E800DA62B2486FC4683F9308C46980A461F8683F2D0BDA643F9308C46A80A463F8683F2D0BDA666FDA60DA62A2486F3F760A3F9308C44E3F93088D08CF5D8D0FF5250E3F06063DDD608810FD10F2F8446FC44D8D7DCBF2E4F3644DF029280F48FFF34C0360844CC44C8D04F6440EC4F2E800C4F3FEF5E44808208D6C3F0606E44D8D7D3F06061C1C1C48FF8088FF8D6D5F06062D7D6810900380A8049F5C608805FDAE08803FFE05FC6D3F9308C43F3F93089F1C043FEE3FFE056FEB34D003C45F6FC4396FF498D033E7D468F9D02D3F95083F9308D4993F9308D4983F930860845095F002287FD5A40380B57D03FB986DCE3F2D0BD59003DDD591036FF57D03C411F57C03C4106FED6B12100348FFBC8D009E2DE8009EEEF844F31206DA14BA1C9A146F9D080909170930093C09570968097A098309950998099C09A809C909D809F5094709AB09AF09C509F109190A4D0A540A2C0AFA0AE00A0000000000000000B80A0101020300010201020101030001020301030300010300030303010000000001F484F009E8048D039B843F490CFBC1F023F5DC02DEC01B09475EF5C8021007FCD004E8802F046095C902D5C8023FEF0D2F07BBC0E8FF3FFA0DF485F009E8408D039B853F490CE447245EF053F54103FDF54003DA10F5730EC412E432F0098F0A118F00108F0A11EB11F6110E80B6100EEB10CFDDEB116096100EFDF52D03CFF569031C1312011CDD900348FFBCEB123FFE058D14E8009A10DA10AB123312C86F09475EDA14DA164DEE60D00F982716687CF01560E800D714FC2F099814163F6B0CFCF7149716D7146FF471F0649B71F005E802DE705BF5B803C417F4D4FBD5DA148D00F714F01C3005FCF71410FB68C8F03F68EFF02968E090306DFDAE96A90AFD2FE0E417F0238B17D00AF53D022DF53C02EE2FCAF551022DF55002EE2FC0FCF7142DFCF714FDAE2FB5E4478D5C3FFE05F213F498F02CF499F0049B992F24E2139B98D00BF5A503D57C03F5A4032F1060F57C03959003D57C03F57D03959103D57D033F220BF4ADF04CF5A002DEAC44F5000175A102D005F5B5022F0D40BB0020FDF002F4AD6095B402D4ADF58C0260958D02D58C02C4121C1C900248FFFDF4AD68F19005280FCF2F04CFDD8D003FDA0D5F7B05BBACE313F86FF213F4C1F009F5DC02DEC0033FE20DF54103FDF54003DA10F485F00AF55503FDF554033FC40DF313033FFE0BF213F57D03FDF57C03DA10F498F00EF499D00AF59103FDF590033FC40DF4ADF0AFF5A002DEACA9EB51F58D02CFDD60958C025F3F0DE213CB123F3F0B6DEB51CFCB148F0015EB51AECF7A143F3F0B7A10DA106FE213EB51F5C902CFDD6095C8021C900248FFFBC1CFDD48FFEB34D003EB59CFF51402CFF50503CFDDCFDDD52D036F000103070D151E293442515E676E73777A7C7D7E7F7F0000000000000058BFDBF0FE070C0C0C212B2B13FEF3F9343300D9E501FCEB2C3C0D4D6C4C5C3D2D5C6B6C4E3848450E494B465F08DE086509F4098C0A2C0BD60B8B0C4A0D140EEA0ECD0FBE100000100020003000400050006000700060007000FA1A37383F1A8FFF348F005E8F4047CD10E4F6F00C0947460947370947363FCA0E3F300F8F8047CD12E4F7F00C0947460947370947363FCA0E3F300F8F0034FA371A6F1C4D5DF50114FDF50014CED4D4DBD5E896D50503E80A3F0909E800D51502D5A503D5F002D56402D4ADD4C1D5B803D484D485E802D4706FE44748FFFD2437C437DD2436C43609475EFA475C0947468F00344D7D80A8045DF515023F9D08CE8FFF34E800D4D56FF4D5F054D8449B70D0453F9308F0C23020D500023F930830182D9F2807FDF60013D50102AE280FFDF60813D514023F930868E090053F81082FD03F1105F50002D470FDF50102CFDDD001BCD4712F033F720C3FEA0A3FA90B6F8DBBE8AADAF4E4F468CCD0FA2F1EEBF4D0FC7EF4D010CBF4E4F5D60000FCD0F2ACA50F5F9B0F10EA7EF410E6BAF6C5A40FCCA50FEBF4E4F5CBF4D0D2CD33D8F16F00000004