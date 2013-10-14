; C02 Operating System
; testcon.s: Initial task to test console functionality
; Copyright (C) 2004-2008 by Jody Bruchon

; This code snippet throws out all possible characters $20-$7f
; to the console without using keyboard input.  A delay loop
; controls the speed at which the characters are thrown out.

        lda #$20                ; Start at zero (nothing)
beginning
        clc
        adc #$01                ; Increment char to print
        cmp #$80                ; Is it $80 yet?
        bne cmpisok             ; No = don't reset
        lda #$20
cmpisok
        ldx #$00                ; Select console
        pha                     ; Save current char
        jsr putchar             ; Send char to console
        pla

        ldy #$00                ; Prepare for delay
loopiness
        iny                     ; Increment Y
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        cpy #$00
        bne loopiness           ; Loop

        jmp beginning           ; Loop forever...
