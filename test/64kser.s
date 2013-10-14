; C02 Operating System
; 64kser.s: Code that tries to use KERNAL serial routines
; Copyright (C) 2004-2008 by Jody Bruchon

; If this works, I'll write a C64 serial driver later on.

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
