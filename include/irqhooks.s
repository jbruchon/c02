; C02 Operating System
; irqhooks.s: Driver IRQ hook inclusion
; Copyright (C) 2004-2008 by Jody Bruchon

!ifdef CONFIG_INPUT_C64_KEY {
        jsr c64keyirqhook       ; C64 keyboard polling
}
!ifdef CONFIG_INPUT_SIMTERM {
        jsr simtermirqhook      ; 65C02 sim terminal in polling
}
!ifdef CONFIG_INPUT_NES_PAD {
        jsr nespadirqhook       ; NES gamepad polling
}
!ifdef CONFIG_NES_PPU {
        jsr nesppuirqhook       ; NES PPU operations
}
!ifdef CONFIG_SERIAL_6551 {
        jsr ser6551irqhook      ; 6551 UART I/O device
}
!ifdef CONFIG_ARCH_C64 {
        jsr c64ciairqhook       ; C64 CIA chip handler
}
