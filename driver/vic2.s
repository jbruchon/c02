; C02 Operating System
; vic2.s: Commodore VIC-II text console driver
; Copyright (C) 2004, 2005 by Jody Bruchon

; Currently just a dummy to allow build to work

consoleput
        rts

; vic2xyput puts the ASCII code specified into the specified X and Y
; locations (starting at 0,0) on the text console.  Load A with the value
; to place, X and Y with the screen location to put the character in.

vic2xyput

; vic2scroll will make a new line at the end of the screen and push all
; other lines up by one, destroying the first line.

vic2scroll
        pha
        txa
        pha
        ldx #$39
        inx


