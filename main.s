; C02 Operating System
; main.s: Kernel Image Core
; Copyright (C) 2004, 2005 by Jody Bruchon

!to "MAIN.O",plain
!sl "KSYMS.TXT"

; Load build configuration variables
!src "BUILD.CFG"
!src "INCLUDE/SETBUILD.S"
!src "INCLUDE/SYSVARS.S"
!src "INCLUDE/KBQUEUE.S"

!ifdef CONFIG_NES_HEADER !src "INCLUDE/INESHEAD.S"

!ifdef CONFIG_PREPEND {
  *=CORE_BASE-CONFIG_PREPEND
  !fill CONFIG_PREPEND
}

*=CORE_BASE

; Custom hard-coded initial task inclusion/remapping
!ifdef CONFIG_CUSTOM_INIT_TASK !src "CUSTOM.S"
!ifdef CONFIG_CUSTOM_INIT_TASK !set INIT_TASK_START=CORE_BASE

; Start address where each task begins execution.
t1addr  =INIT_TASK_START        ; Task 1 start address
tskcnt  =$01                    ; Number of initial tasks running

!ifdef CONFIG_USE_INIT_CODE {
RESVEC
  !ifdef CONFIG_6502 !src "6502/INIT.S"
  !ifdef CONFIG_65C02 !src "6502/INIT.S"
  !ifdef CONFIG_65816EMU !src "6502/INIT.S"
  !ifdef CONFIG_65816 !src "65816/INIT.S"
}

; Device drivers
!ifdef CONFIG_INPUT_C64_KEY !src "DRIVER/C64KEY.S"
!ifdef CONFIG_INPUT_NES_PAD !src "DRIVER/NESPAD.S"
!ifdef CONFIG_NES_PPU !src "DRIVER/NESPPU.S"
!ifdef CONFIG_INPUT_SIMTERM !src "DRIVER/SIMTERM.S"
!ifdef CONFIG_CIA_C64 !src "DRIVER/C64CIA.S"
!ifdef CONFIG_SERIAL_6551 !src "DRIVER/6551.S"
!ifdef CONFIG_VIC_I !src "DRIVER/VIC1.S"
!ifdef CONFIG_VIC_II !src "DRIVER/VIC2.S"

; IRQ handler and task switcher core

!ifdef CONFIG_6502 !src "6502/IRQ.S"
!ifdef CONFIG_65C02 !src "6502/IRQ.S"
!ifdef CONFIG_65816EMU !src "6502/IRQ.S"
!ifdef CONFIG_65816 !src "65816/IRQ.S"

!ifdef CONFIG_6502 !src "6502/SYSLIB.S"
!ifdef CONFIG_65C02 !src "6502/SYSLIB.S"
!ifdef CONFIG_65816EMU !src "6502/SYSLIB.S"
!ifdef CONFIG_65816 !src "65816/SYSLIB.S"

; The jump table loaded here is where system calls take place.

*=JMPTABLE_BASE
!src "INCLUDE/JMPTABLE.S"

; If your system has C02 in a ROM or boots into the init sequence by RESET,
; you will need to provide the RESET vector value in build.cfg

!ifdef CONFIG_BUILD_ROM {

  ; 65816 has more vectors than 6502.
  !ifdef CONFIG_65816 {
    *=$fff0
    !08 $00, $00, $00, $00, <copvec, >copvec
    !08 <brkvec, >brkvec, <abortvec, >abortvec
  }
  *=$fffa
  !08 <nmivec, >nmivec, <RESVEC, >RESVEC, <irq, >irq
}
