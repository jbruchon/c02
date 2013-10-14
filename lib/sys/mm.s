; C02 Operating System
; mm.s: Memory management core
; Copyright (C) 2004-2008 by Jody Bruchon

malloc
        jsr criticalsection     ; Don't task-switch during malloc
        cmp mmfreepagecnt       ; Check against free pages available
        bcc malloc1             ; If enough or more available, scan
        beq malloc1
        jmp malloctoobig        ; If request too big, return an error
malloc1
        sta mmtemp0             ; Temporarily save requested page count
        lda #$00                ; Initialize A for free scan
        ldx #$00                ; Start page scan at zero-page
malloc2
        cmp memorymap,x         ; Compare memory map page with zero
        beq malloc4             ; If equal, start page ranging scan
        inx                     ; Increment page counter
        bne malloc2             ; Keep scanning until out of pages
malloc3
        jmp mallocnoblock       ; ERROR-No block large enough for request
malloc4
        stx mmtemp1             ; Temporarily store starting page
        ldy #$00                ; Initialize Y for page count
        cpx #$00                ; Check for page 0
; The following two lines are a workaround to cover the special case
; where the zero-page is actually marked "free"
        bne malloc5             ; If not page 0, skip to scanner
        beq mallocpage0         ; If page 0, skip first zero check in scan

malloc5
        cpx #$00                ; Check X to be sure it's not zeroed
        beq malloc3             ; If X has recycled to zero, error!
mallocpage0
        iny                     ; Increment counter
        inx                     ; Increment scan page
        cpy mmtemp0             ; Check against requested number of pages
        beq malloc6             ; If done, complete malloc and return
        cmp memorymap,x         ; Check next page in block
        beq malloc5             ; If free, return to counter checkpoint
        jmp malloc2             ; If not free, return to main scan
malloc6
        jsr getcpid             ; Get current process ID in A
        ldx mmtemp1             ; Get starting page of allocation
        ldy mmtemp0             ; Get number of pages allocated
malloc7
        sta memorymap,x         ; Set current memory map pointer to CPID
        inx                     ; Increment to next page
        dec mmfreepagecnt       ; Decrement free page count
        dey                     ; Decrement pages requested counter
        bne malloc7             ; Keep going until all marked used
        lda mmtemp1             ; Return starting page of block in A
        ldx mmtemp0             ; Return original pages requested in X
        jsr uncriticalsection   ; Unlock critical section
        clc
        rts


mfree
        jsr criticalsection     ; Don't task-switch during mfree
        sta mmtemp0             ; Save start of pages to free
        stx mmtemp1             ; Save number of pages
        jsr getcpid             ; Get CPID of caller
        ldx mmtemp0             ; Restore start page
        ldy mmtemp1             ; Restore page count
mfree1
        cmp memorymap,x         ; Check CPID against PID in memory map
        beq mfree2              ; If equal, proceed
        jmp mfreepid            ; If not equal, abort and return error
mfree2
        inx                     ; Increment page number to check
        dey                     ; Decrement page counter
        beq mfree3              ; If zero, actually de-allocate it
        bne mfree1              ; If non-zero, keep checking
mfree3
        ldx mmtemp0             ; Restore start page
        ldy mmtemp1             ; Restore page count
        lda #$00                ; Initialize A for deallocation
mfree4
        sta memorymap,x         ; Deallocate memory
        inx                     ; Increment page number
        inc mmfreepagecnt       ; Increment free page count
        dey                     ; Decrement page counter
        bne mfree4              ; If non-zero, keep going
        jsr uncriticalsection   ; Unlock task switching
        clc                     ; If zero, return OK
        rts
