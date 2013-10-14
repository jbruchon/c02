; C02 Operating System
; nmihooks.s: Driver NMI hook functions
; Copyright (C) 2004-2008 by Jody Bruchon

!ifdef CONFIG_NES_PPU {
        jsr nesppunmihook       ; NES PPU VBlank operations
}
