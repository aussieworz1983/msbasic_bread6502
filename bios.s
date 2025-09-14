.setcpu "65C02" ;setcpu to modern functions
.debuginfo
.segment "BIOS"

ACIA_DATA   = $4800
ACIA_STATUS = $4801
ACIA_CMD    = $4802
ACIA_CTRL   = $4803

LOAD:
              rts
SAVE:
              rts

MONRDKEY:
CHRIN:
              lda  ACIA_STATUS
              and  #$08
              beq  @no_keypressed
              lda  ACIA_DATA
              jsr  CHROUT
              sec
              rts
@no_keypressed:
              clc
              rts

MONCOUT:
CHROUT:
              pha
              sta  ACIA_DATA
              lda  #$FF
@txdelay:
              lda     ACIA_STATUS
              and     #$10
              beq     @txdelay
              pla
              rts

.include "worzman.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector