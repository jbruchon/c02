; C02 Operating System
; testterm.s: Initial task to echo console input to console output
; Copyright (C) 2004, 2005 by Jody Bruchon

beginning
        ldx #$00
        jsr getchar
        cmp #$00
        beq beginning
        ldx #$00
        jsr putchar
        jmp beginning
