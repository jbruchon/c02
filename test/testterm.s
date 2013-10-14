; C02 Operating System
; testterm.s: Initial task to echo console input to console output
; Copyright (C) 2004-2008 by Jody Bruchon

; This code snippet echoes console input to console output.
; A null ($00) from input means no characters exist to be input.

beginning

!ifdef CONFIG_DEBUG {
	lda #<funmessage
	sta debugmessage
	lda #>funmessage
	sta debugmessage+1
	jsr debugprint
}

testtermloop
        ldx #$00                ; Select device 0 (console)
        jsr getchar             ; Get character from device 0
        bcs testerror1
        cmp #$00                ; Is char null?
        beq testtermloop           ; Yes: try again
        ldx #$00                ; No: select console again 
        jsr putchar             ; Echo char back to console
        bcs testerror2
        jmp testtermloop        ; Loop forever...

testerror1
        lda #$01
        pha
        pha
        pha
        jsr kernelpanic
testerror2
        lda #$02
        pha
        pha
        pha
        jsr kernelpanic

funmessage
!raw "C02 terminal endless loop task started.",$0d