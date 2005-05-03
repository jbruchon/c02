; C02 Operating System
; char.s: NES PPU CHR-ROM source
; Copyright (C) 2004, 2005 by Jody Bruchon

; Copied from the original Commodore 64 character set

; This CHR-ROM data is intended to accompany the NES PPU driver.

!to "chr-rom.o",plain
*= $0000

; The characters 0-31 are blank to make ASCII mapping easier.

*= $0200
!08 $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $18,$18,$18,$18,$00,$00,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$66,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$ff,$66,$ff,$66,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $18,$3e,$60,$3c,$06,$7c,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $62,$66,$0c,$18,$30,$66,$46,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$3c,$38,$67,$66,$3f,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $06,$0c,$18,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $0c,$18,$30,$30,$30,$18,$0c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $30,$18,$0c,$0c,$0c,$18,$30,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$66,$3c,$ff,$3c,$66,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$18,$18,$7e,$18,$18,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$00,$00,$00,$18,$18,$30,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$00,$7e,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$00,$00,$00,$18,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$03,$06,$0c,$18,$30,$60,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$6e,$76,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $18,$18,$38,$18,$18,$18,$7e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$06,$0c,$30,$60,$7e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$06,$1c,$06,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $06,$0e,$1e,$66,$7f,$06,$06,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$60,$7c,$06,$06,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$60,$7c,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$66,$0c,$18,$18,$18,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$66,$3c,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$66,$3e,$06,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$18,$00,$00,$18,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$18,$00,$00,$18,$18,$30,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $0e,$18,$30,$60,$30,$18,$0e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$00,$7e,$00,$7e,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $70,$18,$0c,$06,$0c,$18,$70,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$06,$0c,$18,$00,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$6e,$6e,$60,$62,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $18,$3c,$66,$7e,$66,$66,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7c,$66,$66,$7c,$66,$66,$7c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$60,$60,$60,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $78,$6c,$66,$66,$66,$6c,$78,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$60,$60,$78,$60,$60,$7e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$60,$60,$78,$60,$60,$60,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$60,$6e,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$66,$7e,$66,$66,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$18,$18,$18,$18,$18,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $1e,$0c,$0c,$0c,$0c,$6c,$38,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$6c,$78,$70,$78,$6c,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $60,$60,$60,$60,$60,$60,$7e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $63,$77,$7f,$6b,$63,$63,$63,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$76,$7e,$7e,$6e,$66,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$66,$66,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7c,$66,$66,$7c,$60,$60,$60,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$66,$66,$66,$3c,$0e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7c,$66,$66,$7c,$78,$6c,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$66,$60,$3c,$06,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$18,$18,$18,$18,$18,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$66,$66,$66,$66,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$66,$66,$66,$3c,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $63,$63,$63,$6b,$7f,$77,$63,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$3c,$18,$3c,$66,$66,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $66,$66,$66,$3c,$18,$18,$18,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $7e,$06,$0c,$18,$30,$60,$7e,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$30,$30,$30,$30,$30,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $0c,$12,$30,$7c,$30,$62,$fc,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $3c,$0c,$0c,$0c,$0c,$0c,$3c,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$18,$3c,$7e,$18,$18,$18,$18,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!08 $00,$10,$30,$7f,$7f,$30,$10,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

*= $1000

; Sprite data would go here.

*= $2000

; File MUST build to 8,192 bytes!
