; C02 Operating System
; math.s: Mathematical functions
; Copyright (C) 2004-2008 by Jody Bruchon

; multiply8 provides an 8-bit multiply with 16-bit result.
; This should not produce results above $fe01 ($ff * $ff)
; *SYSCALL*
multiply8
!ifdef CONFIG_6502 {
        lda #$00
        sta zp0                 ; Init result
} else {
        stz zp0                 ; Init result [Optimized]
}
        ldy #$08                ; Init multiplier loop
multiply8loop
        asl zp0                 ; Shift low byte left
        rol zp1                 ; Shift high byte left
        bcc multiply8noc        ; No carry = loop around
        clc
        txa                     ; Move multiplier into A
        adc zp0                 ; Add multiplier to result
        sta zp0                 ; Store new low byte
        lda zp1                 ; Load high byte
        adc #$00                ; Add carry (if any) to high byte
        sta zp1                 ; Store new high byte
multiply8noc
        dey                     ; Decrement counter
        bne multiply8loop       ; If not zero, do again
        rts                     ; Return to program
