; Central COP bytecode dispatch engine for IOG's actor and thinker scripting system (Bank $00).
; 
; Contains CopDispatch, a 24-byte native-mode entry reached from the COP interrupt vector (CopVector → JML CopDispatch). On each COP ($02) instruction it reads the opcode byte from the script stream, doubles it, and indirect-jumps through cop_dispatch_table to the matching handler across 13 handler blocks.
; 
; The 227-entry table maps 209 valid opcodes ($00–$6D and $80–$E2) to short-address handler labels; opcodes $6E–$7F are an 18-entry #$0000 gap that would crash if executed. A cop_table_sentinel (NOP/BRA loop) guards the table end.
; 
; Every actor and thinker script in the game routes through this dispatcher—movement, collision, spawning, dialogue, palette, and DMA all depend on it. Handlers receive Actor ID in X/Y, DBR=$81, an argument pointer in $0A, and exit via RTI (continue/branch) or RTL (yield/halt).
; 
; Dispatch target blocks: cop_handlers_audio, cop_handlers_effects, cop_handlers_flow, cop_handlers_input, cop_handlers_lifecycle, cop_handlers_map, cop_handlers_movement, cop_handlers_palette, cop_handlers_player_sprite, cop_handlers_solid, cop_handlers_spatial, cop_handlers_spawn, cop_handlers_sprite.
; 
; Support blocks (called internally by handlers, not dispatch targets): actor_pool, cop_handlers_flags.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_audio'
?INCLUDE 'cop_handlers_effects'
?INCLUDE 'cop_handlers_flow'
?INCLUDE 'cop_handlers_input'
?INCLUDE 'cop_handlers_lifecycle'
?INCLUDE 'cop_handlers_map'
?INCLUDE 'cop_handlers_movement'
?INCLUDE 'cop_handlers_palette'
?INCLUDE 'cop_handlers_player_sprite'
?INCLUDE 'cop_handlers_solid'
?INCLUDE 'cop_handlers_spatial'
?INCLUDE 'cop_handlers_spawn'
?INCLUDE 'cop_handlers_sprite'

---------------------------------------------

; Central COP bytecode dispatcher reached from CopVector. Reads the opcode byte from the script stream at [$0A], doubles it as a word index, and indirect-jumps through cop_dispatch_table to the matching handler. Sets up X=Y=ActorID, script pointer $0A, and bank byte $0C from the COP interrupt stack frame.

CopDispatch {
    REP #$20              ; Native 16-bit mode for opcode fetch and table indexing
    TXY                   ; Preserve actor ID in Y — restored by handlers that need it
    LDA $04, S
    STA $0C               ; Cache script bank byte from stack frame $04,S into $0C
    LDA $02, S
    DEC                   ; Return PC − 1 → points at COP opcode byte on stack
    STA $0A               ; Script arg pointer $0A — first byte is opcode, then operands
    LDA [$0A]             ; Fetch COP opcode byte via indirect long [$0A]
    INC $0A               ; Advance $0A past opcode into operand stream
    AND #$00FF
    ASL                   ; ASL: word index = opcode × 2 into cop_dispatch_table
    TAX 
    JMP ($&cop_dispatch_table, X) ; Indirect JMP through 227-entry handler pointer table (209 valid + 18 gap)
}

---------------------------------------------
; 227-entry handler pointer table mapping COP opcodes $00–$6D and $80–$E2 (209 valid) to short-address handler labels across 13 handler blocks. Opcodes $6E–$7F are an 18-entry #$0000 gap that would crash if executed.

cop_dispatch_table [
  &cop_handlers_solid.GenHdmaSine   ;00
  &cop_handlers_solid.QueueHdma   ;01
  &cop_handlers_solid.QueueDma   ;02
  &cop_handlers_solid.QueueHdmaChannel   ;03
  &cop_handlers_audio.StartMusic   ;04
  &cop_handlers_audio.FadeThenStartMusic   ;05
  &cop_handlers_audio.PlaySoundCh2   ;06
  &cop_handlers_audio.PlaySoundCh1   ;07
  &cop_handlers_audio.PlaySoundBoth   ;08
  &cop_handlers_audio.WriteApuIo1   ;09
  &cop_handlers_audio.WriteApuIo0   ;0A
  &cop_handlers_solid.MarkSolidHere   ;0B
  &cop_handlers_solid.ClearSolidHere   ;0C
  &cop_handlers_solid.MarkSolidOffset   ;0D
  &cop_handlers_solid.ClearSolidOffset   ;0E
  &cop_handlers_solid.MarkSolidAbs   ;0F
  &cop_handlers_solid.ClearSolidAbs   ;10
  &cop_handlers_solid.ClearCollisionHere   ;11
  &cop_handlers_solid.ClearTypeAbs   ;12
  &cop_handlers_solid.BranchIfSolidHere   ;13
  &cop_handlers_solid.BranchIfSolidOffset   ;14
  &cop_handlers_solid.BranchIfSolidNorth   ;15
  &cop_handlers_solid.BranchIfSolidSouth   ;16
  &cop_handlers_solid.BranchIfSolidWest   ;17
  &cop_handlers_solid.BranchIfSolidEast   ;18
  &cop_handlers_audio.MusicAndText   ;19
  &cop_handlers_solid.BranchIfTypeHere   ;1A
  &cop_handlers_solid.BranchIfTypeNorth   ;1B
  &cop_handlers_solid.BranchIfTypeSouth   ;1C
  &cop_handlers_solid.BranchIfTypeWest   ;1D
  &cop_handlers_solid.BranchIfTypeEast   ;1E
  &cop_handlers_solid.BranchIfNotOnGridline   ;1F
  &cop_handlers_movement.BranchIfActorNear   ;20
  &cop_handlers_movement.BranchIfPlayerNear   ;21
  &cop_handlers_movement.MoveToward   ;22
  &cop_handlers_movement.RngByte   ;23
  &cop_handlers_movement.RngMod   ;24
  &cop_handlers_spatial.SetTilePos   ;25
  &cop_handlers_spatial.QueueMapChange   ;26
  &cop_handlers_spatial.WaitWhileOffscreen   ;27
  &cop_handlers_spatial.BranchIfPlayerAt   ;28
  &cop_handlers_spatial.BranchIfActorAt   ;29
  &cop_handlers_spatial.BranchOnPlayerX   ;2A
  &cop_handlers_spatial.BranchOnPlayerY   ;2B
  &cop_handlers_spatial.BranchNearerAxis   ;2C
  &cop_handlers_spatial.DirToPlayer   ;2D
  &cop_handlers_spatial.DirToPlayerFrom   ;2E
  &cop_handlers_spatial.BranchIfDirToPlayer   ;2F
  &cop_handlers_spatial.BranchIfDirToPlayerFrom   ;30
  &cop_handlers_spatial.BranchOnPlayerFacing   ;31
  &cop_handlers_palette.StageBgChange   ;32
  &cop_handlers_palette.ApplyBgChange   ;33
  &cop_handlers_palette.StageBgChangeFromDeathIdx   ;34
  &cop_handlers_spatial.CardinalToPlayer   ;35
  &cop_handlers_palette.PaletteRestart   ;36
  &cop_handlers_palette.PaletteStart   ;37
  &cop_handlers_palette.PaletteStartLoop   ;38
  &cop_handlers_palette.PaletteStep   ;39
  &cop_handlers_palette.PaletteStepLoop   ;3A
  &cop_handlers_palette.SpawnThinkerParam   ;3B
  &cop_handlers_palette.SpawnThinker   ;3C
  &cop_handlers_palette.KillThinker   ;3D
  &cop_handlers_input.WaitForButton   ;3E
  &cop_handlers_input.WaitForRelease   ;3F
  &cop_handlers_input.BranchIfPressed   ;40
  &cop_handlers_input.BranchIfNotPressed   ;41
  &cop_handlers_solid.SetCollisionAbs   ;42
  &cop_handlers_movement.SnapToGrid   ;43
  &cop_handlers_lifecycle.BranchIfPlayerInRelTiles   ;44
  &cop_handlers_lifecycle.BranchIfPlayerInAbsTiles   ;45
  &cop_handlers_lifecycle.CopyPosToPrev   ;46
  &cop_handlers_lifecycle.CopyPosToNext   ;47
  &cop_handlers_lifecycle.GetPlayerFacing   ;48
  &cop_handlers_lifecycle.BranchIfBodyNe   ;49
  &cop_handlers_movement.ResumeAfterSnap   ;4A
  &cop_handlers_map.DrawMetatileAbs   ;4B
  &cop_handlers_map.DrawMetatileHere   ;4C
  &cop_handlers_map.WorldMapStream3   ;4D
  &cop_handlers_map.WorldMapStream4   ;4E
  &cop_handlers_map.AdhocVramDma   ;4F
  &cop_handlers_map.CopyPalette   ;50
  &cop_handlers_map.Decompress   ;51
  &cop_handlers_movement.StageMove   ;52
  &cop_handlers_movement.TickMove   ;53
  &cop_handlers_map.SetScratchPointer   ;54
  &cop_handlers_sprite.ResetSpriteState   ;55
  &cop_handlers_sprite.AdvanceSpriteAnim   ;56
  &cop_handlers_lifecycle.SetDeathCallback   ;57
  &cop_handlers_lifecycle.SetHitCallback   ;58
  &cop_handlers_lifecycle.SetDodgeCallback   ;59
  &cop_handlers_lifecycle.SetCollideCallback   ;5A
  &cop_handlers_lifecycle.OrExtraFlags   ;5B
  &cop_handlers_lifecycle.AndExtraFlags   ;5C
  &cop_handlers_map.BranchIfBehindWall   ;5D
  &cop_handlers_lifecycle.SetCustomCallback   ;5E
  &cop_handlers_effects.InitSineHdma   ;5F
  &cop_handlers_effects.TickSineHdma   ;60
  &cop_handlers_effects.BindSineHdma   ;61
  &cop_handlers_map.BranchIfCollisionTypeNe   ;62
  &cop_handlers_effects.InitGravity   ;63
  &cop_handlers_effects.TickGravity   ;64
  &cop_handlers_input.StageWorldMapMove   ;65
  &cop_handlers_input.StageWorldMapChoice   ;66
  &cop_handlers_input.StageWorldMapMoveIds   ;67
  &cop_handlers_map.BranchIfOffCamera   ;68
  &cop_handlers_map.HaltIfMaxFrames   ;69
  &cop_handlers_lifecycle.SetLinkedEntryPtr   ;6A
  &cop_handlers_input.PrintDialogStringAlt   ;6B
  &cop_handlers_effects.InitSpiral   ;6C
  &cop_handlers_effects.SpiralStep   ;6D
  #$0000   ;6E
  #$0000   ;6F
  #$0000   ;70
  #$0000   ;71
  #$0000   ;72
  #$0000   ;73
  #$0000   ;74
  #$0000   ;75
  #$0000   ;76
  #$0000   ;77
  #$0000   ;78
  #$0000   ;79
  #$0000   ;7A
  #$0000   ;7B
  #$0000   ;7C
  #$0000   ;7D
  #$0000   ;7E
  #$0000   ;7F
  &cop_handlers_sprite.StageSpr   ;80
  &cop_handlers_sprite.StageSprX   ;81
  &cop_handlers_sprite.StageSprY   ;82
  &cop_handlers_sprite.StageSprXY   ;83
  &cop_handlers_sprite.StageSprLoop   ;84
  &cop_handlers_sprite.StageSprLoopX   ;85
  &cop_handlers_sprite.StageSprLoopY   ;86
  &cop_handlers_sprite.StageSprLoopXY   ;87
  &cop_handlers_sprite.SetMetasprite   ;88
  &cop_handlers_sprite.AnimOnce   ;89
  &cop_handlers_sprite.AnimLoop   ;8A
  &cop_handlers_sprite.AnimOneFrame   ;8B
  &cop_handlers_sprite.WaitForAnimFrame   ;8C
  &cop_handlers_sprite.StageSprAndHitbox   ;8D
  &cop_handlers_player_sprite.SetPlayerSpriteDirect   ;8E
  &cop_handlers_player_sprite.StagePlayerSpr   ;8F
  &cop_handlers_player_sprite.StagePlayerSprX   ;90
  &cop_handlers_player_sprite.StagePlayerSprY   ;91
  &cop_handlers_player_sprite.StagePlayerSprXY   ;92
  &cop_handlers_player_sprite.RunPlayerAnim   ;93
  &cop_handlers_player_sprite.StagePlayerSprWall   ;94
  &cop_handlers_player_sprite.StagePlayerSprFromDP   ;95
  &cop_handlers_player_sprite.WallAnimHere   ;96
  &cop_handlers_player_sprite.WallAnimNorth   ;97
  &cop_handlers_player_sprite.WallAnimSouth   ;98
  &cop_handlers_spawn.SpawnBefore   ;99
  &cop_handlers_spawn.SpawnBeforeFlags   ;9A
  &cop_handlers_spawn.SpawnAfter   ;9B
  &cop_handlers_spawn.SpawnAfterFlags   ;9C
  &cop_handlers_spawn.SpawnAfterOffset   ;9D
  &cop_handlers_spawn.SpawnAfterOffsetFlags   ;9E
  &cop_handlers_spawn.SpawnAfterAbs   ;9F
  &cop_handlers_spawn.SpawnAfterAbsFlags   ;A0
  &cop_handlers_spawn.SpawnBeforeMarked   ;A1
  &cop_handlers_spawn.SpawnAfterMarked   ;A2
  &cop_handlers_spawn.SpawnAfterAbsMarked   ;A3
  &cop_handlers_spawn.SpawnAfterOffsetMarked   ;A4
  &cop_handlers_spawn.SpawnListAppend   ;A5
  &cop_handlers_spawn.SpawnListAppendSpr   ;A6
  &cop_handlers_lifecycle.MarkDeath   ;A7
  &cop_handlers_lifecycle.KillPrev   ;A8
  &cop_handlers_lifecycle.KillNext   ;A9
  &cop_handlers_lifecycle.StageMoveX   ;AA
  &cop_handlers_lifecycle.StageMoveY   ;AB
  &cop_handlers_lifecycle.StageMoveXY   ;AC
  &cop_handlers_lifecycle.ForceDirSW   ;AD
  &cop_handlers_lifecycle.ForceDirNE   ;AE
  &cop_handlers_lifecycle.ForceDirBoth   ;AF
  &cop_handlers_lifecycle.ApplyMoveToChild   ;B0
  &cop_handlers_lifecycle.ReloadMoveDurations   ;B1
  &cop_handlers_lifecycle.SetPriorityMax   ;B2
  &cop_handlers_lifecycle.SetPriorityMin   ;B3
  &cop_handlers_lifecycle.ClearPriorityMax   ;B4
  &cop_handlers_lifecycle.ClearPriorityMin   ;B5
  &cop_handlers_lifecycle.SetOamPriority   ;B6
  &cop_handlers_lifecycle.SetOamPalette   ;B7
  &cop_handlers_lifecycle.ToggleHMirror   ;B8
  &cop_handlers_lifecycle.ToggleVMirror   ;B9
  &cop_handlers_lifecycle.ClearHMirror   ;BA
  &cop_handlers_lifecycle.SetHMirror   ;BB
  &cop_handlers_lifecycle.NudgePosition   ;BC
  &cop_handlers_input.RunBg3Script   ;BD
  &cop_handlers_input.DialogueOptions   ;BE
  &cop_handlers_input.PrintDialogString   ;BF
  &cop_handlers_flow.SetInteractHandler   ;C0
  &cop_handlers_flow.SetEntryHere   ;C1
  &cop_handlers_flow.SetEntryHereAndYield   ;C2
  &cop_handlers_flow.JumpAfterDelay   ;C3
  &cop_handlers_flow.JumpNextFrame   ;C4
  &cop_handlers_flow.RestoreSavedPtr   ;C5
  &cop_handlers_flow.SetSavedPtr   ;C6
  &cop_handlers_flow.JumpFar   ;C7
  &cop_handlers_flow.CallNear   ;C8
  &cop_handlers_flow.CallNearDeferred   ;C9
  &cop_handlers_flow.LoopStart   ;CA
  &cop_handlers_flow.LoopEnd   ;CB
  &cop_handlers_flow.SetFlagByte   ;CC
  &cop_handlers_flow.SetFlagWord   ;CD
  &cop_handlers_flow.ClearFlagByte   ;CE
  &cop_handlers_flow.ClearFlagWord   ;CF
  &cop_handlers_flow.BranchOnFlagByte   ;D0
  &cop_handlers_flow.BranchOnFlagWord   ;D1
  &cop_handlers_flow.WaitOnFlagByte   ;D2
  &cop_handlers_flow.WaitOnFlagWord   ;D3
  &cop_handlers_flow.GiveItem   ;D4
  &cop_handlers_flow.RemoveItem   ;D5
  &cop_handlers_flow.BranchIfMissingItem   ;D6
  &cop_handlers_flow.BranchIfItemEquipped   ;D7
  &cop_handlers_flow.SetDungeonKillFlag   ;D8
  &cop_handlers_flow.SwitchCase   ;D9
  &cop_handlers_flow.WaitByte   ;DA
  &cop_handlers_flow.WaitWord   ;DB
  &cop_handlers_effects.CameraPanDown   ;DC
  &cop_handlers_effects.CameraPanUp   ;DD
  &cop_handlers_effects.CameraPanRight   ;DE
  &cop_handlers_effects.CameraPanLeft   ;DF
  &cop_handlers_lifecycle.Die   ;E0
  &cop_handlers_flow.ReturnWithSignal   ;E1
  &cop_handlers_flow.SetEntryFar   ;E2
]

---------------------------------------------
; End-of-table guard: a NOP/BRA infinite loop that catches any opcode past $E2, preventing execution from falling into unmapped ROM.

cop_table_sentinel {
    NOP                   ; cop_table_sentinel: NOP/BRA loop guards past opcode $E2
    BRA cop_table_sentinel
}