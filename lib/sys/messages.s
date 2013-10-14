; C02 Operating System
; messages.s: Pre-defined system messages
; Copyright (C) 2004-2008 by Jody Bruchon

; ***ERROR CODES***

devnumfailuredm
!raw "C02:SYS Device number failure",$0d

resourcelockeddm
!raw "C02:SYS Resource locked",$0d

bufferfulldm
!raw "C02:SYS Buffer full",$0d

malloctoobigdm
!raw "C02:SYS Not enough memory",$0d

mallocnoblockdm
!raw "C02:SYS Memory too fragmented",$0d

mfreepiddm
!raw "C02:SYS Memory dealloc request denied",$0d

randombrkdm
!raw "C02:IRQ Unexpected BRK encountered",$0d

createpidfaildm
!raw "C02:SYS Create PID failed",$0d

createpiduseddm
!raw "C02:SYS Unused PID exists",$0d

activatepiderrordm
!raw "C02:SYS Activated PID without init",$0d

err_libds_initdm
!raw "C02:DS per-process init failed",$0d
