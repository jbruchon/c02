; C02 Operating System
; drvinit.s: Per-driver initialization code
; Copyright (C) 2004-2008 by Jody Bruchon

; Silence CIA IRQs on C64
!ifdef CONFIG_ARCH_C64 {
        lda $dc0d                       ; CIA 1
        lda $dd0d                       ; CIA 2
}

; Initialize VIC-II
!ifdef CONFIG_VIC_II {
        lda #$00
        sta vic2crsrX
        sta vic2crsrY
        lda #$17
        sta $d018		; Set shifted character set
}

; Initialize CIA1 for a C64 keyboard

!ifdef CONFIG_INPUT_C64_KEY {
        lda #$ff                ; Set C64 CIA #1 port A to OUTPUT
        sta $dc02
  !ifdef CONFIG_6502 {
        lda #$00                ; Set C64 CIA #1 port B to INPUT
        sta $dc03
  } else {
        stz $dc03               ; Set CIA #1 PB to INPUT [Optimized]
  }

}

!ifdef CONFIG_NES_PPU {

; Set basic PPU registers.  Load background from $0000,
; sprites from $1000, and the name table from $2000.
; Sets sprites to be off, BG on, VBlank NMI on.
        lda #%10001000
        sta $2000
        lda #%00001110
        sta $2001
}
