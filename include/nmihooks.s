; C02 Operating System
; nmihooks.s: Driver NMI hook functions
; Copyright (C) 2004, 2005 by Jody Bruchon

!ifdev CONFIG_NES_PPU {
        jsr nesppunmihook       ; NES PPU VBlank operations
}
