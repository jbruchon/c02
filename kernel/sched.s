; C02 Operating System for 65xx / Commodore 64
; Task Scheduler and IRQ Handler
; C02/kernel/sched.s
;
; Copyright (C) 2004, 2005 by Jody Bruchon
;
; Heavy commenting all around so that anyone can read this and
; see what it is doing at all steps.  I hate weakly commented code.
; THIS CODE WAS WRITTEN AND TESTED ON THE ACME CROSS-ASSEMBLER 0.85
;

; It is recommended that you load as high as possible in order to
; maximize free memory for tasks.  This should have been obvious.

!src "../build.cfg"
!src "../include/setbuild.h"

*=SCHED_BASE
!to "sched.o",plain

!zone
; Start address where each task begins execution.
t1addr  =INIT_TASK_START        ; Task 1 start address
tskcnt  =$01                    ; Number of tasks running

; Kernel variable ZP locations
task    =$02                    ; Kernel task counter
temp    =$03                    ; Temporary workspace
tasks   =$04                    ; Number of tasks running
offset  =$05                    ; Context offset cache

; Initial SP for tasks
t1spi   =$ff                    ; Task 1 init SP

; The following are zero-page addresses used to store
; context-switching information for a process.
; Each context uses 7 bytes of zero page memory.
; Only Task 1 variables are used.  Higher task numbers
; find their corresponding values from an index generated
; from the task number such that for task N:
; t1var + (7 * (task - 1)) = tNvar
t1pc    =$06                    ; Task 1 PC (2 bytes)
;       =$07
t1a     =$08                    ; Task 1 A
t1x     =$09                    ; Task 1 X
t1y     =$0a                    ; Task 1 Y
t1p     =$0b                    ; Task 1 status
t1sp    =$0c                    ; Task 1 SP

; An INIT program will be automatically launched at "t1addr" when the
; init section finishes.

!ifdef CONFIG_6502 !src "6502/sched/init.s"
!ifdef CONFIG_65C02 !src "65c02/sched/init.s"
!ifdef CONFIG_65816EMU !src "65816emu/sched/init.s"

; irq is the start of our interrupt service routine.

!ifdef CONFIG_6502 !src "6502/sched/irq.s"
!ifdef CONFIG_65C02 !src "65c02/sched/irq.s"
!ifdef CONFIG_65816EMU !src "65816emu/sched/irq.s"
