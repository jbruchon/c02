; Kernel start routine for C64
; C02/boot/c64/start.s
;
; Copyright (C) 2004, 2005 by Jody Bruchon

main
        sei
        lda #$05
        sta $01
        jmp $ff00
