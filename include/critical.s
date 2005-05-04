; C02 Operating System
; critical.s: Syslib critical section entry/exit routines
; Copyright (C) 2004, 2005 by Jody Bruchon

criticalsection
        sei                     ; Obviously.

uncriticalsection
        cli                     ; Obviously.
