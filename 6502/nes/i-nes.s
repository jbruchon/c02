; C02 Operating System
; i-nes.s: NES architecture-specific initializations
; Copyright (C) 2004-2008 by Jody Bruchon

; Disable all graphics
        lda #$00
        sta $2000
        sta $2001

; Spinlock on bit 7 of $2002 to wait for 2 VBlanks
inesvblankwait1
        lda $2002
        bpl inesvblankwait1
inesvblankwait2
        lda $2002
        bpl inesvblankwait2