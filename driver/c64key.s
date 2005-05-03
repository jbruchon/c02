; C02 Operating System
; c64key.s: Commodore 64 keyboard driver
; Copyright (C) 2004, 2005 by Jody Bruchon

; c64keyirqhook is the IRQ hook point for this driver.

c64keyirqhook
        lda #$ff                ; Set C64 CIA #1 port A to OUTPUT
        sta $dc02
!ifdef CONFIG_6502 {
        lda #$00                ; Set C64 CIA #1 port B to INPUT
        sta $dc03
} else {
        stz $dc03               ; Set CIA PB to INPUT [Optimized]
}
        clc
!ifdef CONFIG_6502 {
        lda #$00                ; Prescan to see if a key is pressed
        sta $dc00
} else {
        stz $dc00
}

c64kdbounce
        ldx $dc01               ; Get value of prescan
        cpx $dc01               ; Debounce check
        bne c64kdbounce         ; Bad compare = bounce
        cpx #$ff                ; If no key pressed, CIA1 PB = $ff
        bne c64kscn1            ; Uh-oh, keys depressed, start scan.
        lda c64kflags           ; If keys WERE pressed before this scan
        and #$80                ; bit 7 in kflags set = a key was pressed
        cmp #$00                ; we need to send "unpressed" scancodes.
        beq c64krts             ; If none were pressed, exit scanner.
        lda c64kkey             ; Load last key pressed
        ora #$80                ; Bit 7 set in scancodes = "unpressed"
        jsr queuekey            ; queuekey stores the keypress for us.
c64krts
        rts                     ; No keys pressed = return to IRQ hooks

c64kscn1
        lda #$01                ; Start keyscan
        sta $dc00
        ldx $dc01              ; Scan row 1
        stx c64ktmp
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+1
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+2
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+3
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+4
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+5
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+6
        rol
        sta $dc00
        ldx $dc01
        stx c64ktmp+7
c64kdecode
        ldx #$00                ; Decoder logic (uses lookup table)


; Below is the scancode lookup table used by the decoder routine.

c64ktable

!08 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 ; 0-15
!08 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 ; 16-31
!08 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 ; 32-47
!08 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 ; 48-63
