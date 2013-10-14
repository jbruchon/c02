; C02 Operating System
; tstbrk.s: Initial task that tests unexpected BRK behavior
; Copyright (C) 2004-2008 by Jody Bruchon

beginning
        brk
        nop
loop
        jmp loop
