; C02 Operating System
; memory.s: Memory manipulation functions
; Copyright (C) 2004-2008 by Jody Bruchon

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
