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
        jsr consoleget          ; Get from console
        jmp getcharexit         ; Unset mutex and return

getcharexit
        tax                     ; Save A
        lda #getcharM           ; Get mutex byte
        eor #$ff                ; Invert bit mask
        and mutex1              ; Clear mutex bit in mutex byte
        sta mutex1              ; Store mutex byte
        txa                     ; retrieve A
        rts

; consoleget will perform the queue retrieval and pointer update
consoleget
        clc
        ldx kbqueueA            ; Load keyboard queue start
        cpx kbqueueB            ; Check against queue end
        bne kbqnotnull          ; Non-zero = get char
        lda #$00                ; Zero = send a null char back
        rts
kbqnotnull
        ldx kbqueueA            ; Load queue ring start pointer
        lda kbqueue,x           ; Load character from queue
        inx
        cpx kbqueuelen          ; Check start ring pointer against ring top
        beq kbqringwrap         ; If overflowing, wrap pointer to $00
        stx kbqueueA            ; Increment ring start pointer
        rts
kbqringwrap
!ifdef CONFIG_6502 {
        ldx #$00
        stx kbqueueA           ; Zero the ring pointer
}
!ifdef CONFIG_65C02 {
        stz kbqueueA           ; Zero the ring pointer [Optimized]
}
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
        clc
        ldx kbqueueB            ; Get queue end pointer
        inx                     ; Increment pointer for compare
        cpx kbqueueA            ; Check if queue is full
        beq kbqueuedone         ; If maxed, drop key
        dex                     ; Return pointer to previous value
        sta kbqueue,x           ; Store byte in queue
        inx
        cpx #kbqueuelen         ; Check end pointer against queue end
        bne kbqueuedone         ; If not at end, return
        ldx #$00
kbqueuedone
        stx kbqueueB            ; Store new end pointer
        rts


; ***ERROR CODES***

devnumfailure
        lda #$01                ; Error code $01 = "Device number unknown"
        sec                     ; Carry set = error occurred.
        rts

resourcelocked
        lda #$02                ; Error code $02 = "Resource in use"
        sec
        rts
