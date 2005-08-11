; C02 Operating System
; testterm.s: Initial task to echo console input to console output
; Copyright (C) 2004, 2005 by Jody Bruchon

; This code snippet echoes console input to console output.
; A null ($00) from input means no characters exist to be input.

beginning
        ldx #$00                ; Select device 0 (console)
        jsr getchar             ; Get character from device 0
        cmp #$00                ; Is char null?
        beq beginning           ; Yes: try again
        ldx #$00                ; No: select console again 
        jsr putchar             ; Echo char back to console
        jmp beginning           ; Loop forever...
