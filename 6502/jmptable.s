; C02 Operating System
; jmptable.s: Jump table constructor
; Copyright (C) 2004, 2005 by Jody Bruchon

; EVERYTHING that will be in the API jump table must be mentioned here.


!ifdef CONFIG_ADV_NO_SYSLIB {} else {
        jmp getchar
        jmp putchar
        jmp queuekey
!ifdef CONFIG_ADV_NO_CRITICAL {} else {
        jmp criticalsection
        jmp uncriticalsection
}
        jmp multiply8
        jmp blockmovedown
        jmp blockmoveup
        jmp pagemove
        jmp pagefill
}
