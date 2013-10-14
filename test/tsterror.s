; C02 Operating System
; tsterror.s: Initial task that tests error code debug messages
; Copyright (C) 2004-2008 by Jody Bruchon

beginning
        jsr devnumfailure
        jsr resourcelocked
        jsr bufferfull
        jsr malloctoobig
        jsr mallocnoblock
        jsr mfreepid
        jsr createpidfail
        jsr createpidused
        jsr activatepiderror
        jsr err_libds_initdm
loop
        jmp loop
