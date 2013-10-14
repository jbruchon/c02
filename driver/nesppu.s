; C02 Operating System
; nesppu.s: Nintendo Entertainment System PPU video driver
; Copyright (C) 2004-2008 by Jody Bruchon

; nesppuirqhook is the IRQ hook point for this driver.

; This driver hooks NMI interrupts to perform operations.

nesppuirqhook
        rts

nesppuout
consoleput
        rts

nesppunmihook
        rts
