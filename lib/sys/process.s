; C02 Operating System
; process.s: Process management routines
; Copyright (C) 2004-2008 by Jody Bruchon

; breakexec will prematurely simulate an IRQ safely
; You must call this to return control to C02
; BRK without a "BRK OK" flag set will result in the
; process involved being killed immediately

; *SYSCALL*
breakexec
        pha
        lda systemflags         ; Load system flags
        ora breakokflag         ; Set break OK flag
        sta systemflags         ; Store new flags
        pla
        brk
        nop
        rts

; getcpid will return the currently executing process's ID

; *SYSCALL*
getcpid
        ldx task                ; Load current task number
        lda #$00                ; Clear offset count
getcpid1
        dex
        beq getcpid2            ; If X=0, finish up
        clc
        adc #pitentrysize
        bcc getcpid1
!ifdef CONFIG_DEBUG {
        sei
        jsr kernelpanic         ; This should never happen.
}

getcpid2
        tax                     ; Prepare calculated offset for use
        lda pidpage+pitpid,x    ; Get current PID
        rts

; killcpid will determine the current PID and then call killpid to
; destroy it

; *SYSCALL*
killcpid
        jsr getcpid

; killpid will terminate the PID in A when called without question

; *SYSCALL*
killpid
        rts

; createpid will create a new empty process entry

; *SYSCALL*
createpid
        sei
        jsr criticalsection     ; No interruptions!
        lda systemflags
        and #createpidflag
        beq createpidfok
        jsr uncriticalsection
        cli
        jmp createpidused       ; If flag set, an unused PID exists.
createpidfok
        ldx #$00
        ldy tasks
        lda #$01                ; Default first PID entry
        sta pidtemp             ; Store as potential PID
createpid1
        lda pidpage+pitpid,x    ; Get PID from table
        cmp pidtemp             ; Compare against possible PID
        bne createpid2          ; Don't change PID if not the same
        inc pidtemp             ; Increment PID
        ldx #$00                ; Restart PID search
        ldy tasks
        beq createpid1
createpid2
        dey                     ; Decrement task counter
        beq createpid4          ; If task counter is zero, PID found!
        txa
        clc
        adc #pitentrysize       ; Increase index for next check
        bcc createpid3
!ifdef CONFIG_DEBUG {
        jsr kernelpanic         ; If add produces carry, too many processes
}
        sec
        rts
createpid3
        tax
        inc pidtemp             ; Increment PID to try
        jmp createpid1          ; Return to try next PID number
createpid4
        ldy #$ff
        cpy pidtemp
        bne createpid5
!ifdef CONFIG_DEBUG {
        jsr kernelpanic         ; If add produces carry, too many processes
}
        sec
        rts
createpid5
        txa
        clc
        adc #pitentrysize       ; Increase offset for new PID
        bcc createpid6
        jsr uncriticalsection
        cli
        jmp createpidfail       ; Error if add produces carry
createpid6
        tax
        lda #$00
        sta pidpage+pitstate    ; Clear out process state
        lda pidtemp
        sta pidpage+pitpid,x    ; Store new PID in PIT
        jsr uncriticalsection
        cli
        clc
        rts                     ; Return PID in A

; activatepid will start a task

; *SYSCALL*
activatepid
        sei
        jsr criticalsection     ; No interruptions!
        lda systemflags
        and #createpidflag      ; Check if a PID is waiting for activation
        bne activatepid1
        jsr uncriticalsection
        cli
        jmp activatepiderror    ; If no PID has been initialized, error
activatepid1
        ldx #$00                ; Init PID search index
activatepid2
        ldy pidpage+pitpid,x    ; Get PID at index
        cpy pidtemp             ; Check against index
        beq activatepid3        ; If found, activate it!
        tya                     ; Not found? Increment and try again.
        clc
        adc #pitentrysize       ; Jump by the PIT entry size
        bcc activatepidcc1      ; Error (this should never happen)
        sec
        rts
activatepidcc1
        tay                     ; Restore index
        jmp activatepid2        ; Restart PID search
activatepid3
        lda #$01                ; Process state = running
        inc tasks               ; Schedule task for execution
        jsr uncriticalsection
        cli
        clc
        rts
