; C02 Operating System
; c64key.s: Commodore 64 keyboard driver
; Copyright (C) 2004, 2005 by Jody Bruchon

; c64keyirqhook is the IRQ hook point for this driver.

c64keyirqhook
        lda #$ff
        sta $dc00               ; Disable all rows for joy #1 check
        cmp $dc01               ; Get row values
        bne c64knojoy           ; If all rows off ($ff) then OK
        rts                     ; Else joy #1 is interfering, so skip.

c64knojoy
!ifdef CONFIG_6502 {
        lda #$00                ; Prescan to see if a key is pressed
        sta $dc00
} else {
        stz $dc00
}

c64kdbounce
        ldx $dc01               ; Get value of prescan
        cpx $dc01               ; Debounce check
        bne c64kdbounce         ; Bad compare = bounce

        cpx #$ff                ; If no key pressed, CIA1 PB = $ff
        bne c64kscn1            ; Uh-oh, keys depressed, start scan.
        lda c64kflags           ; If keys WERE pressed before this scan
        and #$80                ; bit 7 in kflags set = a key was pressed
        bne c64krts             ; If none were pressed, exit scanner.
        lda c64kflags           ; Reload flags
        and #$70                ; Unset bits 7,3,2,1,0 (press/shift flags)
        sta c64kflags           ; Save new flags
c64krts
        rts                     ; No keys pressed = return to IRQ hooks

c64kscn1
        lda #$80
        ora c64kflags           ; Set bit 7 in flags (key pressed)
        sta c64kflags
        lda #$ff                ; Preparation for scan
        ldy #$00
        clc
c64kscn2
        rol                     ; Shift to next row
        sta $dc00
        ldx $dc01               ; Scan row
        cpx #$ff                ; $ff = nothing pressed
        beq c64kcheck           ; Skip to next row
        jsr c64kdecode          ; Decode/queue/mark key
c64kcheck
        iny                     ; Increment row counter for decoder
        cpy #$08                ; Have we passed the last row yet?
        sec                     ; Keep the Carry from mangling scan
        bne c64kscn2            ; No = keep scanning!
        rts                     ; Yes = exit scanner

c64kdecode
        pha                     ; Save accumulator
        sty temp                ; Temporarily save row pointer
        lda #$00                ; Initialize accumulator for count
c64kdec1
        cpy #$00                ; Check Y
        beq c64kdec2            ; If zero, end row multiply
        clc
        adc #$08                ; 8 keys per row
        dey                     ; Decrement row pointer
        jmp c64kdec1            ; Recurse
c64kdec2
        tay                     ; Move A to Y
        txa                     ; Copy key scan location to A
        sec                     ; Set carry for rotation
c64kdec3
        rol                     ; Rotate accumulator
        bcc c64kdec4            ; If C clear, key hit, so finish
        iny                     ; Increment pointer
        bcs c64kdec3            ; Skip back to rotation
c64kdec4
        lda c64kcodes,y         ; Load key to queue from table
        jsr queuekey            ; Queue the key (shifts queue a $00)
        tya                     ; Need to do shift check in A, not Y
        ldx #$00
c64kshift1
        cmp c64kshkeys,x        ; Check current raw key against shifts
        beq c64kshift2          ; If equal, mark a shift
        inx                     ; If not, go to next possibility
        cpx #$04                ; Make sure X isn't past all keys
        bne c64kshift1
        beq c64kexit
c64kshift2
        lda c64kshflags,x       ; Load the flag for the shift key
        ora c64kflags           ; Set the flag
        sta c64kflags           ; Store the flag
c64kexit
        ldy temp                ; Reload saved registers
        pla
        rts                     ; Return to scanner routine

; Below is the ASCII lookup table used by the decoder

c64kcodes

!08 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0-15
!08 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 16-31
!08 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 32-47
!08 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 48-63

; This table contains the shift scan+flag data

c64kshkeys
; Keys
!08 $08,$33,$3A,$3D             ; left-sh,right-sh,cmdr,ctrl
c64kshflags
; Flags
!08 $01,$01,$04,$02             ; shift,shift,cmdr(alt),ctrl
