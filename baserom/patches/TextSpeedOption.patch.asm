

  loc_03E7C2!:

    INC
    LSR
    PHA 
    LDA $worldReadyFlag   ; worldReadyFlag not set → return immediately (no frame sync during init)
    BNE loc_03E7CC
    PLA 
    PLP 
    RTS 
