; C02 Operating System
; vic2.s: Commodore VIC-II text console driver
; Copyright (C) 2004, 2005 by Jody Bruchon

; Currently just a dummy to allow build to work

consoleput
        cmp #$0d                ; Carriage return?
        beq vic2ydown           ; Yes = new line

vic2ydown
        ldx vic2crsrY           ; Get cursor location
        cmp #24                 ; At line 24 already?
        bne vic2not24           ; No = don't scroll
        jsr vic2scroll
vic2not24
        iny                     ; Increment Y
        sty vic2crsrY
        rts

; vic2xyput puts the screen code specified into the specified X and Y
; locations (starting at 0,0) on the text console.  Load A with the value
; to place, X and Y with the screen location to put the character in.

vic2xyput
        pha                     ; Save value
        sty zp1                 ; Pass multiplier to multiply8
        txa
        pha                     ; Save offset from multiplier
        ldx #$28                ; 40 characters per line
        jsr multiply8           ; Do the multiply
        lda zp1                 ; Load high byte
        adc #>vic2text          ; Add in VIC-II text base high byte
        sta zp1                 ; Save changes to vector
        pla                     ; Pull offset
        tay                     ; Use offset as index
        pla                     ; Get code to put on screen
        sta (zp1),y             ; Store code on screen
        rts

; vic2scroll will make a new line at the end of the screen and push all
; other lines up by one, destroying the first line.

vic2scroll
        lda #<vic2text+40       ; Prepare to push screen data up
        sta zp0
        lda #>vic2text+40
        sta zp1
        lda #<vic2text
        sta zp2
        lda #>vic2text
        sta zp3
        lda #$ff                ; 256 bytes at a time
        sta zp4
        jsr pagemove            ; Move first page

        inc zp1
        inc zp3
        jsr pagemove            ; Move second page

        inc zp1
        inc zp3
        jsr pagemove            ; Move third page

        inc zp1
        inc zp3
        lda #$bf                ; Don't go beyond the screen!
        sta zp4
        jsr pagemove            ; Move last page

        lda #<vic2text+960      ; Last line on screen
        sta zp0
        lda #>vic2text+960
        sta zp1
        lda #$20                ; Blank space = 32 = $20
        jsr pagefill

        rts
