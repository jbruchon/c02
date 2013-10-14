; C02 Operating System
; tstdebug.s: Initial task that puts out a debugging message.
; Copyright (C) 2004-2008 by Jody Bruchon

; Nothing but code to illustrate a debugging message.

beginning
        lda #<testdebugmsg
        sta debugmessage
        lda #>testdebugmsg
        sta debugmessage+1
        jsr debugprint          ; Print debugging message
testloop
        bcs testloop
        bcc testloop            ; Loop forever

testdebugmsg
!raw "This is a test debug message.  w00t!",$0d
