    device ZXSPECTRUM48
    
begin:
    org 0x0000
    ; Запрещаем прерывания.
    di
    jp start

    org 0x0038
    di
    push af
    push bc
    push hl
    push de
    ; start int programm
    ld bc, 1000
    call delay

    ld a, 0b00000111
    out (0xfe), a
    ld bc, 300
    call delay

    ld a, 0b00000001
    out (0xfe), a 
    ld bc, 300
    call delay

    ld a, 0b00000010
    out (0xfe), a 
    ld bc, 300
    call delay

    ld a, 0b00000000
    out (0xfe), a 
    ld bc, 300
    call delay  


    ; end int programm
    pop de
    pop hl
    pop bc
    pop af
    ei
    reti

    org 0x0100
start
    
    ; Устанавливаем дно стека.
    ld sp, 0x7ff7
    ;ld sp, 0xfff7
    ;ld sp, 0x3ff7
    ; Разрешаем прерывания.
    ei    ; <-- off, for debug

    call led_start
    call led_start
    call led_start


loop    


    call key

    ld de, startup_end - startup
    ld hl, startup
    call covox_8kHz

    jp loop 


key
    ;halt
    ;call led_loop
    ld    a, 0x7e       ;в аккумулятор заносится старший байт адреса порта #7EFE
    in    a, (0xfe)    ;считывание из порта (254 или #FE - младший байт адреса)
    bit   2, a          ;проверка нажатия третьей от края клавиши (M)
    jr    nz, key
    ret

; 
led_start
    ld a, 0b00000000
    out (0xfe), a
    ld bc, 10000
    call delay

    ld a, 0b00000001
    out (0xfe), a
    ld bc, 10000
    call delay
    ret

; 
led_loop
    ld a, 0b00000000
    out (0xfe), a
    ld bc, 10
    call delay

    ld a, 0b00000001
    out (0xfe), a 
    ld bc, 10
    call delay

    ld a, 0b00000010
    out (0xfe), a 
    ld bc, 10
    call delay

    ld a, 0b00000100
    out (0xfe), a 
    ld bc, 10
    call delay  
    ret

    ld a, 0b00000111
    out (0xfe), a 
    ld bc, 10
    call delay  
    ret
; Процедура задержки
delay
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

port_covox  EQU 0xfb

covox_8kHz 
    di
covox_8kHz_l
    ld bc, 13
    nop
    nop
    nop
    nop
    call delay
    ld a, (hl)
    out (port_covox), a
    inc hl
    dec de
    ld a, d
    or e
    jr nz, covox_8kHz_l
    ei
    ret

startup
    ;incbin "tung.wav", 0x86+73000, 30000-8650
    ;incbin "startup.wav", 0x86, 30000
    ;incbin "tada.wav", 0x86
startup_end


end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "out.bin", begin, 32768; 32768 - размер бинарного файла для прошивки ПЗУ\ОЗУ