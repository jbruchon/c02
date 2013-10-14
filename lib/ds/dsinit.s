; C02 Operating System
; dsinit.s: libds initialization routines
; Copyright (C) 2004-2008 by Jody Bruchon

; libds_init uses Syslib to malloc the pages that hold all the information

libds_init
        lda #$01                        ; Allocate MSPT page
        jsr malloc
        bcc libds_init_mspt             ; Carry = error
        jmp err_libds_init
libds_init_mspt
        sta dsmspt                      ; Store MSPT allocated page
        lda #$01                        ; Allocate PAT page
        jsr malloc
        bcc libds_init_pat              ; Carry = error
        jmp err_libds_init
libds_init_pat
        sta dspat                       ; Store PAT allocated page
        sta zp1                         ; Store PAT for clearing
        lda #$ff
        sta zp2
        lda #$00
        sta zp0
        jsr pagefill                    ; Zero out page
        ldx dsmspt
        stx zp1
        jsr pagefill                    ; Zero again, yay
        rts

ds_init
        jsr getcpid                     ; Get requestor PID
        jsr ds_scan_mspt                ; Scan MSPT for requested PID
        bcs ds_init_ok_1                ; If "error," PID not found
        jmp err_libds_init
ds_init_ok_1
        jsr ds_new_mspt_entry           ; Make new MSPT entry for PID
        


; --Subroutine--
ds_scan_mspt
        tax                             ; Put PID to scan for in X
        lda dsmspt                      ; Load mspt page number for indexing
        sta zp1
        lda #$00                        ; Init vector for mspt
        sta zp0
ds_Scan_mspt_nofail
        tay
        txa                             ; Shuffling values around
ds_scan_mspt_1
        cmp (zp0),y                     ; Compare PID values
        bne ds_scan_mspt_none1          ; No match = keep looking
        jmp ds_mspt_match_ok1           ; Match found
ds_scan_mspt_none1
        tya
        clc
        adc #$08                        ; Increment offset by 8
        bcc ds_scan_mspt_nofail         ; Carry = scan failure
        sec
        rts
ds_mspt_match_ok1
        tya                             ; Return matching offset in A
        clc
        rts

; --Subroutine--
ds_new_mspt_entry

