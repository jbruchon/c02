; C02 Operating System
; sysvars.s: Global kernel/syslib variables
; Copyright (C) 2004-2008 by Jody Bruchon

; If the system has a 6510 CPU, push all globals forward by 2
; so non-6510 systems don't waste ZP space but 6510 systems don't
; misbehave either.  What an annoyance, eh?


!set gzpoffset=$00
!ifdef CPU_6510 !set gzpoffset=$02

;;;;;;;;;;;;;;;;;;;;;;;;
; Context storage offsets

; This must be set to the total context size.
ctxsize=$0f

taskpc          =$00            ; Task PC (2 bytes)
;               =$01
taska           =$02            ; Task A
taskx           =$03            ; Task X
tasky           =$04            ; Task Y
taskp           =$05            ; Task proc status
tasksp          =$06            ; Task SP
taskzp          =$07            ; Task zero page storage 0...7
;               =$08...$14        Same as above


;;;;;;;;;;;;;;;;;;;;;;;;
; Initial task stack pointer
taskspi =$ff

;;;;;;;;;;;;;;;;;;;;;;;;
; Basic kernel function storage
task            =$00+gzpoffset  ; Kernel current task number storage
temp            =$01+gzpoffset  ; Temporary kernel storage (non-reentrant)
tasks           =$02+gzpoffset  ; Total running tasks quantity storage
offset          =$03+gzpoffset  ; Offset cache storage
systemflags     =$04+gzpoffset  ; System core flags register
; systemflags flag definitions
criticalflag    =%00000001      ; Critical Section (scheduler disable) flag
breakokflag     =%00000010      ; BRK instruction intentional flag
createpidflag   =%00000100      ; Unused PID waiting to be activated flag

;;;;;;;;;;;;;;;;;;;;;;;
; Commodore 64 keyboard driver
c64kflags       =$05+gzpoffset
c64kscantbl     =$0d+gzpoffset  ; 8 bytes
c64knewkeys     =$15+gzpoffset  ; 3 bytes
c64koldkeys     =$18+gzpoffset  ; 5 bytes
c64ktemp        =$1d+gzpoffset
c64ktemp2       =$1e+gzpoffset
c64kignore      =$1f+gzpoffset
c64kporta       =$dc00
c64kportb       =$dc01
c64kddra        =$dc02
c64kddrb        =$dc03

;;;;;;;;;;;;;;;;;;;;;;;
; Rictor's 65C02 simulator terminal driver
simtermin       =$8000
simtermstb      =$8001
simtermout      =$8010

;;;;;;;;;;;;;;;;;;;;;;;
; Commodore 64 VIC-II driver
vic2text        =$0400
vic2textll      =vic2text+$3c0
vic2color       =$d800
vic2crsrX       =$06+gzpoffset
vic2crsrY       =$07+gzpoffset
vic2vector1     =$08+gzpoffset
vic2vector2     =$09+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; Malloc/Mfree storage
mmtemp0         =$0a+gzpoffset
mmtemp1         =$0b+gzpoffset
mmfreepagecnt   =$0c+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; Debug area defines
debugmessage    =$d0 ;(vector)
debuga          =$d2
debugx          =$d3
debugy          =$d4
debugp          =$d5
debugtmp0       =$d6
debugtmp1       =$d7

;;;;;;;;;;;;;;;;;;;;;;;
; Syslib global variables

; Library lock flags
; Each byte serves eight Syslib routines with locking functions.

lock1           =$20+gzpoffset
  getcharL      =%00000001
  kbqueueL      =%00000010

;;;;;;;;;;;;;;;;;;;;;;;
; Machine Language Monitor

mlmbufptr       =$21+gzpoffset
mlmbuffer       =$22+gzpoffset
mlmbuflen       =$0a
mlmpromptchar   ="."

;;;;;;;;;;;;;;;;;;;;;;;
; PID working area
pidtemp         =$2d+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; Keystroke input queue constants
kbqueue         =$2e+gzpoffset
kbqueuelen      =$0e            ; length in bytes (must be $04 or higher)

;;;;;;;;;;;;;;;;;;;;;;;
; DS library ZP storage
dspat           =$3d+gzpoffset
dsmspt          =$3e+gzpoffset

;;;;;;;;;;;;;;;;;;;;;;;
; User ZP locations
; These are saved with all context switches

zp0             =$f8
zp1             =$f9
zp2             =$fa
zp3             =$fb
zp4             =$fc
zp5             =$fd
zp6             =$fe
zp7             =$ff

;;;;;;;;;;;;;;;;;;;;;;;;
; Process information table

pitentrysize    =$08

pitpid          =$00
pitstate        =$01
pitimport       =$02
pitexport       =$04
pitbank         =$06
pitsize         =$07

