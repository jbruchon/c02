; Task Scheduler and IRQ Handler
; C02/kernel/65c02/sched/irq.s
;
; Copyright (C) 2004, 2005 by Jody Bruchon

irq
        phx                     ; Save X [Optimized]

; If maxtsk is too high, the kernel will crash out
; irqsav will save all of the context information for the task that
; is being pre-empted, increment the task counter, and do a bounds
; check on the task number, recycling to 1 if tasks has been exceeded.
; irqsav also checks the offset cache for overflow and re-inits if so.

irqsav
        ldx offset              ; Load the offset cache
        sty t1y,x               ; Store Y
        sta t1a,x               ; Store A [Optimized]
        pla                     ; Pull X
        sta t1x,x               ; Store X
        pla                     ; Pull P (IRQ stored)
        sta t1p,x               ; Store P
        pla                     ; Pull PC low byte
        sta t1pc,x              ; Store PC low
        pla                     ; Pull PC high
        sta t1pc+1,x            ; Store PC high
        stx temp                ; Save index
        tsx                     ; Get current SP
        txa                     ; Save SP elsewhere
        ldx temp                ; Restore index
        sta t1sp,x              ; Save SP
        clc                     ; Carry bit can kill our addition...
        lda offset              ; Retrieve the offset cache
        adc #$07                ; Increment offset cache by 7
        bcc addokay             ; If the carry bit isn't set, OK.
        jmp init                ; Carry bit set = too many tasks
addokay
        ldx task                ; Load task number
        inx                     ; Increment task number by 1
        cpx tasks               ; Compare with running task counter
        bne irqtsk              ; If not at max, proceed normally
        lda #$00                ; Reset offset cache to 0
        ldx #$01                ; Reset task number to 1

; All irqtsk does is provide a skip point to jump over the code
; that resets the task counter to 1 and the offset cache to 0

irqtsk
        sta offset              ; Save offset cache
        stx task                ; Save task number

; irqload performs the loading of the context from zero-page memory
; and returns from the interrupt to the next task

irqload
        tax                     ; Load new offset index
        lda t1sp,x              ; Load SP
        tax                     ; Prepare SP for change
        txs                     ; Change SP
        lda offset              ; Restore clobbered offset index
        lda t1pc+1,x            ; Load PC high
        pha                     ; Push PC high
        lda t1pc,x              ; Load PC low
        pha                     ; Push PC low
        lda t1p,x               ; Load P
        pha                     ; Push P
        lda t1a,x               ; Load A
        pha                     ; Temporarily save A
        ldy t1y,x               ; Load Y
        lda t1x,x               ; Load X with A
        tax                     ; Move X's value from A into X
        pla                     ; Load A from temporary location
!ifdef CONFIG_ARCH_C64 {
        lda $dc0d               ; c64: Silence the CIA 1 interrupts
        lda $dd0d               ; c64: Silence the CIA 2 interrupts
}
        rti                     ; Return from IRQ into next task
