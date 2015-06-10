; C02 Operating System
; char.s: Character I/O functions
; Copyright (C) 2004-2008 by Jody Bruchon

; -----------------------------------
; getchar will attempt to retrieve a character from the specified input.

getchar
; lock
        lda lock1               ; Load lock byte
        and #getcharL           ; Check getchar lock bit
        beq getcharLok          ; If zero, lock unset so continue
        jmp resourcelocked      ; Set lock = resource locked
getcharLok
        lda #getcharL
        ora lock1               ; Set getchar lock bit
        sta lock1
; endlock
        cpx #$00                ; $00 = console
        beq consoleinput
        jmp devnumfailure       ; Failed compares, put error

consoleinput
        jsr consoleget          ; Get char from console
getcharexit
        tax                     ; Save A
; lock
        lda #255-getcharL       ; Load inverted lock bit mask
        and lock1               ; Clear lock bit
        sta lock1
; endlock
        txa                     ; retrieve A
        clc
        rts
; consoleget does queue retrieval and pointer update
consoleget
        clc
        ldx kbqueue             ; Load keyboard queue pointer
        bne kbqnotnull          ; Non-zero = get char
        lda #$00                ; Zero = send a null char back
        clc
        rts
kbqnotnull
        lda kbqueue+1           ; Load character from queue
        pha
        cpx #$01
        beq kbqnocycle          ; <2 = no cycling
        ldx #$01                ; Prepare to move buffer backwards
        ldy #$00
kbqcycle
        inx
        iny
        lda kbqueue,x           ; Load char
        sta kbqueue,y           ; Move back 1 space
        cpx kbqueue             ; Check Y against current queue end
        bne kbqcycle
kbqnocycle
        dec kbqueue             ; Decrement pointer
        pla                     ; Restore value
        rts

; -----------------------------------
; putchar attempts to send a character to the specified output device.

putchar
        cpx #$00                ; $00 = console
        beq putchardev0
        jmp devnumfailure       ; Failed compares, put error

putchardev0
        jsr consoleput
putcharworked
        clc
        rts

; -----------------------------------
putstring
        ldy #$00                        ; Counter for message printing
putstring1
        lda (zp0),y                     ; Grab next char from message
        sty zp2                         ; Save counter
        sta zp3                         ; Save character for compare
        jsr putchar                     ; Send to the console
        bcc putstring2                  ; If carry clear, all is well
        rts                             ; If carry set, pass error on
putstring2
        lda zp3                         ; Load a null into A for compare
        beq putstring3                  ; If equal, finish up
        ldy zp2                         ; Restore counter value
        iny                             ; Increment counter
        bne putstring1                  ; Do it again until done
putstring3
        rts

; -----------------------------------
; queuekey adds a byte to the keyboard queue and updates queue pointers

queuekey
        tax                     ; Save the key
; lock
        lda lock1               ; Load lock
        and #kbqueueL           ; Check lock
        beq kbqueueLok          ; If zero, continue
        jmp resourcelocked      ; Set lock = resource locked
kbqueueLok
        lda lock1               ; Load lock
        ora #kbqueueL           ; Set lock bit
        sta lock1               ; Store new lock byte
; endlock
        txa
        ldx kbqueue             ; Get current queue pointer
        inx
        cpx #kbqueuelen         ; Check against max length
        beq queuekeyfull        ; If full, drop key
        sta kbqueue,x           ; Store key
        stx kbqueue             ; Store pointer
; lock
        lda lock1               ; Get lock byte
        and #255-kbqueueL       ; Clear lock bit in lock byte
        sta lock1               ; Store lock byte
; endlock
        clc
        rts
queuekeyfull
        jmp bufferfull          ; Oops!

; -----------------------------------
; Convert a byte to two ASCII hexadecimal digits

byte2hex
        lda zp0
byte2hexhigh
        lsr                             ; Translate high down to low
        lsr
        lsr
        lsr
        clc
        adc #$30                        ; ASCII 0 = $30
        cmp #$3a                        ; Is it going to be a-f?
        bmi byte2hexhigh1               ; No = go ahead and send
        clc
        adc #$07                        ; Translate up to alphabet for hex
byte2hexhigh1
        sta zp1
        lda zp0
        and #$0f                        ; Cut high nybble out
        clc
        adc #$30                        ; ASCII 0 = $30
        cmp #$3a                        ; Is it going to be a-f?
        bmi byte2hexlow1                ; No = go ahead and send
        clc
        adc #$07                        ; Translate up to alphabet for hex
byte2hexlow1
        sta zp2
        clc
        rts
