; C02 Operating System
; process.s: Process management routines
; Copyright (C) 2004, 2005 by Jody Bruchon

; getcpid will return the currently executing process's ID

; *SYSCALL*
getcpid
        lda #$01                ; Dummy to allow for testing!
        rts
