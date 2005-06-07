; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004, 2005 by Jody Bruchon

; This library allows programs to be somewhat ignorant of the actual
; kernel configuration and drivers.

syslibstart

; getchar will attempt to retrieve a character from the specified input.
; If no character is present, it will return with the carry flag set.
; Pass the requested input device in X, and the data byte will be returned
; in A.
; Uses:  A, X, C

getchar
        lda mutex1              ; Load mutex byte
        and #getcharM            ; Check getchar mutex bit
        beq getcharMok          ; If zero, mutex unset so continue
        jmp resourcelocked      ; Set mutex = resource locked

getcharMok
        lda getcharM            ; Load the bit for the getchar mutex
        ora mutex1              ; Set getchar mutex bit in mutex byte
        sta mutex1              ; Store new mutex byte
        cpx #$00                ; $00 = console
        beq consoleinput
        jmp devnumfailure       ; Failed compares, put error

consoleinput
        jsr consoleget          ; Get char from console
getcharexit
        tax                     ; Save A
        lda #getcharM           ; Get mutex byte
        eor #$ff                ; Invert bit mask
        and mutex1              ; Clear mutex bit in mutex byte
        sta mutex1              ; Store mutex byte
        txa                     ; retrieve A
        rts

; consoleget will perform queue retrieval and pointer update
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

; putchar will attempt to send a character to the specified output device.
; Pass the device in X and the data to send in A.  C set = error.
; Error code will be in A.
; Uses:  A, X, Y, C

putchar
        cpx #$00                ; $00 = console
        beq consoleoutput
        jmp devnumfailure       ; Failed compares, put error

consoleoutput
        jsr consoleput
        jmp putcharworked
putcharworked
        clc
        rts

; queuekey adds a byte to the keyboard queue and updates queue pointers
; Put the byte you want to queue in A first!

queuekey
        ldx kbqueue             ; Get current queue pointer
        inx
        cpx #kbqueuelen         ; Check against max length
        beq queuekeyfull        ; If full, drop key
        sta kbqueue,x           ; Store key
        stx kbqueue             ; Store pointer
        clc
        rts
queuekeyfull
        jmp bufferfull          ; Oops!

; criticalsection will disable the scheduler before entering a
; critical section.  uncriticalsection will reverse the process.
; This is highly preferred over doing sei/cli in your program!!!

criticalsection
        lda #criticalflag       ; Get bit mask
        ora systemflags         ; Disable scheduler
        sta systemflags         ; Store new flags
        rts

uncriticalsection
        lda #criticalflag       ; Get bit mask
        eor #$ff                ; Invert bit mask
        and systemflags         ; Apply mask to flags
        sta systemflags         ; Store new flags
        rts

; ***ERROR CODES***

devnumfailure
        lda #$01                ; Error code $01 = "Device number unknown"
        sec                     ; Carry set = error occurred.
        rts

resourcelocked
        lda #$02                ; Error code $02 = "Resource in use/locked"
        sec
        rts

bufferfull
        lda #$03                ; Error code $03 = "Buffer is full"
        sec
        rts

