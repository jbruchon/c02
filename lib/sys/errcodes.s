; C02 Operating System
; errcodes.s: Error codes
; Copyright (C) 2004-2008 by Jody Bruchon

; ***ERROR CODES***

devnumfailure
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<devnumfailuredm
        sta debugmessage
        lda #>devnumfailuredm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$01                ; Error code $01 = "Device number unknown"
        sec                     ; Carry set = error occurred.
        rts

resourcelocked
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<resourcelockeddm
        sta debugmessage
        lda #>resourcelockeddm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$02                ; Error code $02 = "Resource in use/locked"
        sec
        rts

bufferfull
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<bufferfulldm
        sta debugmessage
        lda #>bufferfulldm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$03                ; Error code $03 = "Buffer is full"
        sec
        rts

malloctoobig
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<malloctoobigdm
        sta debugmessage
        lda #>malloctoobigdm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$04                ; Error code $04 = "Not enough memory"
        sec
        rts

mallocnoblock
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<mallocnoblockdm
        sta debugmessage
        lda #>mallocnoblockdm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$05                ; Error code $05 = "Memory too fragmented"
        sec
        rts

mfreepid
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<mfreepiddm
        sta debugmessage
        lda #>mfreepiddm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$06                ; Error code $06 = "Bad PID called mfree"
        sec
        rts

createpidfail
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<createpidfaildm
        sta debugmessage
        lda #>createpidfaildm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$07                ; Error code $07 = "Cannot create new PID"
        sec
        rts

createpidused
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<createpiduseddm
        sta debugmessage
        lda #>createpiduseddm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$08                ; Error code $08 = "Unused PID exists"
        sec
        rts

activatepiderror
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<activatepiderrordm
        sta debugmessage
        lda #>activatepiderrordm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$09                ; Error code $09 = "Must create PID first"
        sec
        rts

err_libds_init
!ifdef CONFIG_DEBUG {
  !ifdef CONFIG_DEBUG_ERRCODES {
        sei
        lda #<err_libds_initdm
        sta debugmessage
        lda #>err_libds_initdm
        sta debugmessage+1
        jsr debugprint
        cli
  }
}
        lda #$0a                ; Error code $0a = "DS initialization error"
        sec
        rts