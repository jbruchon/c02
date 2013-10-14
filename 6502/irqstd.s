; C02 Operating System
; irqstd.s: IRQ handler for most systems
; Copyright (C) 2004-2008 by Jody Bruchon

irq

!ifdef CONFIG_6502 {
        pha                     ; Save A
        txa                     ; Push X into A to be saved
        ldx offset              ; Load the offset cache
        sta ctxpage+taskx,x     ; Store X
        pla
        sta ctxpage+taska,x     ; Store A
}
!ifdef CONFIG_65C02 {
        phx                     ; Save X [Optimized]
        ldx offset              ; Load the offset cache
        sta ctxpage+taska,x     ; Store A
        pla
        sta ctxpage+taskx,x     ; Store X
}
        tya
        sta ctxpage+tasky,x     ; Store Y
        pla
        sta ctxpage+taskp,x     ; Store P
        pla
        sta ctxpage+taskpc,x    ; Store PC low
        pla
        sta ctxpage+taskpc+1,x  ; Store PC high
        stx temp                ; Save index
        tsx
        txa                     ; Save SP elsewhere
        ldx temp                ; Restore index
        sta ctxpage+tasksp,x    ; Save SP

!ifdef CONFIG_ADV_NO_ZPCONTEXT {} else {
        ldy #$00
irqzpsave
        lda zp0,y               ; Save ZP values
        sta ctxpage+taskzp,x
        inx
        iny
        cpy #$08
        bcc irqzpsave
}

!ifdef CONFIG_ADV_NO_BRK_KILL {} else {
        ldx offset              ; Get offset to load status with
        lda ctxpage+taskp,x     ; Get status byte
        and #$10                ; BRK flag check
        beq irqbrkclear         ; If unset, BRK did not happen
        lda systemflags
        and breakokflag         ; Check to see if BRK is expected
        bne irqbrkclear
  !ifdef CONFIG_DEBUG {
        sei                     ; Debugging error message
        lda #<randombrkdm
        sta debugmessage
        lda #>randombrkdm
        sta debugmessage+1
        jsr debugprint
        cli
  }
        lda task
        jsr killcpid            ; Kill current process!
irqbrkclear
        lda systemflags
        and #255-breakokflag    ; Reset break OK flag
        sta systemflags
}

!ifdef CONFIG_ADV_NO_CRITICAL {} else {
        lda systemflags         ; Load system flags
        and #criticalflag       ; Check critical flag
        bne irqnoinc            ; If unset, go ahead
}
        lda offset              ; Retrieve offset cache
        clc
        adc #ctxsize            ; Inc offset cache by context size
        bcc addokay				; This should never ever happen!!!
!ifdef CONFIG_ADV_NO_SYSLIB {
irqcontextoverflow
		jmp irqcontextoverflow	; Hang forever if syslib missing
} else {
		ldx #$ff				; Clear stack pointer before panic
		txs
		lda #$ef				; Put DEADBEEF on the stack.
		pha
		lda #$be
		pha
		lda #$ad
		pha
		lda #$de
		pha
        jmp kernelpanic			; DEADBEEF will appear in the PANIC
}

addokay
        ldx task                ; Load task number
        inx
        cpx tasks               ; Compare with running task counter
        bne irqtsk              ; If not at max, proceed normally
        lda #$00                ; Reset offset cache to 0
        ldx #$01                ; Reset task number to 1
irqtsk
        sta offset
        stx task

irqnoinc
; Switch stack pointer
        tax                     ; Load new offset index
        lda ctxpage+tasksp,x    ; Load SP
        tax
        txs                     ; Change SP

; IRQ hooks are here because we can safely clobber AXY now

irqhooks1
!src "include/irqhooks.s"

; Load context and return from interrupt
        ldx offset
        ldy #$00
irqzpload
        lda ctxpage+taskzp,x    ; Restore ZP values
        sta zp0,y
        inx
        iny
        cpy #$08
        bcc irqzpload

        ldx offset              ; Restore offset

        lda ctxpage+taskpc+1,x
        pha
        lda ctxpage+taskpc,x
        pha
        lda ctxpage+taskp,x
        pha
        lda ctxpage+taska,x
        pha
        ldy ctxpage+tasky,x
        lda ctxpage+taskx,x
        tax
        pla

!ifdef CONFIG_NULL_NMI {
nmivec
        rti
} else {
        rti                     ; Return from IRQ into next task
nmivec
!src "include/nmihooks.s"       ; NMI hooks (if applicable)
        rti
}
