; Unused proximity check subroutine.
; 
; Returns carry set if player is not near (BranchIfPlayerNear radius 7),
; carry clear if near. No references anywhere in the ROM.
---------------------------------------------

?BANK 0A

---------------------------------------------

unused_proximity_check_noref {
    COP [BranchIfPlayerNear] ( #07, &code_0AEE9D )
    SEC 
    RTS 
}

code_0AEE9D {
    CLC 
    RTS 
}