; Kernel start routine for C64

main
        sei
        lda #$05
        sta $01
        jmp $ff00
