; C02 Operating System
; c64key.s: Commodore 64 keyboard driver
; Copyright (C) 2004-2008 by Jody Bruchon

; c64keyirqhook is the IRQ hook point for this driver

c64kshrow
!08 $01,$06,$07,$07,$0a
c64kshbit
!08 $80,$10,$20,$04,$01
c64kshflag
!08 $01,$01,$02,$04,$08

!src "driver/c64kcode.s"

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

; At this point, we only need to decode the scan code + flags into a real
; key value.

c64kfinish
        ldx c64ktemp2           ; Load resultant scancode
        lda c64kflags           ; Load key flags
        and #$01                ; Check for [SHIFT]
        beq c64kfinish1         ; No shift = next check
        txa
        clc
        adc #$40                ; Add $40 to scancode for [SHIFT]
        tax
c64kfinish1
        lda c64kflags           ; Load key flags
        and #$02                ; Check for [CTRL]
        beq c64kfinish2         ; No control = stop checking
        lda #$80                ; [CTRL] scancode
        jmp queuekey
c64kfinish2
        lda c64kcodetbl,x       ; Load proper key from table
        jmp queuekey            ; Queue the key and exit hook

; -- end IRQ hook main section

c64knokeys
        lda #$ff
c64knokeys1
        sta c64koldkeys,x       ; Clear out old pressed keys entirely
        dex
        bpl c64knokeys1
        lda c64kflags
        and #%11110000          ; Clear out shift flags
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
;        jsr c64kdebounce
        eor #$ff                ; Invert result to a "nicer" number
        sta c64kscantbl,x       ; Store inverted result to scan table
        sec                     ; Make sure no zeroes are introduced
        rol temp                ; Change scanning row
        inx                     ; Increment scan table location
        cpx #$08                ; Done with scanning for all rows?
        bne c64kscan1           ; No = keep scanning!
        rts

c64kshifts
        ldy #$04                ; Filter shift keys out for flagging
c64kshifts1
        ldx c64kshrow,y         ; Load the shift key's row
        lda c64kscantbl,x       ; Load the scan value for that row
        and c64kshbit,y         ; Check against bit for shift key
        beq c64kshifts2         ; If bit unset, no shift present
        lda c64kshflag,y        ; Load flag value for this key
        ora c64kflags           ; Turn on corresponding key flag
        sta c64kflags
        lda c64kshbit,y         ; Load bit for this shift key
        eor #$ff                ; Invert to make removal mask
        and c64kscantbl,x       ; Remove shift bit from scan table
        sta c64kscantbl,x
c64kshifts2
        dey                     ; Decrement counter
        bpl c64kshifts1         ; If counter not 255, then go again
        rts

c64kdecode
        ldx #$02                ; Clear out new key list
        lda #$ff
c64kdecode1
        sta c64knewkeys,x       ; Wipe out key
        dex
        bpl c64kdecode1         ; Keep clearing until done
        ldy #$00
        sty temp                ; Initialize temporary locations
        ldx #$00
        stx c64ktemp2
c64kdecnext
        lda c64kscantbl,x       ; Load scan table value
        beq c64kdecode5         ; If zero, skip this row
        ldy c64ktemp2           ; Load scancode
c64kdecode2
        lsr                     ; Shift data right
        bcc c64kdecode4         ; If bit is zero, no key here
        pha                     ; Save A
        stx c64ktemp            ; Save current scan offset
        ldx temp
        cpx #$03                ; Has count exceeded 3 keys?
        bcs c64kdecode3         ; Yes = don't save new key
        tya
        sta c64knewkeys,x       ; Save new key code
        inc temp                ; Increment key counter
c64kdecode3
        ldx c64ktemp            ; Restore scan offset
        pla                     ; Restore A for next shift
c64kdecode4
        iny                     ; Increment scancode by 1
        cmp #$00                ; All columns checked yet?
        bne c64kdecode2         ; No = do it again
c64kdecode5
        lda c64ktemp2           ; Load scancode
        clc
        adc #$08                ; Add $08 (per-row multiply)
        sta c64ktemp2
        inx                     ; Set to scan next row
        cpx #$08                ; Done?
        bne c64kdecnext         ; No = scan again
        rts

c64kcheck
        ldy #$00
c64kcheck1
        lda c64koldkeys,y       ; Get current old key
        cmp #$ff                ; Is it actually a key?
        beq c64kcheck5          ; No = don't decode the thing
        ldx #$02                ; Yes = search for it new keys
c64kcheck2
        cmp c64knewkeys,x       ; Load new key
        beq c64kcheck4          ; If matching, key is still held
        dex
        bpl c64kcheck2          ; Otherwise, keep looking
        tya                     ; Not found = old key no longer down
        tax
c64kcheck3
        lda c64koldkeys+1,x     ; Drop old key from old key list
        sta c64koldkeys+0,x
        inx
        cpx #$02
        bcc c64kcheck3          ; If not done, continue shifting
        lda #$ff
        sta c64koldkeys+2       ; Clear out last old key value
c64kcheck4
        iny                     ; Check next old key
        cpy #$03                ; Done?
        bcc c64kcheck1          ; No = check next
c64kcheck5
        ldy #$00
c64kchkinsert
        lda c64knewkeys,y       ; Get current new key
        cmp #$ff
        beq c64kcheck9          ; If not a key, stop now.
        ldx #$02                ; Otherwise, check old keys for it
c64kcheck6
        cmp c64koldkeys,x
        beq c64kcheck8
        dex
        bpl c64kcheck6
        pha                     ; If not old key, insert at front of new
        ldx #$01
c64kcheck7
        lda c64koldkeys+0,x
        sta c64koldkeys+1,x
        dex
        bpl c64kcheck7
        pla
        sta c64koldkeys+0
        ldy #$03                ; Force exit
c64kcheck8
        iny
        cpy #$03
        bcc c64kchkinsert
c64kcheck9
        rts

c64kdebounce
        lda c64kportb
        cmp c64kportb
        bne c64kdebounce
        rts
