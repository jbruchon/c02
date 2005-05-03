; C02 Operating System
; jmptable.s: Jump table constructor
; Copyright (C) 2004, 2005 by Jody Bruchon

; EVERYTHING that will be in the API jump table must be mentioned here.

; -- Syslib API routines --

; - Character I/O -

sgetchar
        jmp getchar
sputchar
        jmp putchar
squeuekey
        jmp queuekey
