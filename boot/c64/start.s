; Kernel start routine for C64
; This is an example that will start
; a program loaded under the KERNAL ROM
; from BASIC.

main
        sei
        lda #$05
        sta $01
        jmp $f000
