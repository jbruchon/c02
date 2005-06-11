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
        lda #getcharM           ; Load the bit for the getchar mutex
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
        lda #255-getcharM       ; Load inverted mutex bit mask
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
; mutex
        lda mutex1              ; Load mutex
        and #kbqueueM           ; Check mutex
        beq kbqueueMok          ; If zero, continue
        jmp resourcelocked      ; Set mutex = resource locked
kbqueueMok
        lda #kbqueueM           ; Load mutex
        ora mutex1              ; Set mutex bit
        sta mutex1              ; Store new mutex byte
; endmutex
        ldx kbqueue             ; Get current queue pointer
        inx
        cpx #kbqueuelen         ; Check against max length
        beq queuekeyfull        ; If full, drop key
        sta kbqueue,x           ; Store key
        stx kbqueue             ; Store pointer
; mutex
        lda #255-kbqueueM       ; Get mutex byte
        and mutex1              ; Clear mutex bit in mutex byte
        sta mutex1              ; Store mutex byte
; endmutex
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
        lda #255-criticalflag   ; Get bit mask
        and systemflags         ; Apply mask to flags
        sta systemflags         ; Store new flags
        rts

; multiply8 provides an 8-bit multiply
; *SYSCALL*
multiply8
        sei                     ; Do not interrupt after this point
        sty zp1                 ; Store multiplicand
!ifdef CONFIG_6502 {
        lda #$00
        sta zp0                 ; Init result
} else {
        stz zp0                 ; Init result [Optimized]
}
        ldy #$07                ; Init multiplier loop
multiply8loop
        asl zp0                 ; Shift low byte left
        rol zp1                 ; Shift high byte left
        bcc multiply8noc        ; No carry = loop around
        clc
        txa                     ; Move multiplier into A
        adc zp0                 ; Add multiplier to result
        sta zp0                 ; Store new low byte
        lda zp1                 ; Load high byte
        adc #$00                ; Add carry (if any) to high byte
        sta zp1                 ; Store new high byte
multiply8noc
        dey                     ; Decrement counter
        bne multiply8loop       ; If not zero, do again
        ldy zp0                 ; Return low byte in Y
        ldx zp1                 ; Return high byte in X
        cli                     ; Unlock interrupts
        rts                     ; Return to program

; blockmove(down/up) move memory down or up

; *SYSCALL*
blockmovedown
        ldy #$00
blockdownloop
        lda (zp2),y             ; Load data byte
        sta (zp0),y             ; Store data in destination
        lda zp2                 ; Load data start low
        cmp zp4                 ; Compare to data start low
        beq blockdownchk        ; If equal, check high too
blockdownok
        inc zp0                 ; Increment dest start low byte
        bne blockdown1          ; If dest start = 0 don't inc high
        inc zp1                 ; Otherwise increment high
blockdown1
        inc zp2                 ; Increment data start low byte
        bne blockdown2          ; If low byte non-zero, don't inc high
        inc zp3                 ; Otherwise inc high
blockdown2
        jmp blockdownloop       ; Loop until done
blockdownchk
        lda zp3                 ; Load data start high
        cmp zp5                 ; Compare against data end high
        bne blockdownok         ; If not equal, return to loop
        rts

; *SYSCALL*
blockmoveup
        ldy #$00                ; Initialize index (only want indirection)
blockuploop
        lda (zp2),y             ; Load data byte
        sta (zp0),y             ; Store data in destination
        lda zp2                 ; Get data end low byte
        cmp zp4                 ; Compare against data start low
        beq blockupchk          ; If equal, possibly done, so check
blockupok
        lda zp0                 ; Get data dest. end low
        bne blockup1            ; if zp0 not 0, don't dec high byte
        dec zp1                 ; Otherwise decrement high byte
blockup1
        dec zp0                 ; Decrement data dest. end low byte
        lda zp2                 ; Load data end low byte
        bne blockup2            ; If not 0, don't dec data end high
        dec zp3                 ; Decrement data end high byte
blockup2
        dec zp2                 ; Decrement data end low byte
        jmp blockuploop         ; Loop until zp2/3 = zp4/5
blockupchk
        lda zp3                 ; Load data end high byte
        cmp zp5                 ; Check against data start high
        bne blockupok           ; If not equal, return to loop
        rts

; *SYSCALL*
pagefill
        ldy #$00                ; Init counter to zero
pagefillloop
        sta (zp0),y             ; Store fill byte
        cpy zp2                 ; Last byte reached?
        beq pagefilldone        ; If so, end fill
        iny                     ; If not, move to next byte
        bne pagefillloop        ; and loop until done
pagefilldone
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

