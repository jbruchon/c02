; Task Scheduler and IRQ Handler
; C02/kernel/6502/sched/init.s
;
; Copyright (C) 2004, 2005 by Jody Bruchon

init
        sei                     ; Mask off IRQs so we aren't interrupted
        lda #$05                ; C64: Make SURE 6510 keeps I/O banked in
        sta $01                 ; C64: LORAM+CHAREN=I/O.  CHAREN only=RAM
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
        ldx #t1spi              ; Task SP inits
        txs
        lda #<t1addr            ; Task PC inits
        sta t1pc
        lda #>t1addr
        sta t1pc+1
        lda #$00                ; Init offset cache to 0
        sta offset
        lda #$01                ; Set up task counter to start at task 1
        sta task
        lda #tskcnt+1           ; Get the maximum tasks to start running
        sta tasks               ; ...and set the kernel to execute them
        lda #>t1addr            ; Push task 1 context to stack
        pha                     ; so we can RTI, end up at t1addr
        lda #<t1addr            ; and start executing task 1.
        pha
        lda #$20                ; Clear P, except for E bit (for 65816's)
        pha			; Push for task 1.
!ifdef CONFIG_ARCH_C64 {
        lda $dc0d               ; C64: Silence the CIA 1 interrupts
        lda $dd0d               ; c64: Silence the CIA 2 interrupts
}
        rti                     ; Start Task 1!  w00t!
