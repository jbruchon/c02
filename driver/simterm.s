; C02 Operating System
; simterm.s: Daryl Rictor's 65C02 Simulator terminal driver
; Copyright (C) 2004-2008 by Jody Bruchon

; simtermirqhook is the IRQ hook point for this driver.

simtermin = $8000
simtermstb = $8001
simtermout = $8010

; The IRQ hook will try to get a character but will not wait

simtermirqhook
        lda simtermin           ; Get character
        bmi simtermchr          ; If bit 7 not set, ignore
        rts
simtermchr
        sta simtermstb          ; Otherwise, acknowledge receipt of char
        and #$7f                ; Strip bit 7 to get clean ASCII
        jmp queuekey            ; Queue the key

; To use simtermout, put the ASCII char in A to be output and jsr simtermout

simtermsend
consoleput
        cmp #$0d                ; CR must -> CR+LF to behave properly
        bne consoleput0d        ; If not CR, continue
        sta simtermout          ; otherwise, make it behave
        lda #$0a
consoleput0d
        sta simtermout          ; Output character
        rts
