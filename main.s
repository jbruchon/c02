; C02 Operating System
; main.s: Kernel Image Core
; Copyright (C) 2004-2008 by Jody Bruchon

!to "main.o",plain
!sl "ksyms.txt"

; Load build configuration variables
!src "build.cfg"
!src "include/setbuild.s"
!src "include/sysvars.s"

!ifdef CONFIG_NES_HEADER !src "include/ineshead.s"

!ifdef CONFIG_PREPEND {
  *=CORE_BASE-CONFIG_PREPEND
  !fill CONFIG_PREPEND
}

*=CORE_BASE

; Custom hard-coded initial task inclusion/remapping
        jmp init                ; Jump point
!ifdef CONFIG_CUSTOM_INIT_TASK !src "custom.s"
!ifdef CONFIG_CUSTOM_INIT_TASK !set INIT_TASK_START=CORE_BASE+3

; Start address where each task begins execution.
taskaddr        =INIT_TASK_START        ; Task 1 start address
tskcnt          =$01                    ; Number of initial tasks running

!ifdef CONFIG_USE_INIT_CODE {
RESVEC
  !ifdef CONFIG_6502 !src "6502/init.s"
  !ifdef CONFIG_65C02 !src "6502/init.s"
  !ifdef CONFIG_65816EMU !src "65816emu/init.s"
  !ifdef CONFIG_65816 !src "65816/init.s"
}

; Device drivers
!ifdef CONFIG_INPUT_C64_KEY !src "driver/c64key.s"
!ifdef CONFIG_INPUT_NES_PAD !src "driver/nespad.s"
!ifdef CONFIG_NES_PPU !src "driver/nesppu.s"
!ifdef CONFIG_INPUT_SIMTERM !src "driver/simterm.s"
!ifdef CONFIG_CIA_C64 !src "driver/c64cia.s"
!ifdef CONFIG_SERIAL_6551 !src "driver/6551.s"
!ifdef CONFIG_VIC_I !src "driver/vic1.s"
!ifdef CONFIG_VIC_II !src "driver/vic2.s"

; IRQ handler and task switcher core

!ifdef CONFIG_6502 !src "6502/irq.s"
!ifdef CONFIG_65C02 !src "6502/irq.s"
!ifdef CONFIG_65816EMU !src "65816/irq.s"
!ifdef CONFIG_65816 !src "65816/irq.s"

; System library

!ifdef CONFIG_ADV_NO_SYSLIB {} else {

!src "lib/sys/syslib.s"

}

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
