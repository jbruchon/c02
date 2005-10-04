; C02 Operating System
; char.s: Character I/O functions
; Copyright (C) 2004, 2005 by Jody Bruchon

; getchar will attempt to retrieve a character from the specified input.
; *SYSCALL*
getchar
; lock
        lda lock1               ; Load lock byte
        and #getcharL           ; Check getchar lock bit
        beq getcharLok          ; If zero, lock unset so continue
        jmp resourcelocked      ; Set lock = resource locked
getcharLok
        lda #getcharL           ; Load the bit for the getchar lock
        ora lock1               ; Set getchar lock bit in lock byte
        sta lock1               ; Store new lock byte
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
        and lock1               ; Clear lock bit in lock byte
        sta lock1               ; Store lock byte
; endlock
        txa                     ; retrieve A
        rts
; consoleget does queue retrieval and pointer update
consoleget
        clc
        ldx kbqueue             ; Load keyboard queue pointer
        bne kbqnotnull          ; Non-zero = get char
        lda #$00                ; Zero = send a null char back
        rts
kbqnotnull
        lda kbqueue+1           ; Load character from queue
        pha                     ; Temporarily save
        cpx #$01                ; Are there two or more keys in queue?
        beq kbqnocycle          ; <2 = no cycling
        ldx #$01                ; Prepare to move buffer backwards
        ldy #$00
kbqcycle
        inx
        iny
        lda kbqueue,x           ; Load char
        sta kbqueue,y           ; Move back 1 space
        cpx kbqueue             ; Check Y against current queue end
        bne kbqcycle            ; If not done, recurse
kbqnocycle
        dec kbqueue             ; Decrement pointer
        pla                     ; Restore value
        rts

; putchar attempts to send a character to the specified output device.
; *SYSCALL*
putchar
        cpx #$00                ; $00 = console
        beq putchardev0
        jmp devnumfailure       ; Failed compares, put error

putchardev0
        jsr consoleput
        jmp putcharworked
putcharworked
        clc
        rts

; *SYSCALL*
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
        lda #$00                        ; Load a null into A for compare
        cmp zp3                         ; Check against character
        beq putstring3                  ; If equal, finish up
        ldy zp2                         ; Restore counter value
        iny                             ; Increment counter
        jmp putstring1                  ; Do it again until done
putstring3
        rts

; queuekey adds a byte to the keyboard queue and updates queue pointers
; *SYSCALL*
queuekey
; lock
        lda lock1               ; Load lock
        and #kbqueueL           ; Check lock
        beq kbqueueLok          ; If zero, continue
        jmp resourcelocked      ; Set lock = resource locked
kbqueueLok
        lda #kbqueueL           ; Load lock
        ora lock1               ; Set lock bit
        sta lock1               ; Store new lock byte
; endlock
        ldx kbqueue             ; Get current queue pointer
        inx
        cpx #kbqueuelen         ; Check against max length
        beq queuekeyfull        ; If full, drop key
        sta kbqueue,x           ; Store key
        stx kbqueue             ; Store pointer
; lock
        lda #255-kbqueueL       ; Get lock byte
        and lock1               ; Clear lock bit in lock byte
        sta lock1               ; Store lock byte
; endlock
        clc
        rts
queuekeyfull
        jmp bufferfull          ; Oops!

