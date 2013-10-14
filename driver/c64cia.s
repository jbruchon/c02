; C02 Operating System
; c64cia.s: Commodore 64 CIA handler
; Copyright (C) 2004-2008 by Jody Bruchon

; For now, this is a placeholder that clears IRQ conditions and exits

c64ciairqhook
        lda $dc0d               ; c64: Silence the CIA 1 interrupts
        lda $dd0d               ; c64: Silence the CIA 2 interrupts
        rts                     ; Return to IRQ handler
