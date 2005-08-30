; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004, 2005 by Jody Bruchon

; See API documentation for high-level details on using Syslib.

syslibstart

!src "6502/CHAR.S"
!src "6502/CRITICAL.S"
!src "6502/MATH.S"
!src "6502/MEMORY.S"
!src "6502/PROCESS.S"
!src "6502/MM.S"
!ifdef CONFIG_DEBUG !src "6502/DEBUG.S"
!ifdef CONFIG_DEBUG !src "6502/PANIC.S"
!src "6502/ERRCODES.S"
