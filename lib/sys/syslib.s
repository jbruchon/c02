; C02 Operating System
; syslib.s: Kernel core API library
; Copyright (C) 2004-2008 by Jody Bruchon

; See API documentation for high-level details on using Syslib.

syslibstart

!src "lib/sys/char.s"
!src "lib/sys/critical.s"
!src "lib/sys/math.s"
!src "lib/sys/memory.s"
!src "lib/sys/process.s"
!src "lib/sys/mm.s"
!ifdef CONFIG_DEBUG !src "lib/sys/debug.s"
!ifdef CONFIG_DEBUG !src "lib/sys/panic.s"
!src "lib/sys/errcodes.s"
!src "lib/sys/messages.s"
