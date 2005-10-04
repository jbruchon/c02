; C02 Operating System
; c64key.s: Commodore 64 keyboard driver
; Copyright (C) 2004, 2005 by Jody Bruchon

; c64keyirqhook is the IRQ hook point for this driver

c64kshrow .byte $01,$06,$07,$07,$0a
c64kshbit .byte $80,$10,$20,$04,$01
c64kshflag .byte $01,$01,$02,$04,$08

c64keyirqhook
        lda #$00
        sta $dc00               ; Disable all rows for joy #1 check
        jsr c64kdebounce
        cmp #$ff                ; Check if keys are held
        beq c64knokeys          ; No = don't scan

        jsr c64kchkjoy          ; Check for joystick interference
        jsr c64kscan            ; Scan keys
;        jsr c64kchkjoy          ; Check joystick again
        jsr c64kshifts          ; Check shift/ctrl/C= keys
        jsr c64kdecode          ; Decode pressed keys
        jsr c64kcheck           ; Figure out what key to queue
        jmp queuekey            ; Queue the key

c64knokeys
        lda #$ff
c64knokeys1
        sta c64koldkeys,x       ; Clear out old pressed keys entirely
        dex
        bpl c64knokeys1
        lda c64kflags
        and #%01110000          ; Clear out ignore and shift flags
        sta c64kflags
        rts                     ; No key held, so quit trying

c64kchkjoy
        lda #$ff                ; Clear keyboard rows to check joystick
        sta $dc00               ; Store in port register
        jsr c64kdebounce
        cmp #$ff                ; $ff = no joystick presses
        bne c64knokeys          ; If not $ff, then ignore keyboard
        rts

c64kscan
        ldx #$00                ; Start at scan table location 0
        lda #$fe                ; Mark a row to scan
        sta temp                ; Store scan row value
c64kscan1
        lda temp                ; Restore current scanning row value
        sta c64kporta           ; Store scan value in CIA port
;        jsr c64kdebounce        ; Debounce result
        eor #$ff                ; Invert result to a "nicer" number
        sta c64kscantbl,x       ; Store inverted result to scan table
        sec                     ; Make sure no zeroes are introduced
        rol temp                ; Change scanning row
        inx                     ; Increment scan table location
        cpx #$08                ; Done with scanning for all rows?
        bne c64kscan1           ; No = keep scanning!
        rts

c64kshifts
        ldy #4               ;  them from the scan matrix
c64kshifts1
        ldx shiftRows,y
        lda scanTable,x
        and shiftBits,y
        beq c64kshifts2
        lda shiftMask,y
        ora shiftValue
        sta shiftValue
        lda shiftBits,y
        eor #$ff
        and scanTable,x
        sta scanTable,x
c64kshifts2
        dey
        bpl c64kshifts1
        rts

c64kdecode

c64kcheck

c64kdebounce
        lda c64kportb
        cmp c64kportb
        bne c64kdebounce
        rts
