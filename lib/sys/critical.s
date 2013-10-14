; C02 Operating System
; critical.s: Critical section handlers
; Copyright (C) 2004-2008 by Jody Bruchon

; (un)criticalsection enables/disables task switching for protection of
; a program's critical section.
; *SYSCALL*
!ifdef CONFIG_ADV_NO_CRITICAL {} else {
criticalsection
        pha
        lda #criticalflag       ; Get bit mask
        ora systemflags         ; Disable scheduler
        sta systemflags         ; Store new flags
        pla
        rts

; *SYSCALL*
uncriticalsection
        pha
        lda #255-criticalflag   ; Get bit mask
        and systemflags         ; Apply mask to flags
        sta systemflags         ; Store new flags
        pla
        rts
}

