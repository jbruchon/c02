; Pre-emptive multitasking "kernel" for 65xx / Commodore 64
;
; Copyright (C) 2004 by Jody Bruchon
;
; Heavy commenting all around so that anyone can read this and
; see what it is doing at all steps.  I hate weakly commented code.
; THIS CODE WAS WRITTEN AND TESTED ON THE A6 CROSS-PLATFORM NMOS 6502
; ASSEMBLER.
;

; Start address where each task begins execution.
t1addr  =$1000                  ; Task 1 start address
t2addr  =$7000                  ; Task 2 start address
tskcnt  =$02                    ; Number of tasks running

; Kernel variable ZP locations
task    =$02                    ; Kernel task counter
temp    =$03                    ; Temporary workspace
tasks   =$04                    ; Number of tasks running
offset  =$05                    ; Context offset cache

; Initial SP for tasks
t1spi   =$ff                    ; Task 1 init SP
t2spi   =$7f                    ; Task 2 init SP

; The following are zero-page addresses used to store
; context-switching information for a process.
; Each context uses 7 bytes of zero page memory.
; Only Task 1 variables are used.  Higher task numbers
; find their corresponding values from an index generated
; from the task number such that for task N:
; t1var + (7 * (task - 1)) = tNvar
t1pc    =$06                    ; Task 1 PC (2 bytes)
;       =$07
t1a     =$08                    ; Task 1 A
t1x     =$09                    ; Task 1 X
t1y     =$0a                    ; Task 1 Y
t1p     =$0b                    ; Task 1 status
t1sp    =$0c                    ; Task 1 SP

; It is recommended that you load as high as possible in order to
; maximize free memory for tasks.  This should have been obvious.
; The "init" section can be totally wiped out by a program.

        .org $ff00

; init is where the kernel's tasks are set up.  It sets up two tasks
; for demonstrations, but for a real system this will only need to
; clean house before kernel entry and the program that loads the kernel
; will be responsible for setting PC/SP up for the "init program" it
; loads...blah, that was a mouthful. :)

init
        sei                     ; Mask off IRQs so we aren't interrupted
        lda #$05                ; C64: Make SURE 6510 keeps I/O banked in
        sta $01                 ; C64: LORAM+CHAREN=I/O.  CHAREN only=RAM
        lda #<irq               ; Set NMI vector to irq
        sta $fffa               ; nmivec = $fffa-b
        lda #>irq
        sta $fffb
        lda #<init              ; Set RESET vector to init
        sta $fffc               ; resvec = $fffc-d
        lda #>init
        sta $fffd
        lda #<irq               ; Set IRQ vector to irq (surprise...)
        sta $fffe               ; irqvec = $fffe-f
        lda #>irq
        sta $ffff
        ldx #t1spi              ; Task SP inits
        txs
        lda #t2spi
        sta t1sp+7              ; t2sp = (t1sp+((task-1)*7)
        lda #<t1addr            ; Task PC inits
        sta t1pc
        lda #>t1addr
        sta t1pc+1
        lda #<t2addr
        sta t1pc+7              ; t2pc = t1pc+((task-1)*7)
        lda #>t2addr
        sta t1pc+8
        lda #$00                ; Init offset cache to 0
        sta offset
        lda #$01                ; Set up task counter to start at task 1
        sta task
        lda #tskcnt+1           ; Get the maximum tasks to start running
        sta tasks               ; ...and set the kernel to execute them
        lda #>t1addr            ; Push task 1 context to stack
        pha                     ; so we can RTI, end up at t1addr
        lda #<t1addr            ; and start executing task 1.
        pha
        lda #$20                ; Clear P, except for E bit (for 65816's)
	sta t1p+7		; Store for task 2.
        pha			; Push for task 1.
        lda $dc0d               ; C64: Silence the CIA 1 interrupts
        lda $dd0d               ; c64: Silence the CIA 2 interrupts
        rti                     ; Start Task 1!  w00t!

; irq is the start of our interrupt service routine.
; This is where the real kernel scheduling is done!

irq
        pha                     ; Save A so we won't lose it!

; If maxtsk is too high, the kernel will crash out
; irqsav will save all of the context information for the task that
; is being pre-empted, increment the task counter, and do a bounds
; check on the task number, recycling to 1 if tasks has been exceeded.
; irqsav also checks the offset cache for overflow and re-inits if so.

irqsav
        txa                     ; Push X into A to be saved
        ldx offset              ; Load the offset cache
        sty t1y,x               ; Store Y
        sta t1x,x               ; Store X
        pla                     ; Pull A
        sta t1a,x               ; Store A
        pla                     ; Pull P (IRQ stored)
        sta t1p,x               ; Store P
        pla                     ; Pull PC low byte
        sta t1pc,x              ; Store PC low
        pla                     ; Pull PC high
        sta t1pc+1,x            ; Store PC high
        stx temp                ; Save index
        tsx                     ; Get current SP
        txa                     ; Save SP elsewhere
        ldx temp                ; Restore index
        sta t1sp,x              ; Save SP
        clc                     ; Carry bit can kill our addition...
        lda offset              ; Retrieve the offset cache
        adc #$07                ; Increment offset cache by 7
        bcc addokay             ; If the carry bit isn't set, OK.
        jmp init                ; Carry bit set = too many tasks
addokay
        ldx task                ; Load task number
        inx                     ; Increment task number by 1
        cpx tasks               ; Compare with running task counter
        bne irqtsk              ; If not at max, proceed normally
        lda #$00                ; Reset offset cache to 0
        ldx #$01                ; Reset task number to 1

; All irqtsk does is provide a skip point to jump over the code
; that resets the task counter to 1 and the offset cache to 0

irqtsk
        sta offset              ; Save offset cache
        stx task                ; Save task number

; irqload performs the loading of the context from zero-page memory
; and returns from the interrupt to the next task

irqload
        tax                     ; Load index
        stx temp                ; Save index to memory temporarily
        lda t1sp,x              ; Load SP
        tax                     ; Prepare SP for change
        txs                     ; Change SP
        ldx temp                ; Restore index
        lda t1pc+1,x            ; Load PC high
        pha                     ; Push PC high
        lda t1pc,x              ; Load PC low
        pha                     ; Push PC low
        lda t1p,x               ; Load P
        pha                     ; Push P
        lda t1a,x               ; Load A
        sta temp                ; Temporarily save A
        ldy t1y,x               ; Load Y
        lda t1x,x               ; Load X with A
        tax                     ; Move X's value from A into X
        lda temp                ; Load A from temporary location
        lda $dc0d               ; c64: Silence the CIA 1 interrupts
        lda $dd0d               ; c64: Silence the CIA 2 interrupts
        rti                     ; Return from IRQ into next task
