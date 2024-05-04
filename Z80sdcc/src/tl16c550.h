
#ifndef __TL16C550__
#define __TL16C550__
#include "defines.h"

void uart_init(void);
void uart_print(char* text);
char uart_get(char* data);

void delay(unsigned int t);

// Порт reg 0. RBR_THR регистр данных TL16C550.
__sfr __banked __at(0xf8ef) port_0xf8ef;
// Порт reg 1. IER TL16C550.
__sfr __banked __at(0xf9ef) port_0xf9ef;
// Порт reg 2. IIR_FCR TL16C550.
__sfr __banked __at(0xfaef) port_0xfaef;
// Порт reg 3. LCR TL16C550.
__sfr __banked __at(0xfbef) port_0xfbef;
// Порт reg 4. MCR TL16C550.
__sfr __banked __at(0xfcef) port_0xfcef;
// Порт reg 5. LSR TL16C550.
__sfr __banked __at(0xfdef) port_0xfdef;
// Порт reg 6. MSR TL16C550.
__sfr __banked __at(0xfeef) port_0xfeef;
// Порт reg 7. SR TL16C550.
__sfr __banked __at(0xffef) port_0xffef;

#endif /* __TL16C550__ */
