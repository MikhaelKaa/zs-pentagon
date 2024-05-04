#ifndef __DEFINES__
#define __DEFINES__

#if !defined(__SDCC_z80)
    #define __data
    #define __code
    #define __sfr volatile unsigned char
    #define __critical
    #define __banked
    #define __at(x)
    #define __using(x)
    #define __interrupt(x)
    #define __naked
    #define __asm
    #define __endasm
    
    #define ds
    #define nop
    #define ld
    #define iy
#endif

#endif /* __DEFINES__ */
