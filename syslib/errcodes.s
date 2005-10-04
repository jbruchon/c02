; C02 Operating System
; errcodes.s: Error codes
; Copyright (C) 2004, 2005 by Jody Bruchon

; ***ERROR CODES***

devnumfailure
        lda #$01                ; Error code $01 = "Device number unknown"
        sec                     ; Carry set = error occurred.
        rts

resourcelocked
        lda #$02                ; Error code $02 = "Resource in use/locked"
        sec
        rts

bufferfull
        lda #$03                ; Error code $03 = "Buffer is full"
        sec
        rts

malloctoobig
        lda #$04                ; Error code $04 = "Not enough memory"
        sec
        rts

mallocnoblock
        lda #$05                ; Error code $05 = "Memory too fragmented"
        sec
        rts

mfreepid
        lda #$06                ; Error code $06 = "Bad PID called mfree"
        sec
        rts


