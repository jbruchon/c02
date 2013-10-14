; C02 Operating System
; debug.s: Debugging helper stuff
; Copyright (C) 2004-2008 by Jody Bruchon

; This will print a string terminated with a carriage return
; ($0d) to the console device.
; The string must be pointed to by the "debugmessage" vector in
; zero-page.

debugprint
        sta debuga
        php                             ; Don't mangle the current state
        pla
        sta debugp
        stx debugx
        sty debugy
        ldx #$00                        ; Select console device
        ldy #$00                        ; Counter for message printing
debugprint1
        lda (debugmessage),y            ; Grab next char from message
        sty debugtmp0                   ; Save counter
        sta debugtmp1                   ; Save character for compare
        ldx #$00                        ; Send to char dev 0 = console
        jsr putchar
        bcc debugprint2                 ; If carry clear, all is well
        jsr kernelpanic                 ; If carry set, panic
debugprint2
        lda #$0d                        ; Load a CR into A for compare
        cmp debugtmp1                   ; Check against character
        beq debugprint3                 ; If equal, finish up
        ldy debugtmp0                   ; Restore counter value
        iny                             ; Increment counter
        jmp debugprint1                 ; Do it again until done
debugprint3
        ldx debugx                      ; Restore current state
        ldy debugy
        lda debugp
        pha
        lda debuga
        plp
        rts                             ; Return to caller

