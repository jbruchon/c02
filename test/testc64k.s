; C02 Operating System
; testc64k.s: Initial task that spits out queued keys in hex
; Copyright (C) 2004-2008 by Jody Bruchon

beginning
        ldx #$00
        jsr getchar
        cmp #$00
        beq beginning
        
        jsr byte2asciihex
        lda zp0
        ldx #$00
        jsr putchar
        lda zp1
        ldx #$00
        jsr putchar
        jmp beginning


byte2asciihex
        pha

byte2asciihexhigh
        and #$f0                        ; Cut low nybble out
        lsr                             ; Translate high down to low
        lsr
        lsr
        lsr
        clc
        adc #$30                        ; ASCII 0 = $30
        cmp #$3a                        ; Is it going to be a-f?
        bmi byte2asciihexhigh1          ; No = go ahead and send
        clc
        adc #$07                        ; Translate up to alphabet for hex
byte2asciihexhigh1
        sta zp0                         ; Send out nybble hex value

byte2asciihexlow
        pla
        and #$0f                        ; Cut high nybble out
        clc
        adc #$30                        ; ASCII 0 = $30
        cmp #$3a                        ; Is it going to be a-f?
        bmi byte2asciihexlow1           ; No = go ahead and send
        clc
        adc #$07                        ; Translate up to alphabet for hex
byte2asciihexlow1
        sta zp1                         ; Send out nybble hex value
        rts

