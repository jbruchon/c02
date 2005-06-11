; C02 Operating System
; init.s: Kernel initialization
; Copyright (C) 2004, 2005 by Jody Bruchon

init
        sei                     ; Mask off IRQs so we aren't interrupted
        cld                     ; Just in case, clear decimal mode.

!ifdef CONFIG_6502 {
        lda #$00
        sta systemflags         ; Clear all system flags
        sta kbqueue             ; Clear keyboard queue pointers
        sta mutex1              ; Clear Syslib mutex
}
!ifdef CONFIG_65C02 {
        stz systemflags         ; Same as above.
        stz kbqueue
        stz mutex1
}

!src "DRIVER/DRVINIT.S"         ; Per-driver initialization code

!ifdef CONFIG_ARCH_C64 {
        lda #$05                ; Make SURE 6510 keeps I/O banked in!
        sta $01                 ; LORAM+CHAREN=I/O.  CHAREN only=RAM :(
}
!ifdef RAM_AT_FF_PAGE {
        lda #<irq               ; Set NMI vector to irq
        sta $fffa               ; nmivec = $fffa-b
        lda #>irq
        sta $fffb
        lda #<init              ; Set RESET vector to init
        sta $fffc               ; resvec = $fffc-d
        lda #>init
        sta $fffd
        lda #<irq               ; Set IRQ vector to irq (surprise...)
        sta $fffe               ; irqvec = $fffe-f
        lda #>irq
        sta $ffff
}
        ldx #taskspi              ; Task SP inits
        txs
        lda #<taskaddr            ; Task PC inits
        sta ctxpage+taskpc
        lda #>taskaddr
        sta ctxpage+taskpc+1
!ifdef CONFIG_6502 {
        lda #$00                ; Init offset cache to 0
        sta offset
}
!ifdef CONFIG_65C02 {
        stz offset              ; Store offset [Optimized]
}
!ifdef CONFIG_65816EMU {
        stz offset              ; Store offset [Optimized]
}
        lda #$01                ; Set up task counter to start at task 1
        sta task
        lda #tskcnt+1           ; Get the maximum tasks to start running
        sta tasks               ; ...and set the kernel to execute them
        lda #>taskaddr            ; Push task 1 context to stack
        pha                     ; so we can RTI, end up at taskaddr
        lda #<taskaddr            ; and start executing task 1.
        pha
        lda #$20                ; Clear P, except for E bit (for 65816's)
        pha			; Push for task 1.
        rti                     ; Start Task 1!  w00t!
