# I058 open questions

Mesen2 MCP was not available in this session, so everything below is UNVERIFIED-RUNTIME. IDs are cited in the merged notes.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I058-1 | I058 | What does the world-map screen look like below the boundary row (Mode 1 with BG3 priority, plus a white fixed-colour write on every other scanline from the `$01FF` fill) and above it (Mode 7 with the map)? Is this the intended "iris" look the old comments describe, or a bug-like leftover? Does the boundary row really leave the 224-line screen after the 40-frame ramp? | E1: table templates `7F 07 18 07 01 09 00` (BGMODE) and `7F 00 18 00 01 FF 00` (COLDATA); offset added to the second line count (`$18 + 2 x 40 = $68`); `InitSineTableBuffers` fill; E4: BGMODE and COLDATA bit layouts | Start a world-map travel and screenshot frames 0, 2, 20 and 42; read the HDMA tables at `$7E8800-$7E8B00` and the channel set-up registers |
| OQ-I058-2 | I058 | What do the 48 parts of `sprite_group_000008` draw (the comet and its tail?) and which OBJ palette do they use? | E1: tile words `$0904-$09E9`, palette bits from the tile words; rows 16 px apart on a diagonal; `TitleCometSpriteActor` plays animation `#00` | Screenshot the title scene during the sweep and read OBJ tile numbers and palettes in the PPU viewer |
