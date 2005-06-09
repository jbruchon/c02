; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004, 2005 by Jody Bruchon

; See API documentation for high-level details on using Syslib.

syslibstart

; getchar will attempt to retrieve a character from the specified input.
; *SYSCALL*
getchar
; mutex
        lda mutex1              ; Load mutex byte
        and #getcharM           ; Check getchar mutex bit
        beq getcharMok          ; If zero, mutex unset so continue
        jmp resourcelocked      ; Set mutex = resource locked
getcharMok
        lda getcharM            ; Load the bit for the getchar mutex
        ora mutex1              ; Set getchar mutex bit in mutex byte
        sta mutex1              ; Store new mutex byte
; endmutex
        cpx #$00                ; $00 = console
        beq consoleinput
        jmp devnumfailure       ; Failed compares, put error

consoleinput
        jsr consoleget          ; Get char from console
getcharexit
        tax                     ; Save A
; mutex
        lda #getcharM           ; Get mutex byte
        eor #$ff                ; Invert bit mask
        and mutex1              ; Clear mutex bit in mutex byte
        sta mutex1              ; Store mutex byte
; endmutex
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
        beq consoleoutput
        jmp devnumfailure       ; Failed compares, put error

consoleoutput
        jsr consoleput
        jmp putcharworked
putcharworked
        clc
        rts

; queuekey adds a byte to the keyboard queue and updates queue pointers
; *SYSCALL*
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

; (un)criticalsection enables/disables task switching for protection of
; a program's critical section.
; *SYSCALL*
criticalsection
        lda #criticalflag       ; Get bit mask
        ora systemflags         ; Disable scheduler
        sta systemflags         ; Store new flags
        rts

; *SYSCALL*
uncriticalsection
        lda #criticalflag       ; Get bit mask
        eor #$ff                ; Invert bit mask
        and systemflags         ; Apply mask to flags
        sta systemflags         ; Store new flags
        rts

; multiply8 provides an 8-bit multiply
; *SYSCALL*
multiply8
        sei                     ; Do not interrupt after this point
        sty mpybyte1            ; Store multiplicand
!ifdef CONFIG_6502 {
        lda #$00
        sta mpybyte0            ; Init result
} else {
        stz mpybyte0            ; Init result [Optimized]
}
        ldy #$07                ; Init multiplier loop
multiply8loop
        asl mpybyte0            ; Shift low byte left
        rol mpybyte1            ; Shift high byte left
        bcc multiply8noc        ; No carry = loop around
        clc
        txa                     ; Move multiplier into A
        adc mpybyte0            ; Add multiplier to result
        sta mpybyte0            ; Store new low byte
        lda mpybyte1            ; Load high byte
        adc #$00                ; Add carry (if any) to high byte
        sta mpybyte1            ; Store new high byte
multiply8noc
        dey                     ; Decrement counter
        bne multiply8loop       ; If not zero, do again
        ldy mpybyte0            ; Return low byte in Y
        ldx mpybyte1            ; Return high byte in X
        cli                     ; Unlock interrupts
        rts                     ; Return to program

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

