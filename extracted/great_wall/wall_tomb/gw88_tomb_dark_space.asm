; Dark Space portal in the Great Wall tomb area.
; 
; Hidden Dark Space access point in the tomb section.
; Checks visibility/flag conditions before spawning the
; Dark Space portal. Provides a save/heal point mid-dungeon.
---------------------------------------------

?INCLUDE 'dark_space'

---------------------------------------------

gw88_tomb_dark_space [
  actor-def < #00, #00, #30, {

  code_07BDEB:
    COP [BranchOnFlagWord] ( #$0174, #01, &code_07BE09 )
    COP [SetEntryHere]
    LDA $0A9F
    AND #$00FF
    CMP #$003F
    BEQ loc_07BE00
    RTL 

  loc_07BE00:
    COP [StageBgChange] ( #74 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0174 )
} >
]

code_07BE09 {
    COP [SpawnAfterAbsFlags] ( @dark_space.DarkSpacePortalInit, #$01C8, #$0280, #$2B00 )
    LDA #$0001
    STA $0024, Y
    LDA #$2000
    STA $000E, Y
    COP [Die]
}