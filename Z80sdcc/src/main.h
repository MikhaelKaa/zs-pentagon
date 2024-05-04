// 15.04.2024 Михаил Каа
#ifndef __MAIN__
#define __MAIN__

#include "defines.h"

void print(char x, char y, char* text) __naked;

// Полуряд Space...B.
__sfr __banked __at(0x7ffe) port_0x7ffe;
// Полуряд 0...6.
__sfr __banked __at(0xeffe) port_0xeffe;
// Полуряд Enter....H
__sfr __banked __at(0xbffe) port_0xbffe;
// Полуряд P...Y.
__sfr __banked __at(0xdffe) port_0xdffe;
// Полуряд 1...5.
__sfr __banked __at(0xf7fe) port_0xf7fe;
// Полуряд CS....V
__sfr __banked __at(0xfefe) port_0xfefe;
// Полуряд Q...T.
__sfr __banked __at(0xfbfe) port_0xfbfe;
// Полуряд A...G.
__sfr __banked __at(0xfdfe) port_0xfdfe;
//  Управление конфигурацией компьютера для любых 128K моделей.
__sfr __banked __at(0x7ffd) port_0x7ffd;
// Порт клавиатуры, цвет бордюра, бипер, магнитофон.
__sfr __banked __at(0x00fe) port_0x00fe;
// Порт регистр адреса AY-3-8910.
__sfr __banked __at(0xfffd) port_0xfffd;
// Порт регистр данных AY-3-8910.
__sfr __banked __at(0xbffd) port_0xbffd;

// Порт 0xeff7.
__sfr __banked __at(0xeff7) port_0xeff7;



#endif /* __MAIN__ */
