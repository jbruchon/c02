; C02 Operating System
; arch.s: Architecture-specific initialization inclusion
; Copyright (C) 2004-2008 by Jody Bruchon

!ifdef CONFIG_ARCH_C64 !src "6502/c64/i-c64.s"
!ifdef CONFIG_ARCH_VIC20 !src "6502/vic20/i-vic20.s"
!ifdef CONFIG_ARCH_NES !src "6502/nes/i-nes.s"
!ifdef CONFIG_ARCH_RIC65C02 !src "6502/ric65c02/i-ric65.s"
!ifdef CONFIG_ARCH_C64SCPU !src "6502/c64s/i-c64s.s"
