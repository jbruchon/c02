; C02 Operating System
; irq.s: IRQ handler and IRQ hook execution point
; Copyright (C) 2004, 2005 by Jody Bruchon

; If maxtsk is too high, the kernel will crash out
; irqsav will save all of the context information for the task that
; is being pre-empted, increment the task counter, and do a bounds
; check on the task number, recycling to 1 if tasks has been exceeded.
; irqsav also checks the offset cache for overflow and re-inits if so.

irq

; Check flags for task switch disable
; Adding this killed a CMOS optimization...oh well.
        pha                     ; Save A
        lda systemflags         ; Load system flags
        and #criticalflag       ; Check critical flag
        beq irqokay1            ; If unset, go ahead
        jmp irqhooks1           ; Otherwise skip task switch code
irqokay1

; Perform the context save

        txa                     ; Push X into A to be saved
        ldx offset              ; Load the offset cache
        sta ctxpage+taskx,x     ; Store X
        tya
        sta ctxpage+tasky,x     ; Store Y
        pla                     ; Pull A
        sta ctxpage+taska,x     ; Store A
        pla                     ; Pull P (IRQ stored)
        sta ctxpage+taskp,x     ; Store P
        pla                     ; Pull PC low byte
        sta ctxpage+taskpc,x    ; Store PC low
        pla                     ; Pull PC high
        sta ctxpage+taskpc+1,x  ; Store PC high
        stx temp                ; Save index
        tsx                     ; Get current SP
        txa                     ; Save SP elsewhere
        ldx temp                ; Restore index
        sta ctxpage+tasksp,x    ; Save SP

        lda zp0                 ; Get ZP0
        sta ctxpage+taskzp,x    ; Save ZP0 in context
        lda zp1
        sta ctxpage+taskzp+1,x
        lda zp2
        sta ctxpage+taskzp+2,x
        lda zp3
        sta ctxpage+taskzp+3,x
        lda zp4
        sta ctxpage+taskzp+4,x
        lda zp5
        sta ctxpage+taskzp+5,x
        lda zp6
        sta ctxpage+taskzp+6,x
        lda zp7
        sta ctxpage+taskzp+7,x  ; Repeat until all ZP[0..7] are saved

        clc                     ; Carry bit can kill our addition...
        lda offset              ; Retrieve the offset cache
        adc #$10                ; Increment offset cache by 16
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

; Switch stack pointer
        tax                     ; Load new offset index
        lda ctxpage+tasksp,x    ; Load SP
        tax                     ; Prepare SP for change
        txs                     ; Change SP

; IRQ hooks are here because we can safely clobber AXY now

irqhooks1
!src "include/irqhooks.s"

; Check flags for task switch disable
        lda systemflags         ; Load system flags
        and #criticalflag       ; Check critical flag
        beq irqokay2            ; If unset, go ahead
        rti                     ; Otherwise return to program

irqokay2

; Load context and return from interrupt
        ldx offset              ; Restore clobbered offset index

        lda ctxpage+taskzp+0,x  ; Start ZP restoration
        sta zp0
        lda ctxpage+taskzp+1,x
        sta zp1
        lda ctxpage+taskzp+2,x
        sta zp2
        lda ctxpage+taskzp+3,x
        sta zp3
        lda ctxpage+taskzp+4,x
        sta zp4
        lda ctxpage+taskzp+5,x
        sta zp5
        lda ctxpage+taskzp+6,x
        sta zp6
        lda ctxpage+taskzp+7,x
        sta zp7

        lda ctxpage+taskpc+1,x  ; Load PC high
        pha                     ; Push PC high
        lda ctxpage+taskpc,x    ; Load PC low
        pha                     ; Push PC low
        lda ctxpage+taskp,x     ; Load P
        pha                     ; Push P
        lda ctxpage+taska,x     ; Load A
        pha                     ; Temporarily save A
        ldy ctxpage+tasky,x     ; Load Y
        lda ctxpage+taskx,x     ; Load X with A
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
