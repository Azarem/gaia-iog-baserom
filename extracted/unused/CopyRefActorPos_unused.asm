; Unreferenced three-instruction snippet that copies $0014/$0016 from actor Y into the current actor's position.
; 
; Would have been a JSL target for simple position mirroring. Functionality is inlined elsewhere where needed.
---------------------------------------------

---------------------------------------------

CopyRefActorPos_unused {
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
}