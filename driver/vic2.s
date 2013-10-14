; C02 Operating System
; vic2.s: Commodore VIC-II text console driver
; Copyright (C) 2004-2008 by Jody Bruchon


consoleput
        cmp #$0d                ; Carriage return?
        bne vic2noydown         ; No = no new line, yes= new line
vic2ydown
        ldy vic2crsrY           ; Get cursor location
        cpy #24                 ; At line 24 already?
        bne vic2not24           ; No = don't scroll
        jmp vic2scroll
vic2noydown
; This translates ASCII codes to screen codes
        cmp #$20                ; Is code $20 or higher?
        bpl vic2is32            ; Yes = OK
        rts                     ; No = ignore
vic2is32
        cmp #$80                ; Is code $80 or higher?
        bmi vic2is127           ; No = OK
        rts                     ; Yes = ignore
vic2is127
        sec
        sbc #$20                ; Lower A by 32 for lookup
        tax                     ; Use A as lookup index
        lda vic2transtbl,x      ; Load A with new value
        ldx vic2crsrX           ; Get cursor X
        ldy vic2crsrY           ; Get cursor Y
        jsr vic2xyput           ; Put screen code
        jmp vic2crsrinc         ; Increment cursor location

vic2not24
        iny                     ; Increment Y
        sty vic2crsrY
        ldx #$00
        stx vic2crsrX           ; Zero X
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
        sta (zp0),y             ; Store code on screen
        rts

; vic2scroll will make a new line at the end of the screen and push all
; other lines up by one, destroying the last line.

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

        lda #<vic2textll        ; Last line on screen
        sta zp0
        lda #>vic2textll
        sta zp1
        lda #$27                ; $27 = chars 0-39 on the line
        sta zp2
        lda #$20                ; Blank space = 32 = $20
        jsr pagefill
        rts

vic2crsrinc
        lda vic2crsrX           ; Get X
        cmp #$27                ; X at end of line?
        bne vic2cinc1           ; No = just increment and exit
        lda #$00
        sta vic2crsrX           ; Zero X
        lda vic2crsrY           ; Get Y
        cmp #$18                ; Y at end of screen?
        bne vic2cinc2           ; No = just increment Y
        jsr vic2scroll          ; Scroll screen by one line
        rts
vic2cinc1
        inc vic2crsrX           ; Increment X
        rts
vic2cinc2
        inc vic2crsrY           ; Increment X
        rts

vic2transtbl
; This table is missing 32 bytes for non-displayable
; ASCII characters; the table starts at $20 (32)
; $20 (32)
!08 $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
!08 $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
; $40 (64)
!08 $00,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
!08 $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$1b,$1c,$1d,$1e,$1f
; $60 (96)
!08 $27,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
!08 $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$5d,$1d,$7a,$60
; $80 (128) and above are not part of ASCII and will
; not be used in the console driver, though special access
; is planned in the future for raw screen codes.
