module video (
input CLK,
input RESET,
input [7:0] Q,
input C17, C3, C18, C1, C2,
output R, G, B, I,
output test

);

wire [7:0] DD37_Q;
ir23 DD37(.D(Q), .C(C17), .OE(1'b0), .Q(DD37_Q));

wire [7:0] DD40_Q;
ir23 DD40(.D(DD37_Q), .C(C3), .OE(1'b0), .Q(DD40_Q));

wire [7:0] DD38_Q;
ir23 DD38(.D(Q), .C(C18), .OE(1'b0), .Q(DD38_Q));

wire [3:0] DD41_Q;
ir16 DD41(.D({DD38_Q[3], DD38_Q[2], DD38_Q[1], DD38_Q[0]}), .DI(1'b0), .C(C1), .PE(C2), .OE(1'b1), .Q(DD41_Q));

wire [3:0] DD42_Q;
ir16 DD42(.D({DD38_Q[7], DD38_Q[6], DD38_Q[5], DD38_Q[4]}), .DI(DD41_Q[3]), .C(C1), .PE(C2), .OE(1'b1), .Q(DD42_Q));

reg [31:0] flash_cnt = 0;

always @(negedge CLK) begin
	flash_cnt = flash_cnt + 1;
end

//kp2 DD46()

assign R = DD42_Q[3];
assign G = C1;//DD41_Q[2];
assign B = C2;//DD41_Q[1];
assign I = C18;//DD41_Q[0];

assign test = flash_cnt[23];

endmodule

/////// IR23
module ir23(
input [7:0] D,
input C, OE,
output [7:0] Q
);
reg [7:0] data = 8'b0;
	always @(posedge C) begin
		data = D;
	end
assign Q = OE?(8'bz):(data);
endmodule

/////// IR16
module ir16(
input [3:0] D,
input DI, C, PE, OE,
output [3:0] Q
);
reg [3:0] data = 4'b0;
	always @(negedge C) begin
		if (PE) data <= D;
		else data <= {data[2:0], DI};
		
	end
assign Q = OE?(data):(4'bz);
endmodule

////// KP2
module kp2(
input [3:0] A,
input EA,
input [3:0] B,
input EB,
input S1, S2,
output AY, BY
);
wire adr = {S2, S1};
reg Ad = 1'b0, Bd = 1'b0;

always @* begin 
	case (adr)
		2'b00: begin Ad = EA?(1'b0):(A[0]); Bd = EB?(1'b0):(A[0]); end 
		2'b01: begin Ad = EA?(1'b0):(A[1]); Bd = EB?(1'b0):(A[1]); end 
		2'b10: begin Ad = EA?(1'b0):(A[2]); Bd = EB?(1'b0):(A[2]); end 
		2'b11: begin Ad = EA?(1'b0):(A[3]); Bd = EB?(1'b0):(A[3]); end 
	endcase
end

assign AY = Ad;
assign BY = Bd;

endmodule
// Dual 4-input multiplexer

/*module kp2 #(parameter BLOCKS = 2, WIDTH_IN = 4, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
  begin
    if (!Enable_bar[i])
      computed[i] = A[i][Select];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

//`ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule*/