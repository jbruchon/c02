; C02 Operating System
; tstpanic.s: Initial task that simply throws a PANIC
; Copyright (C) 2004-2008 by Jody Bruchon

; Nothing but code to illustrate a kernel panic.

beginning
        lda #$01                ; Put a recognizable sequence on the stack.
        pha
        lda #$02
        pha
        lda #$03
        pha
        lda #$04
        pha
        lda #$05
        pha
        jsr kernelpanic         ; PANIC!!!!!
