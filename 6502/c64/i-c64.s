; C02 Operating System
; i-c64.s: Commodore 64 architecture-specific initializations
; Copyright (C) 2004-2008 by Jody Bruchon

        lda #$05                ; Make SURE 6510 keeps I/O banked in!
        sta $01                 ; LORAM+CHAREN=I/O.  CHAREN only=RAM :(
