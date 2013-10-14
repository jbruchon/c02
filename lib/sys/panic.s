; C02 Operating System
; panic.s: Kernel panic code
; Copyright (C) 2004-2008 by Jody Bruchon

; kernelpanic will halt the system entirely and should only be called
; in the event of a failure that should not happen but did anyway.
; This will stop EVERYTHING on the system and you cannot recover from it!

; Calling this will print the following to the screen as debug help:
; "PANIC $xxxx" where xxxx is the hex address of the last byte of the
; JSR instruction that called kernelpanic.  If this is called with a
; JMP instruction, the "address" provided will not be helpful.

; You must have a console driver for this to build and work properly!

kernelpanic
        sei                             ; Prevent interruptions
        sta debuga                      ; Save processor state
        stx debugx
        sty debugy
        php
        pla
        sta debugp
        tsx
        stx zp4
        pla                             ; Pull calling address low/high
        sta zp5                         ; Store address temporarily
        pla
        sta zp6
        lda #$0d
        jsr consoleput
        lda #$50                        ; "PANIC $" string here
        jsr consoleput
        lda #$41
        jsr consoleput
        lda #$4e
        jsr consoleput
        lda #$49
        jsr consoleput
        lda #$43
        jsr consoleput
        lda #$20
        jsr consoleput
        lda #$24
        jsr consoleput
; Put panic address to screen
        lda zp6                         ; Retrieve caller's location
        jsr kernelpanichigh             ; Send out high nybble
        lda zp6
        jsr kernelpaniclow              ; Send out low nybble
        lda zp5
        jsr kernelpanichigh             ; Send out high nybble
        lda zp5
        jsr kernelpaniclow              ; Send out low nybble
        lda #$0d                        ; (carriage return)
        jsr consoleput

; Put panic A/X/Y/P/SP to screen

        lda #$41
        jsr consoleput
        lda #$3d
        jsr consoleput
        lda debuga
        jsr kernelpanichigh
        lda debuga
        jsr kernelpaniclow
        lda #$20
        jsr consoleput

        lda #$58
        jsr consoleput
        lda #$3d
        jsr consoleput
        lda debugx
        jsr kernelpanichigh
        lda debugx
        jsr kernelpaniclow
        lda #$20
        jsr consoleput

        lda #$59
        jsr consoleput
        lda #$3d
        jsr consoleput
        lda debugy
        jsr kernelpanichigh
        lda debugy
        jsr kernelpaniclow
        lda #$20
        jsr consoleput

        lda #$50
        jsr consoleput
        lda #$3d
        jsr consoleput
        lda debugp
        jsr kernelpanichigh
        lda debugp
        jsr kernelpaniclow
        lda #$20
        jsr consoleput

        lda #$53
        jsr consoleput
        lda #$3d
        jsr consoleput
        lda zp4
        jsr kernelpanichigh
        lda zp4
        jsr kernelpaniclow
        lda #$0d
        jsr consoleput

; Stack dump

        ldx #$00
kernelpanicdump
        stx debugx
        ldx debugx
        lda $0100,x
        sta debuga
        jsr kernelpanichigh
        lda debuga
        jsr kernelpaniclow
        ldx debugx
        inx
        bne kernelpanicdump

kernelpanicloop
        clc
        bcc kernelpanicloop             ; Loop forever

kernelpaniclow
        and #$0f                        ; Cut high nybble out
; Inline all the code for expensive optimizations
!ifdef CONFIG_EXPENSIVE {
        cmp #$0a                        ; Is it going to be a-f?
        bmi EX_kernelpanichigh1         ; No = add a different number...
	clc
        adc #$37                        ; ASCII A = $37 + $0A
	jmp consoleput
EX_kernelpanichigh1
	clc
	adc #$30			; ASCII 0 = $30
        jmp consoleput
} else {
	jmp kernelpanichigh0		; Nybble is normalized!
}

kernelpanichigh
        lsr                             ; Translate high down to low
        lsr
        lsr
        lsr				; Nybble is normalized!

kernelpanichigh0
!ifdef CONFIG_SPEED {
        cmp #$0a                        ; Is it going to be a-f?
        bmi kernelpanichigh1            ; No = add a different number...
	clc
        adc #$37                        ; ASCII A = $37 + $0A
	jmp consoleput
kernelpanichigh1
	clc
	adc #$30			; ASCII 0 = $30
        jmp consoleput

} else {
        clc
        adc #$30                        ; ASCII 0 = $30
        cmp #$3a                        ; Is it going to be a-f?
        bmi kernelpanichigh1            ; No = go ahead and send
        clc
        adc #$07                        ; Translate up to alphabet for hex
kernelpanichigh1
        jmp consoleput
}
