; C02 Operating System
; irq.s: IRQ handler and IRQ hook execution point
; Copyright (C) 2004, 2005 by Jody Bruchon

; If maxtsk is too high, the kernel will crash out
; irqsav will save all of the context information for the task that
; is being pre-empted, increment the task counter, and do a bounds
; check on the task number, recycling to 1 if tasks has been exceeded.
; irqsav also checks the offset cache for overflow and re-inits if so.

irq

!ifdef CONFIG_6502 {
        pha                     ; Save A so we won't lose it!

; This code performs the context save.

        txa                     ; Push X into A to be saved
        ldx offset              ; Load the offset cache
        sta ctxpage+t1x,x       ; Store X
        tya
        sta ctxpage+t1y,x       ; Store Y
        pla                     ; Pull A
        sta ctxpage+t1a,x       ; Store A
}
!ifdef CONFIG_65C02 {
        phx                     ; Save X [Optimized]
        ldx offset              ; Load the offset cache
        sta ctxpage+t1a,x       ; Store A
        tya
        sta ctxpage+t1y,x       ; Store Y
        pla                     ; Pull X
        sta ctxpage+t1x,x       ; Store X
}
!ifdef CONFIG_65816EMU {
        phx                     ; Save X [Optimized]
        ldx offset              ; Load the offset cache
        sta ctxpage+t1a,x       ; Store A
        tya
        sta ctxpage+t1y,x       ; Store Y
        pla                     ; Pull X
        sta ctxpage+t1x,x       ; Store X
}
        pla                     ; Pull P (IRQ stored)
        sta ctxpage+t1p,x       ; Store P
        pla                     ; Pull PC low byte
        sta ctxpage+t1pc,x      ; Store PC low
        pla                     ; Pull PC high
        sta ctxpage+t1pc+1,x    ; Store PC high
        stx temp                ; Save index
        tsx                     ; Get current SP
        txa                     ; Save SP elsewhere
        ldx temp                ; Restore index
        sta ctxpage+t1sp,x      ; Save SP
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

; This code loads the context from memory and returns from the
; interrupt to the next task

        tax                     ; Load new offset index
        lda ctxpage+t1sp,x      ; Load SP
        tax                     ; Prepare SP for change
        txs                     ; Change SP

; IRQ hooks are here because we can safely clobber AXY now

!src "include/irqhooks.s"

        ldx offset              ; Restore clobbered offset index
        lda ctxpage+t1pc+1,x    ; Load PC high
        pha                     ; Push PC high
        lda ctxpage+t1pc,x      ; Load PC low
        pha                     ; Push PC low
        lda ctxpage+t1p,x       ; Load P
        pha                     ; Push P
        lda ctxpage+t1a,x       ; Load A
        pha                     ; Temporarily save A
        ldy ctxpage+t1y,x       ; Load Y
        lda ctxpage+t1x,x       ; Load X with A
        tax                     ; Move X's value from A into X
        pla                     ; Load A from temporary location
!ifdef CONFIG_NULL_NMI {
nmivec
        rti
} else {
        rti                     ; Return from IRQ into next task
nmivec
!src "INCLUDE/NMIHOOKS.S"       ; NMI hooks (if applicable)
        rti
}