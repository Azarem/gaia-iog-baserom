; SPC700 audio processor data transfer system (168078–171490, Bank 02).
; 
; Implements the SNES-to-SPC700 upload protocol used to load the game's sound engine at boot and every music track afterwards into the SPC700's 64 KB RAM (ARAM). All communication goes through the four I/O ports APUIO0–APUIO3 ($2140–$2143): a CPU read returns what the SPC wrote to its port, a CPU write goes to the SPC's input port.
; 
; === IPL PROTOCOL (SpcIplHandshake) ===
; The SPC700 boot ROM (IPL) and the sound engine's resident clone of it (sub_0f89, entered by port command $FF; docs/audio/spc-disassembly.md) speak the same byte-stream protocol, so one 65816 routine serves both:
; 1. The SPC posts $BBAA on ports 0/1 when it is ready.
; 2. A record is size (word), ARAM destination (word) and size data bytes. The CPU writes the destination to ports 2/3, port 1 = 1 (data follows) or 0 (size 0: end of session), then a kick value on port 0 ($CC for the first record) and waits for the SPC to echo it.
; 3. Each data byte is one 16-bit write to ports 0/1 (counter in the low byte, data in the high byte; the counter starts at 0 and increments per byte). The CPU waits for the SPC to echo the counter before sending the next byte.
; 4. After the last byte the code waits for the final echo; the carry from that equal compare makes ADC #$03 add 4, and a result of 0 is stepped over, so the next record's kick is non-zero and differs from the last counter.
; 5. A record of size 0 ends the session. For the boot ROM its destination word is the entry address the SPC jumps to; the resident loader just returns to the engine.
; The V flag carries 'more records follow': ROL puts the size-nonzero carry into port 1 (0 or 1) and ADC #$7F overflows only when it was 1.
; 
; === NMI STATE ===
; Both transfer routines call DisableNmiKeepJoypad (NMITIMEN = $01: NMI OFF, joypad auto-read on) just before each header and kick, so the NMI cannot interleave with the port writes. After the SPC echoes the kick they call EnableNmiAndJoypad only if worldReadyFlag = $0F, so once the game is running the data bytes are sent with NMI enabled (the NMI then runs UpdateFrameFull; the music change in the main loop relies on it); at boot the NMI stays off.
; 
; === ROUTINES ===
; SpcLoadBuiltinEngine (boot, from SystemInit): [$46] = spc_sound_engine, then SpcIplHandshake. The blob is one record (size $0BCA = 3,018 bytes of SPC700 code and tables to ARAM $0400) followed by the terminator record (size 0, entry $0400): 168464–171490.
; SpcIplHandshake: sends the records at [$46] from Y = 0 until the size-0 record, leaving Y just past it.
; SpcBlockTransfer (music; callers: LoadMusicFromTransitionState and scene_script's music load): two sessions on one stream. Session 1 = SpcIplHandshake over the stream's leading records (the song data and tables, e.g. ARAM $1254, $1300, $5532, $1038, $0FFC, $0FFE, $0FE0; the words at ARAM $0FFC/$0FFE are the engine's stream and tail pointers). The stream continues after the terminator: its destination word is reused as the ARAM address of the first sample chunk, then one count byte and that many chunk-index bytes. Port command $FF re-enters the engine's loader (a fresh $BBAA, awaited at 168114) and session 2 sends the chunks from the sample library at $C5:0000: chunk = [size word][data], stored back to back (61 chunks, indices 0-60), in 32 KB pages (the pointer $4A wraps at $8000 into the next bank, even inside a chunk). For each index byte the code walks the library from the start to that chunk (skipping chunks by their size words), sends it to the running ARAM address (previous chunk's destination + size) and moves on; an index with bit 7 set is an empty slot and is skipped. A final size-0 record ends session 2.
; 
; The library, the index lists and the records are data; the SPC engine's own behavior is documented in docs/audio/.
---------------------------------------------

?BANK 02

?INCLUDE 'vblank_joypad'

!worldReadyFlag                 0654
!APUIO0                         2140
!APUIO1                         2141
!APUIO2                         2142

---------------------------------------------

; Boot-time entry point for uploading the built-in sound engine to the SPC700 (called by SystemInit). Sets the data pointer [$46] to the spc_sound_engine blob (16-bit offset and bank byte), then calls SpcIplHandshake, which sends the blob's single record (3,018 bytes to ARAM $0400) and the terminator whose entry address $0400 makes the IPL start the engine.

SpcLoadBuiltinEngine {
    LDX #$&spc_sound_engine ; Load spc_sound_engine address (16-bit offset within bank)
    STX $46
    LDA #$^spc_sound_engine ; Load bank byte of spc_sound_engine via ^prefix
    STA $48
    JSR $&SpcIplHandshake ; Transfer sound engine binary to SPC700 via IPL protocol
    RTL 
}

---------------------------------------------
; Upload one music track's data to the SPC700: two sessions over the stream at [$46] (callers: LoadMusicFromTransitionState and scene_script's music load).
; 
; Session 1: SpcIplHandshake sends the stream's leading records (the song's data and tables, ARAM $1254 ...) up to the size-0 terminator and returns with Y past it. Y is backed up by 2 to the terminator's destination word, which becomes $2E: the ARAM address of the first sample chunk. Port command $FF is written to APUIO0 (the engine re-enters its resident loader), $30 is set to $CC (first kick) and the routine waits for the fresh $BBAA.
; 
; Session 2: the next stream byte is the chunk count ($28), followed by that many chunk-index bytes (Y of the first one is kept in $32). Per index byte: bit 7 set = empty slot (skip via SpcChunkDone); otherwise $4A/$4C is reset to the library start $C5:0000, $2E += the previous chunk's size ($2C), and the loop at SpcFindChunk reads each chunk's size word and skips chunks (adding their sizes, wrapping at $8000 into the next bank) until the index reaches 0. The chosen chunk's size goes to X and $2C, the data pointer to Y; the header (destination to ports 2/3, flag in port 1, kick on port 0) is sent by SpcSendHeader and the data loop at SpcSendChunkData sends the bytes with the same counter handshake as SpcIplHandshake. The counter ($30) persists across chunks.
; 
; After the last chunk SpcChunkDone clears $2C and sends a size-0 record (port 1 = 0, V clear), ends the session, clears APUIO1/APUIO2 and returns. NMI is switched off around each header/kick (DisableNmiKeepJoypad) and back on after the kick echo when worldReadyFlag = $0F.

SpcBlockTransfer {
    PHP                   ; Save processor state — multi-block transfer modifies all registers
    PHY 
    JSR $&SpcIplHandshake ; Session 1: the song's data records (ARAM $1254, $1300, ...) up to the size-0 terminator
    DEY                   ; Y is past the terminator record: back up 2 to its destination word
    DEY 
    SEP #$20
    LDA #$FF              ; Port command $FF: the engine re-enters its resident loader, which posts a fresh $BBAA
    STA $APUIO0
    LDA #$CC              ; $CC: initial counter value for the byte transfer handshake
    STA $30               ; $30 = $CC: first kick value for session 2
    REP #$20
    LDA #$BBAA            ; $BBAA: IPL ready signal — wait for SPC to echo after initial block

  loc_0290B2:
    CMP $APUIO0           ; Poll APUIO0 until SPC echoes $BBAA (IPL ready for next phase)
    BNE loc_0290B2
    LDA [$46], Y          ; Read 2-byte SPC RAM destination address from data stream
    INY 
    INY 
    STA $2E               ; The terminator's destination word is reused as the ARAM address of the first sample chunk
    LDA [$46], Y          ; Chunk count byte; the chunk-index bytes follow (Y after the count is saved in $32)
    INY 
    STY $32
    AND #$00FF            ; Mask to 8-bit block count ($28)
    STA $28
    STZ $2C

; Start of the per-chunk loop inside SpcBlockTransfer: resets the sample-library pointer to bank C5 page 0, reads the next chunk index byte from the stream at Y in $32, and skips to SpcChunkDone when bit 7 marks an empty slot; otherwise accumulates the running SPC destination offset and enters SpcFindChunk.

  SpcNextChunkIndex:
    REP #$20              ; Begin sub-block processing loop
    LDX #$0000            ; Initialize indirect data pointer $4A to zero (start of bank $C5)
    STX $4A
    SEP #$20
    LDA #$C5              ; $C5:0000 = start of the sample library (32 KB pages: $4A wraps at 32 KB into the next bank)
    STA $4C
    LDY $32
    LDA [$46], Y          ; Chunk index byte: bit 7 set = empty slot (skipped), else the chunk's position in the library
    INY 
    STY $32
    STA $2A
    STZ $2B
    BIT #$80              ; Bit 7 set: empty slot, nothing to send; jump to SpcChunkDone (next record or finish)
    BEQ loc_0290E8        ; Bit 7 clear: $2A = the wanted chunk index; walk the sample library below
    JMP $&SpcChunkDone

  loc_0290E8:
    REP #$20
    LDA $2E               ; Accumulate destination offset: previous dest + accumulated size
    CLC 
    ADC $2C
    STA $2E

; Walks the C5 sample library: for each header word at [$4A], subtracts one from the wanted index in $2A until zero, skipping payload bytes and wrapping $4A at 32K page boundaries; when the target chunk is found, sets Y to the data offset and branches into SpcSendHeader with the handshake counter from $30.

  SpcFindChunk:
    LDA [$4A]             ; Library chunk size word; reaching the wanted index means skipping the earlier chunks one by one
    STA $2C
    STA $34
    INC $4A
    INC $4A
    LDA $2A               ; $2A = chunks still to skip; zero means the wanted chunk starts at $4A / $4C
    BEQ loc_029113        ; Wanted chunk reached: start sending its bytes at loc_029113
    DEC $2A
    LDA $4A               ; Skip this chunk's payload: $4A += its size (the 2-byte size word was already passed)
    CLC 
    ADC $2C
    STA $4A
    BPL SpcFindChunk      ; Still inside this 32 KB page: next chunk header; otherwise wrap into the next bank below
    AND #$7FFF            ; Wrap address within bank: AND #$7FFF, increment bank byte
    STA $4A
    INC $4C
    BRA SpcFindChunk

  loc_029113:
    LDY $4A               ; Transfer start: Y = data pointer offset, switch to 8-bit for byte loop
    STZ $4A
    SEP #$20
    LDA $30               ; Load continuation counter from $30 (preserved across blocks)
    BRA SpcSendHeader

; Byte loop for one library chunk after SpcSendHeader: reads from [$4A],Y with bank byte $4C, waits for APUIO0 echo, writes data and an incrementing counter to APUIO0/1, wraps Y at $8000, and exits when X (byte count) reaches zero.

  SpcSendChunkData:
    LDA [$4A], Y          ; Next chunk byte from the sample library: [$4A],Y with $4A = 0, so Y is the offset inside the page at bank $4C
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
    LDA [$4A], Y          ; Next chunk byte from the sample library (same source as above)
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
    ADC #$03              ; Carry is set by the equal compare, so this adds 4; BEQ re-adds 3 if it wrapped to 0 (next kick must be non-zero)
    BEQ loc_02914D        ; Retry if counter accidentally landed on zero
    STA $30               ; Store updated counter for next block's continuation
}

---------------------------------------------
; Per-chunk bookkeeping and end of session inside SpcBlockTransfer (the data loop above falls into it; empty chunk slots jump here). Decrements the remaining chunk count ($28). While chunks remain it loops back to SpcNextChunkIndex for the next index byte. When the count is exhausted it clears the previous-size accumulator ($2C/$2D) and falls into SpcSendHeader with the running counter, which sends the final size-0 record (port 1 = 0, V clear) that ends the session.

SpcChunkDone {
    DEC $28               ; Decrement remaining block count ($28)
    BEQ loc_02915A        ; All blocks done: fall through to finalization
    JMP $&SpcNextChunkIndex ; More blocks: loop back to sub-block processing

  loc_02915A:
    STZ $2C               ; Clear accumulated offset for finalization
    STZ $2D
    LDA $30

; Shared block header inside SpcBlockTransfer (also reached from SpcChunkDone when all chunks are done): pushes the continuation counter, writes chunk size to the port handshake, SPC RAM dest to APUIO2/3, more-data flag to APUIO1, disables NMI around the kick, waits for APUIO0 echo, optionally re-enables NMI when worldReadyFlag is $0F, then branches to SpcSendChunkData if more bytes remain or clears ports and returns.

  SpcSendHeader:
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
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMITIMEN = $01: NMI OFF around the header and kick (joypad auto-read stays on)
    PLA 
    STA $APUIO0           ; Send start/continuation signal to SPC via APUIO0

  loc_029180:
    CMP $APUIO0           ; Wait for SPC to echo APUIO0 (block transfer acknowledged)
    BNE loc_029180
    LDA $worldReadyFlag   ; Check if game is fully initialized (worldReadyFlag == $0F)
    CMP #$0F
    BNE loc_029190
    JSL $@vblank_joypad.EnableNmiAndJoypad ; NMI back on after the kick echo (not after the whole transfer): the byte loop then runs with NMI enabled

  loc_029190:
    BVS SpcSendChunkData  ; BVS: overflow set = more blocks remain (branch to byte transfer loop)
    STZ $APUIO1           ; All blocks done: clear APUIO1/2 (signal transfer complete to SPC)
    STZ $APUIO2
    PLY 
    PLP 
    RTL 
}

---------------------------------------------
; Low-level SPC700 upload protocol (boot ROM IPL or the engine's resident clone of it). Waits for $BBAA on APUIO0/1, then sends the records at [$46] from Y = 0 until a size-0 record; returns with Y just past that record.
; 
; Per record (SpcSendRecord): size word → X, destination word → ports 2/3, DisableNmiKeepJoypad (NMI off), port 1 = 1 if the size is non-zero else 0 (ROL of the CPX #1 carry), ADC #$7F sets V when it was 1, then the kick (the counter pushed earlier; $CC for the first record) on port 0 and a wait for the echo; if worldReadyFlag = $0F the NMI is turned back on. BVS then sends the data bytes: the first byte with counter 0, each following byte as one 16-bit write (counter low, data high) after the SPC has echoed the previous counter. After the last byte the final echo is awaited and the counter advances by 4 (ADC #$03 with the carry set; a result of 0 is stepped over) to become the next kick.
; 
; The size-0 record ends the session (port 1 = 0, V clear); the routine then clears APUIO2 and returns with RTS. It is the shared low-level routine of SpcLoadBuiltinEngine and SpcBlockTransfer.

SpcIplHandshake {
    PHP                   ; Save processor state — handshake modifies flags and registers
    REP #$20
    LDY #$0000            ; Y=0: start reading data from beginning of stream
    LDA #$BBAA            ; $BBAA: IPL ready signature — SPC writes this when ready to receive

  loc_0291A4:
    CMP $APUIO0           ; Poll APUIO0 until SPC700 IPL ROM signals ready ($BBAA)
    BNE loc_0291A4
    SEP #$20
    LDA #$CC              ; First kick value: must be non-zero ($CC is the customary IPL value)
    BRA SpcSendRecord

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
    ADC #$03              ; Carry is set by the equal compare, so this adds 4; BEQ re-adds 3 if it wrapped to 0
    BEQ loc_0291D1

; IPL record sender inside SpcIplHandshake: pushes the kick counter, reads size and destination words from [$46],Y, disables NMI, writes port 1/2/3, kicks port 0 and waits for echo, restores NMI when worldReadyFlag is $0F, loops to the byte sender when overflow indicates data, else clears APUIO2 and returns with the saved P.

  SpcSendRecord:
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
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMITIMEN = $01: NMI OFF around the header and kick (joypad auto-read stays on)
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
    JSL $@vblank_joypad.EnableNmiAndJoypad ; NMI back on after the kick echo when the game is running; at boot it stays off

  loc_029209:
    BVS loc_0291AF        ; BVS: overflow = more blocks to transfer (loop to byte send)
    STZ $APUIO2           ; Transfer complete: clear APUIO2 to signal done to SPC
    PLP 
    RTS 
}

---------------------------------------------
; Raw SPC700 machine code binary — the complete Quintet sound engine uploaded to the SPC700's 64KB RAM at boot time. Contains the audio driver, DSP register management, envelope tables, frequency lookup tables, and the music/SFX playback interpreter. This is not 65C816 code — it is SPC700 (Sony SPC-700) bytecode executed on the SNES audio coprocessor.

spc_sound_engine #CA0B000420CDCFBDE8005DAFC8F0D0FBC248BC3F760AA248E8008D0C3F06068D1C3F06068D2C3F06068D3C3F0606E8108D5D3F0606E830C4F1E810C4FAE810C4FBC453E803C4F1E43648FF244AC4388D0AAD05F007B008694D4CD00FE34C0CF6440EC4F2F64E0E5DE6C4F3FEE4CB45CB46EBFDF0FCE840CF608443C4439015E5FD0F6814F007E431F0033F870E694D4CF002AB4CE4536084F5EBFEF0FCCF608451C451B004AD00F0463F3807E431F037EB61E431CFE43ECFCB6BEB63E431CFE43ECFCB6C8D60E431CFE43ECFDDC4F78D0C3F06068D1C3F0606E430F00A8B31D0068F00043F3606CD003F04055F4304E404F012CD008F0147F4D5F0033F630D3D3D0B47D0F35F4304F404D4F4F4F474F4D0FAD4006FADCA90053F9D088DA4ADC8B0F2E41A2447D0ECDD287F6084506095F002D57D03F5A503D57C03F5A1025CE8007CD58C02E800D4ACD50001D5C802D4C009475E094745F56402D498F01EF56502D499F57802D00AF57D0380B57902D57D03F5790260957D033F0A0B3F220B8D00E41180A834B009E41180A813B006DC1C7A10DA104DE4111C8D00CD189E5DF65A0EC415F6590EC414F65C0E2DF65B0EEE9A14EB10CFDD8D007A14CB151C2B15C4142F044B157C3DC806D0F8C414CEF52802EB15CFDA16F52802EB14CF6DF52902EB14CF7A16DA16F52902EB15CFFDAE7A16DA16F5730E0802FDE4163FFE05FCE4172DE447241AAED004CBF2C4F36F8D00F7403A402DF7403A40FDAE6F8FFF308FFF31C4046F2DE5FE0FECFF0FDA3BE8005DC73B3A3BD0FAAE6FE4D5F044E800C46BC46C8FFF5C8FFF0E8F0004E8008D0C3F06068D1C3F06068D2C3F06068D3C3F0606A248E800C4D5C4D7C4D9C4DBC4DDC4DFC4E1C4E3C4E5C4E7C431E8013F760A6F8FFF0E6F3F890FC408C4046F68F0F0A768F1F08668F2F0E868FFF0E86FE4046890F0186891F018E404300F80A840900A1C1C48FFFDE8E0CFCB3E6F8F01326F8F00326FC4041CF0336802D0D13F2206E5FC0FECFD0FDA403A403A408F020CE800C4308F0031C45FC439C436C4E5C4E7C43DC4F58FE03E8F000ED248E41A48FF0E46006FCD0E8F8047E800D50503E80A3F0909D51502D5A503D5F002D56402D4ADD4C11D1D4B47D0E0C45AC468C454C450C4428F00598F20536FEB08E40068F090035F8B06C4087E00F0035FC206E404F0E78F000EE40CF05E6E0CA8FA3DF53F0B06D020FDD0098FFF3D8FFFF55FC2068B421005C4428F003D3F0B06F842F0DCDA402FD8AB3DDA168D0FF716D6D400DC10F8CD008F0147F4D5F00AF51502D005E8003F9D08E800D5B803D484D485BCD4703D3D0B47D0E0CD00D85E8F0147D844F4D5F06C9B70D0623F9308D01DF5B803F08A3F0E0AF5B8039CD5B803D0EAF53C02D4D4F53D02D4D52FDE3020D500023F930830182D9F2807FDF60013D50102AE280FFDF60813D514023F930868E090053F81082FB33F1105F50002D470FDF50102CFDDD001BCD4712F033F720C3FEA0A3D3D0B47D088E454F00BBA567A526E5402BA54DA52E468F015BA647A60DA60BA667A626E6806BA68DA60EB6ADA62E45AF00EBA5C7A586E5A02BA5ADA588FFF5ECD008F0147F4D5F0033FA90B3D3D0B47D0F36F1CFDF68A0A2DF6890A2DDD5CFDF6290BF008E7D4BBD4D002BBD5FD6FD51502EB34D011FD100680A8CA60845F4D5DF5E00FCE2F09FD100680A8CA6084398D06CFDA1460980014981215E41A2447D0384DF5730E08045D8D00F714100E281F3820480E4800094749DD2F07E4474E4900F714D8F2C4F33DFCAD04D0F4CEF714D52902FCF714D528026FD56903281FD54103E800D540036FD4852D3F9308D5680380B54103CE3F2D0BD55403DDD555036FD5A0023F9308D58D023F9308D4ADD5B502E800D5A1026FD5A1022D8D00F4ADCE9EF844D5B4026FDD80A81EFDE800DA58E431D0038FFF316FC45A3F9308C45B80A459F85A3F2D0BDA5C6FE434D004E800DA526FC4543F9308C45580A453F8543F2D0BDA566FC4506FD5F0026FD5DC023F9308D5C9023F9308D4C16FE8012F02E800D57802DDD565023F9308D564023F9308D579026FD564026FEB34F002E8B4D50503E800D504036FD4842D3F9308D52C0380B50503CE3F2D0BD51803DDD519036FD5A5036FD550023F9308D551023F9308D5B803F4D4D53C02F4D5D53D02F55002D4D4F55102D4D56FC44A3F9308E800DA603F9308E800DA62B2486FC4683F9308C46980A461F8683F2D0BDA643F9308C46A80A463F8683F2D0BDA666FDA60DA62A2486F3F760A3F9308C44E3F93088D08CF5D8D0FF5250E3F06063DDD608810FD10F2F8446FC44D8D7DCBF2E4F3644DF029280F48FFF34C0360844CC44C8D04F6440EC4F2E800C4F3FEF5E44808208D6C3F0606E44D8D7D3F06061C1C1C48FF8088FF8D6D5F06062D7D6810900380A8049F5C608805FDAE08803FFE05FC6D3F9308C43F3F93089F1C043FEE3FFE056FEB34D003C45F6FC4396FF498D033E7D468F9D02D3F95083F9308D4993F9308D4983F930860845095F002287FD5A40380B57D03FB986DCE3F2D0BD59003DDD591036FF57D03C411F57C03C4106FED6B12100348FFBC8D009E2DE8009EEEF844F31206DA14BA1C9A146F9D080909170930093C09570968097A098309950998099C09A809C909D809F5094709AB09AF09C509F109190A4D0A540A2C0AFA0AE00A0000000000000000B80A0101020300010201020101030001020301030300010300030303010000000001F484F009E8048D039B843F490CFBC1F023F5DC02DEC01B09475EF5C8021007FCD004E8802F046095C902D5C8023FEF0D2F07BBC0E8FF3FFA0DF485F009E8408D039B853F490CE447245EF053F54103FDF54003DA10F5730EC412E432F0098F0A118F00108F0A11EB11F6110E80B6100EEB10CFDDEB116096100EFDF52D03CFF569031C1312011CDD900348FFBCEB123FFE058D14E8009A10DA10AB123312C86F09475EDA14DA164DEE60D00F982716687CF01560E800D714FC2F099814163F6B0CFCF7149716D7146FF471F0649B71F005E802DE705BF5B803C417F4D4FBD5DA148D00F714F01C3005FCF71410FB68C8F03F68EFF02968E090306DFDAE96A90AFD2FE0E417F0238B17D00AF53D022DF53C02EE2FCAF551022DF55002EE2FC0FCF7142DFCF714FDAE2FB5E4478D5C3FFE05F213F498F02CF499F0049B992F24E2139B98D00BF5A503D57C03F5A4032F1060F57C03959003D57C03F57D03959103D57D033F220BF4ADF04CF5A002DEAC44F5000175A102D005F5B5022F0D40BB0020FDF002F4AD6095B402D4ADF58C0260958D02D58C02C4121C1C900248FFFDF4AD68F19005280FCF2F04CFDD8D003FDA0D5F7B05BBACE313F86FF213F4C1F009F5DC02DEC0033FE20DF54103FDF54003DA10F485F00AF55503FDF554033FC40DF313033FFE0BF213F57D03FDF57C03DA10F498F00EF499D00AF59103FDF590033FC40DF4ADF0AFF5A002DEACA9EB51F58D02CFDD60958C025F3F0DE213CB123F3F0B6DEB51CFCB148F0015EB51AECF7A143F3F0B7A10DA106FE213EB51F5C902CFDD6095C8021C900248FFFBC1CFDD48FFEB34D003EB59CFF51402CFF50503CFDDCFDDD52D036F000103070D151E293442515E676E73777A7C7D7E7F7F0000000000000058BFDBF0FE070C0C0C212B2B13FEF3F9343300D9E501FCEB2C3C0D4D6C4C5C3D2D5C6B6C4E3848450E494B465F08DE086509F4098C0A2C0BD60B8B0C4A0D140EEA0ECD0FBE100000100020003000400050006000700060007000FA1A37383F1A8FFF348F005E8F4047CD10E4F6F00C0947460947370947363FCA0E3F300F8F8047CD12E4F7F00C0947460947370947363FCA0E3F300F8F0034FA371A6F1C4D5DF50114FDF50014CED4D4DBD5E896D50503E80A3F0909E800D51502D5A503D5F002D56402D4ADD4C1D5B803D484D485E802D4706FE44748FFFD2437C437DD2436C43609475EFA475C0947468F00344D7D80A8045DF515023F9D08CE8FFF34E800D4D56FF4D5F054D8449B70D0453F9308F0C23020D500023F930830182D9F2807FDF60013D50102AE280FFDF60813D514023F930868E090053F81082FD03F1105F50002D470FDF50102CFDDD001BCD4712F033F720C3FEA0A3FA90B6F8DBBE8AADAF4E4F468CCD0FA2F1EEBF4D0FC7EF4D010CBF4E4F5D60000FCD0F2ACA50F5F9B0F10EA7EF410E6BAF6C5A40FCCA50FEBF4E4F5CBF4D0D2CD33D8F16F00000004