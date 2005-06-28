; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004, 2005 by Jody Bruchon

; See API documentation for high-level details on using Syslib.

syslibstart

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

; (un)criticalsection enables/disables task switching for protection of
; a program's critical section.
; *SYSCALL*
!ifdef CONFIG_ADV_NO_CRITICAL {} else {
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
}

; multiply8 provides an 8-bit multiply
; *SYSCALL*
multiply8
!ifdef CONFIG_6502 {
        lda #$00
        sta zp0                 ; Init result
} else {
        stz zp0                 ; Init result [Optimized]
}
        ldy #$08                ; Init multiplier loop
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

; *SYSCALL*
pagemove
        lda zp3                 ; Get dest. high byte
        cmp zp1                 ; Check against start high
        bmi pagemovedown        ; If dest below start, move down
        beq pagemovelows        ; If equal, check low bytes to decide
        bne pagemoveup          ; If greater, move up
pagemovelows
        lda zp2                 ; Get dest. low
        cmp zp0                 ; Check against start low
        bmi pagemovedown        ; If less, move down
        bne pagemoveup          ; If not equal (greater), move up
        rts                     ; Otherwise, start=dest so ignore call!

pagemovedown
        ldy #$00                ; Init index
        ldx zp4                 ; Init counter
pagemovedownloop
        lda (zp0),y             ; Load data byte
        sta (zp2),y             ; Copy data byte
        cpx #$00                ; Is counter at zero?
        beq pagemovedown1       ; Yes = done
        iny                     ; Increment index
        dex                     ; Decrement counter
        jmp pagemovedownloop    ; Loop until done
pagemovedown1
        rts

pagemoveup
        ldy zp4                 ; Init index/counter
pagemoveuploop
        lda (zp0),y             ; Load data byte
        sta (zp2),y             ; Save data byte
        cpy #$00                ; Is counter at zero?
        beq pagemoveup1         ; Yes = done
        dey                     ; Decrement index/counter
        jmp pagemoveuploop      ; Loop until done
pagemoveup1
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

