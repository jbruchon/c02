; Task 2 for kernel demo

.org $7000

; init here will set up the pointer that is used by tasks to write to the
; VIC-II text-mode screen.  $0400-$07e7 is the range of this pointer.

; The kernel needs a lock to suppress IRQs during operations on shared
; memory locations without programs actually masking interrupts.
; It would be handy if the kernel had a race-condition lock byte that
; overrides any IRQ lock set by a program after a certain amount of
; failures to release the lock by the next IRQ time and return control
; as specified by the lock status.
; I hate developing APIs...

init
        lda #$00
        sta $fe
        lda #$04
        sta $ff

drawloop
        ldx $fe                 ; Get the contents of the screen vector
        ldy $ff
        sei                     ; MESSY WORKAROUND: Don't Interrupt!
        cpx #$ff                ; Are we at the end of a memory page?
        bne nopage              ; No: skip to the low vector increment code
        ldx #$00                ; Yes: increment high vector and zero low
        stx $fe                 ;      to wrap to next page.
        iny                     ; Increment Y will never be zero...
        sty $ff
        bne page                ; ...so bne will never fail to branch :)

; Note that X (our index) is zeroed if we wrap around a page...

nopage
        inx                     ; No wrap-around to next page?  Great!
        stx $fe                 ; Increment low vector...
        ldx #$00                ; ...and zero the index for consistency.

page
        lda #$02                ; $02 = "B"
        sta ($fe,x)             ; Store "B" in the vector's location
        ldx $fe                 ; Get the vector low back
        cpx #$e7                ; Possible end of screen memory?
        beq chkend              ; Yes: Check to make sure $07e7 not hit
        bne delay               ; No: Move ahead to the delay loop

chkend
        cpy #$07                ; Is it the end of memory or not?!
        bne delay               ; No: Move ahead to the delay loop
        lda #$04                ; Write $0400 to the vector
        sta $ff
        lda #$00
        sta $fe

delay
        cli                     ; MESSY WORKAROUND: Allow interrupts again!
        ldx #$63                ; Sir Loop-A-Lot Arrives!
delay1
        cpx #$00                ; X=0?
        beq exitdelay           ; Yes: don't delay anymore!
        dex                     ; Decrement loop counter
        nop                     ; What a way to burn 2550 clock cycles.
        nop                     ; 1 million cycles per second / 2550 =
        nop                     ; 390 NOP-loops per second, X ops excluded.
        nop                     ; Not that anyone cares.  Hmph.
        nop                     ; This delay makes sure we don't flood the
        lda #$00
        beq delay1
exitdelay
        jmp drawloop            ; screen too fast.  Wonder if it works...

