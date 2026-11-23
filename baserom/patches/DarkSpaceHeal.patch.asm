; Restore current HP from max HP once on entry, before Gaia selects the room layout.
?INCLUDE 'sE6_gaia'

sE6_gaia.DarkSpaceMainInit-= {
    LDA $0ACA
    STA $0ACE
}
