.segment "CODE"
.ifdef WORZBASIC



SCK_BIT     = %00000001    ; PB0
MOSI_BIT    = %00000010    ; PB1
MISO_BIT    = %00000100    ; PB2  (input)
CS_BIT      = %00001000    ; PB3

zp_sd_cmd_address = $40
; ===== SPI select/deselect =====
sd_init:
    lda #CS_BIT | MOSI_BIT
    ldx #160
preinitloop:
    eor #SCK_BIT
    sta PORTBADDR
    dex
    bne preinitloop

    jsr longdelay

cmd0: ; GO_IDLE_STATE - resets card to idle state, and SPI mode
  lda #<cmd0_bytes
  sta zp_sd_cmd_address
  lda #>cmd0_bytes
  sta zp_sd_cmd_address+1

;   jsr sd_sendcommand

  ; Expect status response $01 (not initialized)
  cmp #$01
  bne initfailed
  jsr longdelay


initfailed:
  lda #'X'
  jsr lcd_print_char
  jmp loop


cmd8: ; SEND_IF_COND - check voltage range
  lda #<cmd8_bytes
  sta zp_sd_cmd_address
  lda #>cmd8_bytes
  sta zp_sd_cmd_address+1

cmd0_bytes:
  .byte $40, $00, $00, $00, $00, $95
cmd8_bytes:
  .byte $48, $00, $00, $01, $aa, $87
cmd55_bytes:    
  .byte $77, $00, $00, $00, $00, $01
cmd41_bytes:
  .byte $69, $40, $00, $00, $00, $01

sd_send_command:
    jsr LCDCMD

    lda #'c'
    jsr lcd_print_char
    ldx #0
    lda (zp_sd_cmd_address, x)
    

the_delay:
  ldx #0
  ldy #0
loop:
  dey
  bne loop
  dex
  bne loop
  rts

longdelay:
  jsr mediumdelay
  jsr mediumdelay
  jsr mediumdelay
mediumdelay:
  jsr the_delay
  jsr the_delay
  jsr the_delay
  jmp the_delay

.endif