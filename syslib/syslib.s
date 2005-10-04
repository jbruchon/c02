; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004, 2005 by Jody Bruchon

; See API documentation for high-level details on using Syslib.

syslibstart

!src "SYSLIB/CHAR.S"
!src "SYSLIB/CRITICAL.S"
!src "SYSLIB/MATH.S"
!src "SYSLIB/MEMORY.S"
!src "SYSLIB/PROCESS.S"
!src "SYSLIB/MM.S"
!ifdef CONFIG_DEBUG !src "SYSLIB/DEBUG.S"
!ifdef CONFIG_DEBUG !src "SYSLIB/PANIC.S"
!src "SYSLIB/ERRCODES.S"
