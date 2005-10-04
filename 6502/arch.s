; C02 Operating System
; arch.s: Architecture-specific initialization inclusion
; Copyright (C) 2004, 2005 by Jody Bruchon

!ifdef CONFIG_ARCH_C64 !src "6502/C64/I-C64.S"
!ifdef CONFIG_ARCH_VIC20 !src "6502/C64/I-VIC20.S"
!ifdef CONFIG_ARCH_NES !src "6502/NES/I-NES.S"
!ifdef CONFIG_ARCH_RIC65C02 !src "6502/C64/I-RIC65.S"
!ifdef CONFIG_ARCH_C64SCPU !src "6502/C64/I-C64S.S"
