; C02 Operating System
; setbuild.s: Conditional build sub-settings
; Copyright (C) 2004-2008 by Jody Bruchon

; This file makes sure certain build settings don't conflict
; This file also sets conditional parameters.
; Preconfigured known systems are stored here.

!ifdef CONFIG_EXPENSIVE {
  CONFIG_SPEED=1
}

!ifdef CONFIG_ARCH_GENERIC {
  CORE_BASE=CONFIG_ARCH_GENERIC_CORE
  !ifdef CONFIG_CUSTOM_INIT_TASK {} else {
    INIT_TASK_START=CONFIG_ARCH_GENERIC_INIT
  }
  !ifdef CONFIG_ARCH_GENERIC_6510 CPU_6510=1
  !ifdef CONFIG_ARCH_GENERIC_RAM_AT_FF_PAGE RAM_AT_FF_PAGE=1
  !ifdef CONFIG_ARCH_GENERIC_NULL_NMI CONFIG_NULL_NMI=1
  !ifdef CONFIG_ARCH_GENERIC_SYS_NORMAL CONFIG_SYSTEM_NORMAL=1
  !ifdef CONFIG_ARCH_GENERIC_SYS_TINY CONFIG_SYSTEM_TINY=1
  ctxpage=CONFIG_ARCH_GENERIC_CONTEXT_PAGE
  pidpage=CONFIG_ARCH_GENERIC_PID_PAGE
  memorymap=CONFIG_ARCH_GENERIC_MEMORYMAP
}

; Commodore 64

!ifdef CONFIG_ARCH_C64 {
  CONFIG_6502=1
  CPU_6510=1
  CORE_BASE=$c000
  RAM_AT_FF_PAGE=1
  CONFIG_SYSTEM_NORMAL=1
  !ifdef CONFIG_CUSTOM_INIT_TASK {} else {
    INIT_TASK_START=$0900
  }
  CONFIG_INPUT_C64_KEY=1
  CONFIG_CIA_C64=1
  CONFIG_VIC_II=1
  RAM_AT_FF_PAGE=1
  CONFIG_NULL_NMI=1
  ctxpage=$0200
  pidpage=$0300
  memorymap=$0800
}

; Nintendo Entertainment System

!ifdef CONFIG_ARCH_NES {
  CONFIG_6502=1
  CORE_BASE=$c000
  CONFIG_SYSTEM_NORMAL=1
  !ifdef CONFIG_CUSTOM_INIT_TASK {} else {
    INIT_TASK_START=$c000
  }
  JMPTABLE_BASE=$fe00
  CONFIG_BUILD_ROM=1
  CONFIG_INPUT_NES_PAD=1
  CONFIG_NES_PPU=1
  cpu_no_decimal=1
  ctxpage=$ce00
  pidpage=$cf00
  memorymap=$cd00
}

; Commodore VIC-20

!ifdef CONFIG_ARCH_VIC20 {
  CONFIG_6502=1
  CORE_BASE=$1000
  CONFIG_SYSTEM_TINY=1
  !ifdef CONFIG_CUSTOM_INIT_TASK {} else {
    INIT_TASK_START=$0800
  }
  CONFIG_KBCORE=1
  CONFIG_VIC_I=1
  ctxpage=$0200
  pidpage=$0400
  memorymap=$0300
}

; Daryl Rictor's 65C02 simulator

!ifdef CONFIG_ARCH_RIC65C02 {
  CONFIG_65C02=1
  CONFIG_CUSTOM_INIT_TASK=1
  CORE_BASE=$f000
  CONFIG_SYSTEM_NORMAL=1
; INIT_TASK_START will be set to CORE_BASE
  CONFIG_BUILD_ROM=1
  CONFIG_INPUT_SIMTERM=1
  CONFIG_SERIAL_6551=1
  CONFIG_SERIAL_6551_BASE=$8030
  CONFIG_NULL_NMI=1
  CONFIG_PREPEND=CORE_BASE-$8000
  ctxpage=$0200
  pidpage=$0400
  memorymap=$0300
}

; CPU definitions
!ifdef CONFIG_6502 !cpu 6502
!ifdef CONFIG_65C02 !cpu 65c02
!ifdef CONFIG_65816EMU !cpu 65816
!ifdef CONFIG_65816 !cpu 65816
