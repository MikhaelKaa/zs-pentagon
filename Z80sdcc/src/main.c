// 15.04.2024 Михаил Каа

#include "main.h"
#include "font.h"
#include "tl16c550.h"

#define SCREEN_START_ADR (0x4000)
#define SCREEN_SIZE ((256/8)*192)
#define SCREEN_ATR_SIZE (768)

void init_screen(void);

char *screen = 0x4000;
char w = 0;
char i = 0;
char key[8] = {0, 0, 0, 0, 0, 0, 0, 0};
static volatile char irq_0x38_flag = 0;
static volatile char nmi_0x66_flag = 0;
char msg[] = "Hello world!!!\r\n";

void check_turbo(void);
void check_read_port(void);
void check_mem(void);
static int offset = 0;

void main() {
    port_0x7ffd = 0x00;
    uart_init();
    init_screen();
    uart_print("\r\n\r\n***********************\r\n");
    uart_print("init 0\r\n");

    //check_turbo();
    // uart_print("port_0xeff7 = 0x10 (3500kHz CPU clock)\r\n");
    // port_0xeff7 = 0x10; 
    //check_read_port();
    check_mem();
    uart_print("port_0xeff7 = 0x01\r\n");
    port_0xeff7 = 0x01;
    check_mem();
    uart_print("port_0xeff7 = 0x00\r\n");
    port_0xeff7 = 0x00;

    //print(10, 10, msg);

    // PSG init
    port_0xfffd = 0x07;
    port_0xbffd = 0x38;
    port_0xfffd = 0x08;
    port_0xbffd = 0x0a;


    while(1) {
        //*(screen + 4) = key[0];
        //*(screen + 6) = key[1];

        // if(irq_0x38_flag) {
        //     irq_0x38_flag = 0;
        //     *(screen + 0) = i++;
        //     port_0xfffd = 0x00;
        //     port_0xbffd = i;
        // }

        // if(nmi_0x66_flag) {
        //     nmi_0x66_flag = 0;
        //     *(screen + 2) = i;
        // }

        char tmp[] = " ";
        //uart_get(&tmp);
        if(uart_get(&tmp[0]) == 0) {
            uart_print(tmp);
            switch (tmp[0])
            {
            case '1':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                break;
            case '2':
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;  
            case '3':
                    uart_print("check_mem\r\n");
                    check_mem();
                break;
            case '4':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                    uart_print("fill video mem 0x00\r\n");
                    for(unsigned int r = 0x8000; r < 0xffff; r++) {
                        *(char*)r = (char)0x00;
                    }
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;
            case '5':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                    uart_print("fill video mem pattern\r\n");
                    for(unsigned int r = 0x8000; r < 0xffff; r++) {
                        *(char*)r = (char)0x00;
                    }
                    for(unsigned int r = 0x9000; r < 0xa000; r++) {
                        if(r&1) *(char*)r = (char)0xff;
                        else *(char*)r = (char)0x00;
                    }
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;
            case '6':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                    uart_print("fill video mem 0x55\r\n");
                    for(unsigned int r = 0x8000; r < 0xffff; r++) {
                        *((char*)r) = (char)0x55;
                    }
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;
            case '7':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                    uart_print("fill video mem r\r\n");
                    for(unsigned int r = 0x8000; r < 0xffff; r++) {
                        *(char*)r = (char)r;
                    }
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;
            case '8':
                    uart_print("port_0xeff7 = 0x01\r\n");
                    port_0xeff7 = 0x01;
                    uart_print("fill video mem 0x00\r\n");
                    for(unsigned int r = 0x8000; r != 0xffff; r++) {
                        *(char*)r = (char)0x00;
                    }
                    *(char*)0xffff = (char)0x00;
                    uart_print("set dots\r\n");
                    *(char*)(0x9000+offset) = 0x74;
                    *(char*)(0x9001+offset) = 0x10;
                    // *(char*)(0x9002+offset) = 0x00;
                    // *(char*)(0x9004+offset) = 0x02;
                    // *(char*)(0x9006+offset) = 0x04;
                    // *(char*)(0x9008+offset) = 0x0f;
                    // *(char*)(0x900a+offset) = 0x0f;
                    
                    uart_print("port_0xeff7 = 0x00\r\n");
                    port_0xeff7 = 0x00;
                break;

            case 'z':
                offset--;
                break;

            case 'x':
                offset++;
                break;

            case 'c':
                offset -= 0x400 ;
                break;

            case 'v':
                offset += 0x400;
                break;

            default:
                break;
            }
            //print(0, 1, tmp);
        } 
    }
}



void init_screen(void) {
    port_0x00fe = 7;
    for (unsigned int i = SCREEN_START_ADR; i < (SCREEN_START_ADR+SCREEN_SIZE); i++) {
        *((char *)i) = 0;
    } 
    for (unsigned int i = SCREEN_START_ADR+SCREEN_SIZE; i < (SCREEN_START_ADR+SCREEN_SIZE+SCREEN_ATR_SIZE); i++) {
        *((char *)i) = 4;
    }
    port_0x00fe = 0;
}



volatile void irq_0x38(void) {
    irq_0x38_flag = 1;

    key[0] = port_0x7ffe;
    key[1] = port_0xeffe;
    key[2] = port_0xbffe;
    key[3] = port_0xdffe;
    key[4] = port_0xf7fe;
    key[5] = port_0xfefe;
    key[6] = port_0xfbfe;
    key[7] = port_0xfdfe;

}

volatile void nmi_0x66(void) {
    nmi_0x66_flag = 1;
}


void check_turbo(void) {
    for(char n = 0; n < 8; n++) {
        uart_print("port_0xeff7 = 0x00 (7000kHz CPU clock)\r\n");
        port_0xeff7 = 0x00;
        delay(32768);
        
        uart_print("port_0xeff7 = 0x10 (3500kHz CPU clock)\r\n");
        port_0xeff7 = 0x10; 
        delay(16384);     
    }
    uart_print("cpu clock test end\r\n");
}

void check_read_port(void) {
    uart_print("write 0xeff7 0xff\r\n");
    port_0xeff7 = 0xff;
    uart_print("read 0xeff7");
    if(port_0xeff7 != 0xff) uart_print(" FAIL\r\n");
    else uart_print(" OK\r\n");

    uart_print("write 0xeff7 0x00\r\n");
    port_0xeff7 = 0x00;
    uart_print("read 0xeff7");
    if(port_0xeff7 != 0x00) uart_print(" FAIL\r\n");
    else uart_print(" OK\r\n");
    uart_print("\r\n");
}

void check_mem(void) {

    uart_print("write @ 0x3fff 0x55\r\n");
    *(char*)0x3fff = 0x55;
    uart_print("read @ 0x3fff");
    if(*(char*)0x3fff == 0x55) uart_print(" OK\r\n");
    else uart_print(" FAIL\r\n");
    uart_print("\r\n");

    uart_print("write @ 0x8000 0x55\r\n");
    *(char*)0x8000 = 0x55;
    uart_print("read @ 0x8000");
    if(*(char*)0x8000 == 0x55) uart_print(" OK\r\n");
    else uart_print(" FAIL\r\n");
    uart_print("\r\n");

    uart_print("write @ 0x8004 0x55\r\n");
    *(char*)0x8004 = 0x55;
    uart_print("read @ 0x8004");
    if(*(char*)0x8004 == 0x55) uart_print(" OK\r\n");
    else uart_print(" FAIL\r\n");
    uart_print("\r\n");

    uart_print("write @ 0x8005 0x55\r\n");
    *(char*)0x8005 = 0x55;
    uart_print("read @ 0x8005");
    if(*(char*)0x8005 == 0x55) uart_print(" OK\r\n");
    else uart_print(" FAIL\r\n");
    uart_print("\r\n");

    uart_print("write @ 0x8006 0x55\r\n");
    *(char*)0x8006 = 0x55;
    uart_print("read @ 0x8006");
    if(*(char*)0x8006 == 0x55) uart_print(" OK\r\n");
    else uart_print(" FAIL\r\n");
    uart_print("\r\n");

    for(unsigned int r = 0x8000; r < 0xffff; r++) {
        *(char*)r = (char)r;
        //if(*(char*)r != 0x55) uart_print("*");
    }
    uart_print("\r\n"); 
    uart_print("RAM test end\r\n"); 
}

