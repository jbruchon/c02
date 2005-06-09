; C02 Operating System
; sysvars.s: Global kernel/syslib variables
; Copyright (C) 2004, 2005 by Jody Bruchon

; If the system has a 6510 CPU, push all globals forward by 2
; so non-6510 systems don't waste ZP space but 6510 systems don't
; misbehave either.  What an annoyance, eh?

!set gzpoffset=$00
!ifdef CPU_6510 !set gzpoffset=$02

;;;;;;;;;;;;;;;;;;;;;;;;
; Context-switching offset declarations

t1pc    =$00                    ; Task 1 PC (2 bytes)
;       =$01
t1a     =$02                    ; Task 1 A
t1x     =$03                    ; Task 1 X
t1y     =$04                    ; Task 1 Y
t1p     =$05                    ; Task 1 status
t1sp    =$06                    ; Task 1 SP

t1spi   =$ff                    ; Task 1 initial SP

task    =$00+gzpoffset          ; Kernel current task number storage
temp    =$01+gzpoffset          ; Temporary kernel storage
tasks   =$02+gzpoffset          ; Total running tasks quantity storage
offset  =$03+gzpoffset          ; Offset cache storage
systemflags=$04+gzpoffset       ; System core flags register

criticalflag   =%00000001       ; Critical Section (scheduler disable) flag

;;;;;;;;;;;;;;;;;;;;;;;
; Keystroke input queue constants
kbqueue         =$0300
kbqueuelen      =$0e            ; length in bytes (must be $04 or higher)

;;;;;;;;;;;;;;;;;;;;;;;
; Commodore 64 keyboard driver
c64kflags       =$05+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; Rictor's 65C02 simulator terminal driver
simtermin       =$8000
simtermstb      =$8001
simtermout      =$8010

;;;;;;;;;;;;;;;;;;;;;;;
; Commodore 64 VIC-II driver
vic2textbase    =$0400
vic2colorbase   =$d800
vic2crsrX       =$06+gzpoffset
vic2crsrY       =$07+gzpoffset
vic2vector      =$08+gzpoffset
vic2vector2     =$09+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; Syslib global variables

; Library mutual exclusion flags
; Each byte serves eight Syslib routines with mutex functions.

mutex1  =$04+gzpoffset          ; Mutex 1
  getcharM      =%00000001      ; getchar mutex

; multiply8 call variables
mpybyte0        =$0a+gzpoffset
mpybyte1        =$0b+gzpoffset
