; C02 Operating System
; irq.s: Selector for correct IRQ handling core
; Copyright (C) 2004-2008 by Jody Bruchon

!ifdef CONFIG_SYSTEM_NORMAL !src "6502/irqstd.s"
!ifdef CONFIG_SYSTEM_TINY !src "6502/irqtiny.s"
