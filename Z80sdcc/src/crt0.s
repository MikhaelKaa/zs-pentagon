    ;; crt0.s
    ;; zx spectrum 48K ram startup code
    ;; MIT License (see: LICENSE)
    ;; Copyright (C) 2021 Tomaz Stih
    ;; 2021-06-16   tstih
    ;; 15.04.2024 Михаил Каа

    ; CALL Address
    ; 0000h C7 RST 0
    ; 0008h CF RST 8
    ; 0010h D7 RST 16
    ; 0018h DF RST 24
    ; 0020h E7 RST 32
    ; 0028h EF RST 40
    ; 0030h F7 RST 48
    ; 0038h FF RST 56
; when a Nonmaskable Interrupt (NMI) signal is received, the CPU ignores the next instruction and instead restarts, returning to memory address 0066h

    .module crt0
    .area   _CODE
    ; Запрещаем прерывания.
    di
    im 1

    ; Подогнано так, чтобы процедура обработки прерывания располагалась по адресу 0x38
    .ds	49

    jp start
    nop

    ;.org 0x0038 
    di
    ;; store all regs
    push    af
    push    bc
    push    de
    push    hl
    push    ix
    push    iy
    ex      af, af'
    push    af
    exx
    push    bc
    push    de
    push    hl
    ; int programm
    call    _irq_0x38
    ; end int programm
    ;; restore all regs
    pop     hl
    pop     de
    pop     bc
    pop     af
    exx
    ex      af, af'
    pop     iy
    pop     ix
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei
    reti
    ; Подогнано так, чтобы процедура обработки nmi располагалась по адресу 0x66
    .ds	11

    ;.org 0x0066 
    di
    ;; store all regs
    push    af
    push    bc
    push    de
    push    hl
    push    ix
    push    iy
    ex      af, af'
    push    af
    exx
    push    bc
    push    de
    push    hl
    ; nmi programm
    call    _nmi_0x66
    ; end nmi programm
    ;; restore all regs
    pop     hl
    pop     de
    pop     bc
    pop     af
    exx
    ex      af, af'
    pop     iy
    pop     ix
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei
    reti

    .ds	119

    ;.org 0x100
start:
    ld      sp, #__stack             ; load new stack pointer

    call    gsinit                  ; call SDCC init code

    ei
    ;; call C main function
    call    _main	


    ;;	(linker documentation:) where specific ordering is desired - 
    ;;	the first linker input file should have the area definitions 
    ;;	in the desired order
    .area   _GSINIT
    .area   _GSFINAL	
    .area   _HOME
    .area   _INITIALIZER
    .area   _INITFINAL
    .area   _INITIALIZED
    .area   _DATA
    .area   _BSS
    .area   _HEAP

    ;;	this area contains data initialization code.
    .area _GSINIT
gsinit:	
    ;; initialize vars from initializer
    ld      de, #s__INITIALIZED
    ld      hl, #s__INITIALIZER
    ld      bc, #l__INITIALIZER
    ld      a, b
    or      a, c
    jr      z, gsinit_none
    ldir
gsinit_none:
    .area _GSFINAL
    ret

    .area _DATA
    .area _BSS
    ;; this is where we store the stack pointer
__store_sp:	
    .word 1
    ;; 2048 bytes of operating system stack
    .ds	2048
__stack::
    .area _HEAP
__heap::
