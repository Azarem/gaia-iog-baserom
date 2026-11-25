?INCLUDE 'item_use_system'

; Signal Lance's recovery when the melody finishes and keep it in inventory.
item_use_system.UseItem_MemoryMelody_Effect! {
    COP [SpawnThinkerParam] ( #1B, @actor_pool.PaletteResetAndKillThinker )
    COP [SetFlagByte] ( #0F )
    COP [RestoreSavedPtr]
}
