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



void main() {
    port_0x7ffd = 0x00;
    uart_init();
    init_screen();
    uart_print("\r\n\r\n***********************\r\n");
    uart_print("init 0\r\n");
    for(char n = 0; n < 8; n++) {
        uart_print("port_0xeff7 = 0x00 (7000kHz CPU clock)\r\n");
        port_0xeff7 = 0x00;
        delay(32768);
        
        uart_print("port_0xeff7 = 0x10 (3500kHz CPU clock)\r\n");
        port_0xeff7 = 0x10; 
        delay(16384);     
    }
    uart_print("test end\r\n");
    //print(10, 10, msg);

    // PSG init
    port_0xfffd = 0x07;
    port_0xbffd = 0x38;
    port_0xfffd = 0x08;
    port_0xbffd = 0x0a;


    while(1) {
        //*(screen + 4) = key[0];
        //*(screen + 6) = key[1];

        if(irq_0x38_flag) {
            irq_0x38_flag = 0;
            *(screen + 0) = i++;
            port_0xfffd = 0x00;
            port_0xbffd = i;
        }

        if(nmi_0x66_flag) {
            nmi_0x66_flag = 0;
            *(screen + 2) = i;
        }

        char tmp[] = " ";
        //uart_get(&tmp);
        if(uart_get(&tmp[0]) == 0) {
            uart_print(tmp);
            print(0, 1, tmp);
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

// https://gist.github.com/Konamiman/af5645b9998c802753023cf1be8a2970
