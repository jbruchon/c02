; Conditional universal build settings
; C02/include/setbuild.h
;
; Copyright (C) 2004, 2005 by Jody Bruchon

!ifdef CONFIG_6502 !cpu 6502
!ifdef CONFIG_65C02 !cpu 65c02
!ifdef CONFIG_65816EMU !cpu 65816

!ifdef CONFIG_ARCH_C64 {
   SCHED_BASE=$ff00
   INIT_TASK_START=$0800
}
