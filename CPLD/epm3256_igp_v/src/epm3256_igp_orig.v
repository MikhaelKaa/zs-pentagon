module epm3256_igp_orig (
	// Main Clock
	input 	CLK_14MHZ,

	// CPU signals
	input 	CPU_IORQ,
	input 	CPU_MREQ,
	input 	CPU_WR,
	input 	CPU_RD,
	input 	CPU_M1,
	input 	CPU_RFSH,
	input 	CPU_RESET,

	output 	CPU_CLK,
	output 	CPU_INT,
	output 	CPU_BUSRQ,
	output 	CPU_WAIT,
	output 	CPU_NMI,
	
	// CPU address & data
	inout  [7:0] D,	
	input [15:0] A,
	
	// BBSRAM
	output BBSRAM_RD,
	output BBSRAM_WR,
	output BBSRAM_MREQ,

	// Main RAM 1024k
	output WR_RAM,
	output CS_RAM1,
	output CS_RAM0,
	inout [7:0] MD,
	output [18:0]MA,
	
	// ROM
	output ROM_A14, // TODO: ROM_A_H[5],
	output ROM_A15,
	output ROM_A16,
	output ROM_A17,
	output ROM_A18,
	output WR_ROM,
	output RD_ROM,
	output CS_ROM,
	
	// Video output
	output [7:0]VGA, //TODO -2
	output HS,
	output VS,
	output SGI,
	
	// DOS
	output 	C_DOS,
	output 	C_IODOS,

	// 
	input 	C_IORQGE,
	output 	C_BLK,

	//
	output [14:0]VA,
	inout [7:0]VD, // [5:0] ->> [7:0] ?
	output VWR,

	// Port FE
	output BEEP,
	output TAPE_OUT,
	input TAPE_IN,
	
	// Joystick select
	output RD_1F,

	// USB/PS2/SEGAGP controller
	input 	C_MAGIC,
	input 	C_PNT,
	input 	C_TURBO,
	// SPI 
	input 	KBD_DI,
	input 	KBD_CS,
	input 	KBD_CLK,

	// stm32 bluepill device
	input STM32_BUSRQ, 	// EXT0,
	input EXT1,				// RESET. The signal passes by. Disabling requires hardware modification of the hat, do not use this pin (signal) !
	
	// EXT pins.
	output EXT2,  // LED
	output EXT3

	// PSG
	//output AYCLK,
	//output BDIR,
	//output BC1,
);
/*
	reg [3:0] EX_RGBI_PIX = 4'b0;
	reg [7:0] EX_RGBI_DATA = 8'b0;
	reg [19:0] EX_RGBI_cnt = 20'b0;
	reg [14:0] EX_RGBI_ADR = 15'b0;
	reg pre_VWR = 1'b0;
	
	reg [7:0] cnt = 8'b0;
	always @(negedge CLK_14MHZ) begin
		cnt = cnt + 1'b1;
		
		if(cnt[0]) begin
			pre_VWR <= 1'b0;
			VD <= EX_RGBI_cnt[9:2];
			EX_RGBI_ADR <= EX_RGBI_cnt;
			
		end else begin 
			pre_VWR <= 1'b1;
			EX_RGBI_DATA <= VD;
			
			if(KSI) begin
				EX_RGBI_cnt <= 0;	
			end else begin
				EX_RGBI_cnt <= EX_RGBI_cnt + 1'b1;
				EX_RGBI_ADR <= EX_RGBI_cnt[15:1];
				EX_RGBI_PIX <= EX_RGBI_DATA[3:0];
			end
		
		end	
		
	end 
	
	always @(negedge cnt[0]) begin

	end 
*/
	
	/******************** CPU ***********************/	
	// CPU data bus
	//assign D = CPU_RD?(8'bz):(MD);	
	assign D = 8'bz;	
	
	// CPU clock
	assign CPU_CLK   = C25;
	
	// TODO: NMI IODOS перепутаны
	assign C_IODOS = 1'b1;
	assign CPU_NMI   = 1'b1;
	
	
	assign CPU_INT   = C8;
	assign CPU_BUSRQ = STM32_BUSRQ; //1'b1;
	assign CPU_WAIT  = 1'b1;

	
	/***************** BBSRAM 32kb ******************/	
	assign BBSRAM_RD    = CPU_RD | A[15];
	assign BBSRAM_WR    = STM32_BUSRQ?(CPU_WR | (A < 16'h4000) | A[15]):(CPU_WR | A[15]);
	assign BBSRAM_MREQ  = CPU_MREQ | A[15]; 
	// BBRAM data connect to cpu data
	// BBRAM adr connect to cpu adr [14:0]
	
	
	/********** ext RAM W24257AK-20 32kb ************/
	assign VA = A[14:0];
	assign VD = 8'bz;//(CPU_WR | CPU_MREQ )?(8'bz):(D);
	//assign D  = (CPU_RD | CPU_MREQ )?(8'bz):(VD);
	assign VWR = CPU_WR | CPU_MREQ ;
	
	//assign VA = EX_RGBI_ADR;
	////assign VD = 8'bz;
	//assign VWR = pre_VWR;
	
	
	/***************** RAM 1024k ********************/	
	// RAM address  
	assign MA = {A, 3'b1};// 19'bx;
	//assign MD = (CPU_WR | CPU_MREQ)?(8'bz):(D);
	//assign D  = (CPU_RD | CPU_MREQ)?(8'bz):(MD);
	assign WR_RAM  = 1'b1;//CPU_WR | CPU_MREQ;
	assign CS_RAM0 = 1'b1;//CPU_MREQ;
	assign CS_RAM1 = 1'b1;//CPU_MREQ;//~CS_RAM0;
	
	
	/******************* ROM 512k *******************/
	assign ROM_A14 = 1'b0;
	assign ROM_A15 = 1'b0;
	assign ROM_A16 = 1'b0;
	assign ROM_A17 = 1'b0;
	assign ROM_A18 = 1'b0;
	
	assign WR_ROM = 1'b1;
	assign RD_ROM = 1'b1;//CPU_MREQ | C13;  //OE
	assign CS_ROM = 1'b1;//CPU_RD;
	

	/**************** Video output ******************/	
	assign VGA = {1'b0, I, G, 1'b0, I, R, I, B};
	//                  I               G                     I               R               I               B
	//assign VGA = {1'b0, EX_RGBI_PIX[0], EX_RGBI_PIX[2], 1'b0, EX_RGBI_PIX[0], EX_RGBI_PIX[3], EX_RGBI_PIX[0], EX_RGBI_PIX[1]};
	// Vertical sync
	assign VS = SYNC;
	// TODO: in Jasper this pin use to enable scart
	assign HS = 1'b1;
	// Not used.
	assign SGI = 1'b0;

	
	// port 
	assign BEEP = SOUND;
	assign TAPE_OUT = TAPEOUT;

	//
	assign RD_1F = 1'b1;
	
	assign C_DOS = 1'b0;
	
	
	//
	wire test_pin;
	
	assign EXT2 = reg_fe[0];//CAS_n;
	assign EXT3 = C1;
	
	
	// io
	wire iowr = CPU_IORQ | CPU_WR ;//| ~m1;
	wire iord = CPU_IORQ | CPU_RD ;//| ~m1;
	
	// register fe (gpio)
	reg [7:0] reg_fe = 8'b0;
	// register ff (PWM)
	reg [7:0] reg_ff = 8'b0;
	
	always @(negedge iowr) begin
		if(A[7:0] == 8'hfe) reg_fe = D;
	end
	

	// PSG <---- Deleted. This pins now BBSRAM RWIO.
	//assign AYCLK = 1'bz;
	//assign BDIR = 1'bz;
	//assign BC1 = 1'bz;

	// CPU reset
	wire C39 = CPU_RESET;
	
	wire C1, C25, C2, C31, C3, B1, B2, B3, B4, B5, B6, SSI, B7, B8, B9, B10, B11, B12, B13, C6, KSI, C7, BL, C5, C8, RAS, RAS_n, CAS, CAS_n, B14, B15, B16, B17;
	pent_gen gen (.clk14m(CLK_14MHZ), .C30(C30),
	.C1(C1), .C25(C25), .C2(C2), .C31(C31), .C3(C3), .B1(B1), .B2(B2), .B3(B3), .B4(B4), .B5(B5), .B6(B6), .SSI(SSI), .B7(B7), .B8(B8), .B9(B9), .B10(B10), .B11(B11),
	.B12(B12), .B13(B13), .C6(C6), .KSI(KSI), .C7(C7), .BL(BL), .C5(C5), .C8(C8), .RAS(RAS), .RAS_n(RAS_n), .CAS(CAS), .CAS_n(CAS_n), .B14(B14), .B15(B15), .B16(B16), .B17(B17));
	
	wire RD, C19, C16, C20, C13, CPU, DIS, C29, C17, C30, C18, B18;
	pent_log logicz(.B13(B13), .RD_n(CPU_RD), .RAS(RAS), .MREQ(CPU_MREQ), .A15(A[15]), .A14(A[14]), .CAS_n(CAS_n), .RFS(CPU_RFSH), 
	.RD(RD), .C19(C19), .C16(C16), .C20(C20), .C13(C13), .CPU(CPU), .DIS(DIS), .C29(C29), .C17(C17), .C30(C30), .C18(C18), .B18(B18));
	
	
	wire C33, C34, C35, C36, C37, C38;
	pent_logic_0 port7ffd  ( .D(D[5:0]), .C39(C39), .A14(A[14]), .IORQn(CPU_IORQ), .WRn(CPU_WR),.A1(A[1]), .A15(A[15]), .CAS(CAS), .DIS(DIS),
	.C33(C33), .C34(C34), .C35(C35), .C36(C36),.C37(C37),.C38(C38));


	wire K9, K10, K11, TAPEOUT, SOUND;
	pent_logic_1 logi(.D(D[4:0]), .WRn(CPU_WR), .A0(A[0]), .IORQn(CPU_IORQ), .RD(RD),
	.K9(K9), .K10(K10), .K11(K11), .TAPEOUT(TAPEOUT), .SOUND(SOUND));

	wire R, G, B, I, SYNC;
	video video0(.Q(MD), .C17(C17), .C3(C3), .C18(C18), .C1(C1), .C2(C2), .K9(K9), .K10(K10), .K11(K11), .BL(BL), .C5(C5), .C7(C7), .FLASHER(flash_gen),
	.R(R), .G(G), .B(B), .I(I), .SYNC(SYNC), .test_pin(test_pin));
	
endmodule

//set_location_assignment PIN_3 -to B
/*
set_location_assignment PIN_99 -to C_IODOS
set_location_assignment PIN_98 -to CA6
set_location_assignment PIN_97 -to CA7
set_location_assignment PIN_96 -to C_M1
set_location_assignment PIN_95 -to CA5
set_location_assignment PIN_93 -to C_RFSH
set_location_assignment PIN_92 -to CA4
set_location_assignment PIN_91 -to CA8
set_location_assignment PIN_90 -to CS_ROM
set_location_assignment PIN_9 -to KBD_CLK
set_location_assignment PIN_89 -to CA10
set_location_assignment PIN_87 -to CA11
set_location_assignment PIN_86 -to CA9
set_location_assignment PIN_81 -to MA2
set_location_assignment PIN_79 -to MA1
set_location_assignment PIN_78 -to MA10
set_location_assignment PIN_77 -to MA3
set_location_assignment PIN_76 -to MA4
set_location_assignment PIN_73 -to MA11
set_location_assignment PIN_71 -to MA5
set_location_assignment PIN_70 -to MA9
set_location_assignment PIN_7 -to HS
set_location_assignment PIN_69 -to MA6
set_location_assignment PIN_68 -to MA8
set_location_assignment PIN_67 -to MA7
set_location_assignment PIN_66 -to MA13
set_location_assignment PIN_65 -to MA12
set_location_assignment PIN_61 -to MD4
set_location_assignment PIN_60 -to MD6
set_location_assignment PIN_59 -to MD5
set_location_assignment PIN_58 -to ROM_A15
set_location_assignment PIN_55 -to RD_1F
set_location_assignment PIN_49 -to WR_RAMMA11
set_location_assignment PIN_48 -to MA14
set_location_assignment PIN_47 -to CE_RAM2
set_location_assignment PIN_46 -to MA16
set_location_assignment PIN_45 -to MA15
set_location_assignment PIN_43 -to MA0
set_location_assignment PIN_42 -to MD7
set_location_assignment PIN_4 -to VD1
set_location_assignment PIN_39 -to RD_ROM
set_location_assignment PIN_38 -to CS_RAML
set_location_assignment PIN_37 -to MD0
set_location_assignment PIN_36 -to ROM_A14
set_location_assignment PIN_35 -to MD1
set_location_assignment PIN_33 -to MD2
set_location_assignment PIN_31 -to WR_ROM
set_location_assignment PIN_3 -to KBD_DI
set_location_assignment PIN_27 -to MD3
set_location_assignment PIN_206 -to VD0
set_location_assignment PIN_204 -to VD7
set_location_assignment PIN_203 -to C_MAGIC
set_location_assignment PIN_202 -to VD6
set_location_assignment PIN_199 -to VD5
set_location_assignment PIN_197 -to VD4
set_location_assignment PIN_195 -to VD3
set_location_assignment PIN_193 -to VD2
set_location_assignment PIN_188 -to GI
set_location_assignment PIN_184 -to CLK_14MHZ
set_location_assignment PIN_183 -to C_WR
set_location_assignment PIN_182 -to C_RESET
set_location_assignment PIN_181 -to C_MREQ
set_location_assignment PIN_18 -to KBD_CS
set_location_assignment PIN_178 -to TAPE_IN
set_location_assignment PIN_177 -to BBSRAM_MREQ //AYCLK <---
set_location_assignment PIN_175 -to CD2
set_location_assignment PIN_173 -to CD0
set_location_assignment PIN_172 -to C_BLK
set_location_assignment PIN_171 -to CA12
set_location_assignment PIN_170 -to TAPE_OUT
set_location_assignment PIN_169 -to BBSRAM_WR //BDIR <---
set_location_assignment PIN_168 -to BEEP
set_location_assignment PIN_167 -to BBSRAM_RD //BC1 <---
set_location_assignment PIN_166 -to CA15
set_location_assignment PIN_164 -to CA14
set_location_assignment PIN_163 -to CA13
set_location_assignment PIN_162 -to VWR
set_location_assignment PIN_161 -to CD7
set_location_assignment PIN_160 -to PA13
set_location_assignment PIN_159 -to C_DOS
set_location_assignment PIN_154 -to PA8
set_location_assignment PIN_153 -to CD1
set_location_assignment PIN_151 -to CD5
set_location_assignment PIN_150 -to CD6
set_location_assignment PIN_149 -to PA14
set_location_assignment PIN_148 -to PA9
set_location_assignment PIN_147 -to PA12
set_location_assignment PIN_145 -to PA7
set_location_assignment PIN_144 -to PA11
set_location_assignment PIN_141 -to PA6
set_location_assignment PIN_140 -to CA0
set_location_assignment PIN_139 -to PA5
set_location_assignment PIN_138 -to CA1
set_location_assignment PIN_137 -to PA4
set_location_assignment PIN_135 -to PA3
set_location_assignment PIN_133 -to CA2
set_location_assignment PIN_132 -to PA2
set_location_assignment PIN_131 -to CA3
set_location_assignment PIN_130 -to CD3
set_location_assignment PIN_129 -to CD4
set_location_assignment PIN_128 -to C_CLK
set_location_assignment PIN_126 -to C_IORQGE
set_location_assignment PIN_124 -to PA1
set_location_assignment PIN_122 -to PA0
set_location_assignment PIN_120 -to PD0
set_location_assignment PIN_118 -to PD1
set_location_assignment PIN_117 -to C_INT
set_location_assignment PIN_115 -to PD2
set_location_assignment PIN_114 -to PD5
set_location_assignment PIN_112 -to PD4
set_location_assignment PIN_111 -to C_IORQ
set_location_assignment PIN_110 -to PD3
set_location_assignment PIN_109 -to C_BUSRQ
set_location_assignment PIN_102 -to C_RD
set_location_assignment PIN_101 -to C_WAIT
set_location_assignment PIN_100 -to C_NMI
set_location_assignment PIN_10 -to VS

output C_INT
output C_IODOS
output C_NMI
output PA13
output CE_RAM2
output VWR
output PA14
output PA12
output PA11
output PA9
output PA8
output PA7
output PA6
output PA5
output PA4
output PA3
output PA2
output PA1
output PA0
inout  PD5
inout  PD4
inout  PD3
inout  PD2
inout  PD1
inout  PD0
output BDIR
output BC1
output AYCLK
output C_BUSRQ
output C_WAIT
inout  MD7
output MA0
output MA15
output MA16
output MA14
output WR_RAM
inout  MD3
input KBD_CLK
output HS
output RD_1F
output VD7
output VD6
output VD5
output VD4
output VD3
output VD2
output VD1
output VD0
output GI
input KBD_CS
output CS_RAML
inout  MD0
output ROM_A14
inout  MD1
inout  MD2
output WR_ROM
output MA10
output MA3
output MA4
output MA11
output MA5
output MA9
output MA6
output MA8
output MA7
output MA13
input KBD_DI
input C_MAGIC
output VS
output RD_ROM
output MA12
inout  MD4
inout  MD6
inout  MD5
output ROM_A15
inout  CD1
output C_DOS
inout  CD7
input CA13
input CA14
input CA15
inout  CD6
inout  CD5
input C_IORQ
input CA4
input C_RFSH
input CA5
input C_M1
input CA7
input CA6
input C_RD
output BEEP
output TAPE_OUT
input CA12
output C_BLK
inout  CD0
inout  CD2
input TAPE_IN
inout  CD3
input CA3
input CA2
input CA1
input CA0
input C_IORQGE
output C_CLK
inout  CD4
output MA1
output MA2
input CA9
input CA11
input CA10
output CS_ROM
input CA8
input C_WR
input C_RESET
input C_MREQ
input CLK_14MHZ

*/