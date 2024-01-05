    device ZXSPECTRUM48
    
begin:
    org 0x0000
    ; Запрещаем прерывания.
    di
    di
    di
    im 1
    nop
    nop

    jp start

    org 0x0038
    di
    push af
    push bc
    push hl
    push de
    ; start int programm

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
    ;ld sp, 0x6000
    ;ld sp, 0x7ff7
    ld sp, 0xffff
    ;ld sp, 0x3ff7
    ; Разрешаем прерывания.
    ;ei    ; <-- off, for debug

    
    call white_border
    ld bc, 64000
    call delay
    ld bc, 64000
    call delay
    ld bc, 64000
    call delay
    call black_border
    ld bc, 64000
    call delay

    ;jp loop

data_bus_test
    ld a, 0b10101010
    out (0xfe), a
    in a, (0xfe)
    cp a, 0b10101010
    jr nz, dlopp_fail

    ld a, 0b01010101
    out (0xfe), a
    in a, (0xfe)
    cp a, 0b01010101
    jr nz, dlopp_fail

    ld a, 0b00000000
    out (0xfe), a
    in a, (0xfe)
    cp a, 0b00000000
    jr nz, dlopp_fail

    ld a, 0b11111111
    out (0xfe), a
    in a, (0xfe)
    cp a, 0b11111111
    jr nz, dlopp_fail

    jp dlopp_ok

dlopp_fail
    call red_border
    call black_border
    jr dlopp_fail

dlopp_ok
    call green_border
    ld bc, 64000
    call delay

ram_test
    ld hl, 0x8000
    ld de, 0x1000
test
    call black_border

    ld a, 0xff
    ld (hl), a
    nop
    nop
    nop
    nop
    nop
    nop
    cp (hl)
    jp nz, ram_test_failed

    ld a, 0x55
    ld (hl), a 
    nop
    nop
    nop
    nop
    nop
    nop
    cp (hl)
    jp nz, ram_test_failed

    ld a, 0xaa
    ld (hl), a 
    nop
    nop
    nop
    nop
    nop
    nop
    cp (hl)
    jp nz, ram_test_failed

    ld a, 0x00
    ld (hl), a 
    nop
    nop
    nop
    nop
    nop
    nop
    cp (hl)
    jp nz, ram_test_failed

    call green_border
    
    inc hl
    dec de

    ld a, d
    or e
    jp nz, test
    jp ram_test_end

ram_test_failed
    call red_border
    jp ram_test
    
ram_test_end


loop    
    ld a, 0b00000000
    out (0xfe), a
    ld a, 0b00000001
    out (0xfe), a
    ld a, 0b00000010
    out (0xfe), a
    ld a, 0b00000011
    out (0xfe), a
    ld a, 0b00000100
    out (0xfe), a
    ld a, 0b00000101
    out (0xfe), a
    ld a, 0b00000110
    out (0xfe), a
    ld a, 0b00000111
    out (0xfe), a
    ld bc, 1
    call delay
    
    jp loop 

white_border
    ld a, 0b00000111
    out (0xfe), a
    ret

black_border
    ld a, 0b00000000
    out (0xfe), a
    ld bc, 10
    call delay
    ret

red_border
    ld a, 0b00000010
    out (0xfe), a
    ld bc, 64000
    call delay
    ret

green_border
    ld a, 0b00000100
    out (0xfe), a
    ld bc, 10
    call delay
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

; Процедура задержки
delay
    dec bc
    ld a, b
    or c
    jr nz, delay
    ret

end:
    ; Выводим размер банарника.
    display "code size: ", /d, end - begin
    SAVEBIN "out.bin", begin, 32768; 32768 - размер бинарного файла для прошивки ПЗУ\ОЗУ