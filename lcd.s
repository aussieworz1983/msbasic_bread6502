.segment "CODE"
.ifdef WORZBASIC
PORTAADDR = $6000
PORTBADDR = $6002
DDRA = $6001 
DDRB = $6003 

E = %10000000
RW = %01000000
RS = %00100000



LCDINIT:
    jsr porta_out
    jsr portb_out
    ;delay more than 100ms 10000 clock cycles
    jsr delay ;power on delay

    ;manual init for 16x2 lcd
    lda #%00110000 ;lcd special function set
    sta PORTBADDR

    jsr lcd_instruction
    ;delay 4.1ms
    ;4100 cycles
    jsr another_delay
    jsr another_delay
    jsr another_delay
    ;4500 cycles

    lda #%00110000 ;lcd special function set
    sta PORTBADDR

    jsr lcd_instruction
    jsr delay50
    jsr delay50
    ;delay 0.1ms
    ;100 clock cycles

    lda #%00110000 ;lcd special function set
    sta PORTBADDR

    jsr lcd_instruction
    jsr delay50
    jsr delay50
    ;delay 0.1ms
    ;100 clock cycles
    
    ;init sequence
    ;function set 8 bit 2 line
    lda #%00111000 ;port b 8bit 2 line
    sta PORTBADDR

    jsr lcd_instruction

    jsr delay50

    ;delay 53us or wait for busy flag
    
    ;display off
    lda #%00001000
    sta PORTBADDR
    
    jsr lcd_instruction
    
    jsr lcd_wait
    
    ;delay 53us or wait for busy flag
    ;53 clock cycles
    ;clear display
    lda #%00000001
    sta PORTBADDR
    
    jsr lcd_instruction
    jsr lcd_wait

    
    ;delay 53us or wait for busy flag

    ;entry mode set
    lda #%00000110
    sta PORTBADDR
    
    jsr lcd_instruction
    jsr lcd_wait

    
    ;delay 53us or wait for busy flag

    ;display on 0x0e
    lda #%00001110
    sta PORTBADDR
    
    jsr lcd_instruction
    ldx #0
    ;delay 53us or wait for busy flag
    jsr lcd_wait
    rts

LCDPRINT:
    ;print string to lcd

    jsr FRMEVL
    bit VALTYP
    bmi LCDPRINTIT
    jsr FOUT
    jsr STRLIT
LCDPRINTIT:
    ;print byte to lcd
    jsr FREFAC
    tax
    ldy #0
lcd_print_loop:
    lda (INDEX),y ;get byte from input buffer
    jsr lcd_print_char
    iny
    dex
    bne lcd_print_loop
    rts


lcd_print_char:
    jsr lcd_wait
    
    sta PORTBADDR
    lda #RS
    sta PORTAADDR
    lda #(RS | E)
    sta PORTAADDR
    lda #RS
    sta PORTAADDR
    rts


;lcd functions
lcd_wait:
 pha
 ;set port b input
 jsr portb_in

lcdbusy:
 lda #RW
 sta PORTAADDR
 lda #(RW | E)
 sta PORTAADDR

 lda PORTBADDR
 and #%10000000
 bne lcdbusy

 lda #RW
 sta PORTAADDR
;set port b output
 jsr portb_out
 pla
 rts

LCDCMD:
 jsr GETBYT
 txa
 jsr lcd_wait
 sta PORTBADDR
lcd_instruction:
;  jsr lcd_wait
 ;port a lcd controls rw rs bits
 lda #0
 sta PORTAADDR
 ;port a enable bit
 lda #E
 sta PORTAADDR
 ;port a lcd controls rw rs bits
 lda #0
 sta PORTAADDR
 rts

porta_in:
 lda #$00
 sta DDRA ; port b ddr

 lda #$00
 sta PORTAADDR

 lda #$04
 sta DDRA
 rts

porta_out:
 ;configure pia 21 port a as output
 lda #$00  
 sta DDRA ;port a ddr

 lda #%11110000
 sta PORTAADDR ;port a lst 3 bits output

 lda #$04   ; port a ctrl bit
 sta DDRA ; port a to port
 rts

portb_out:
 ;configure pia 21 port b as output
 lda #$00
 sta DDRB ; port b ddr

 lda #$ff
 sta PORTBADDR

 lda #$04
 sta DDRB
 rts

portb_in:
 lda #$00
 sta DDRB ; port b ddr

 lda #$00
 sta PORTBADDR

 lda #$04
 sta DDRB
 rts
 
;delay loops
;100900 cycles
delay:
    ldy #$42;50 *
delay2:
    ldx #$ff ;255 * 6 
delay1:
    nop
    dex
    bne delay1
    rts

delay_one:
    ldy #$ff;255 *
delay_one2:
    ldx #$ff ;255 * 6 
delay_one1:
    nop
    dex
    bne delay_one1
    dey
    bne delay_one2
    rts

;1530 cycles
another_delay:
    ldx #$ff ;255 * 6
another_delay1:
    nop
    dex
    bne another_delay1
    rts

;48 cycles
delay50:
    ldx #$08 ;8 * 6
delay501:
    nop ;2 cycles
    dex ;2 cycles
    bne delay501 ; 2 if no branch 3 if branch
    rts

.endif
