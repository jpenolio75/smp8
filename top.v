module top1 (
						input [3:0] jump_instr_in,
						
						input clk, reset,
						output z_flag_out,
						output [7:0] alu_out);
						
            wire [1:0] select_mux;
            wire WE, jump_mux_select;
            wire [3:0] select;
						wire [7:0] RI, RD, ac_out, reg_out, mux_out;
						wire [3:0] pcplus, adder_out, one_two_mux_out, jump_mux_out, one, two; 
						wire one_two_mux_select, nor_out;


assign one = 4'b0001;														//Drives one_two_mux for program counter
assign two	 = 4'b0010;														//
assign one_two_mux_select = 1'b0;											// Hard codes one_two_mux to increment by 1

mux one_two_mux (one, two,one_two_mux_select, one_two_mux_out);				//Mux for program counter
adder pcadder   (pcplus, one_two_mux_out, adder_out);						//Adder for program counter
mux jump_mux    (jump_instr_in, adder_out, jump_mux_select, jump_mux_out); //Selects between pc+1 signal or jump signal
flip_flop_pc pc_ff ( clk, reset, jump_mux_out, pcplus);               //flip flop                               


dAndImem mem( clk, WE, RI[3:0], pcplus, RI[3:0],ac_out, RD, RI);         //Dmem/Imem                                           
mux_3to1 mux	(alu_out, RD, reg_out, select_mux, mux_out);			//Selects between alu_out, RD (from memory), or reg_out
alu Alu_module  (ac_out, reg_out, select, alu_out);						
reg8 Acc_module (reset, clk, mux_out, ac_out);							//Accumulator
reg8 Reg_module (reset, clk, ac_out, reg_out); 							//Register
nor_gate z_flag (alu_out, nor_out);										//Nor gate
flip_flop z_flag_ff (clk, reset, nor_out, z_flag_out);   				//flip flop
control c(z_flag_out, RI[7:4], select_mux, select, jump_mux_select, WE);



endmodule 
 
module flip_flop_pc (
  input clk,
  input reset,
  input [3:0] d,
  output reg [3:0] q
);
initial q = 4'b0000; 
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      q <= 4'b0000;
    end else begin
      q <= d;
    end
	end
 
endmodule
 
module mux (input [3:0] D0, D1, input S,
output [3:0] Y);
assign Y = S ? D1: D0;
endmodule
 
module adder (input [3:0] a,b, output [3:0] y);
assign y = a+b;
endmodule


module dAndImem    (input        clk, We,
					input  [3:0] RDA, RIA, Wa, 
					input  [7:0] W_data, 
					output [7:0] Rd, Ri);
					
  reg [7:0] mem[31:0];
  assign Ri = mem[{1'b0, RIA}]; 
  assign Rd = mem[{1'b1, RDA}];
  
  initial 
  $readmemb ("testprogram.dat", mem);
  
  
  always @ (posedge clk)
    if (We) mem[{1'b1, Wa}] <= W_data;

endmodule

/////////////////////////////////////////////////////////

module alu_registers (input clk, reset,  
					  input [1:0] select_mux,
					  input [3:0] select,
					  input [7:0] mux_in_2,
					  output z_flag_out,
					  output [7:0] alu_out);
wire nor_out ;
wire [7:0] ac_out, reg_out, mux_out;



mux_3to1 mux3to1	(alu_out, mux_in_2, reg_out, select_mux, mux_out);
alu Alu_module  (ac_out, reg_out, select, alu_out);
reg8 Acc_module (reset, clk, mux_out, ac_out);
reg8 Reg_module (reset, clk, ac_out, reg_out); 
nor_gate z_flag (alu_out, nor_out);
flip_flop z_flag_ff (clk, reset, nor_out, z_flag_out);   
endmodule

module mux_3to1(input [7:0] data_in_a, data_in_b, data_in_c,
                input [1:0] select,
               output reg [7:0] data_out);
    
    always @(*)
        case (select)
            2'b00: data_out = data_in_a;
            2'b01: data_out = data_in_b;
            2'b10: data_out = data_in_c;
            default: data_out = 1'b0;
        endcase
    
endmodule


module reg8 (reset, CLK, D, Q);
input reset;
input CLK;
input [7:0] D;
output [7:0] Q;
reg [7:0] Q;
always @(posedge CLK)
if (reset)
Q = 0;
else
Q = D;
endmodule // reg8


module alu(AC,R,SEL,OUT);
    input [7:0] AC,R;
    input [3:0] SEL;
    output reg [7:0] OUT;
    always @ (*) begin
        case(SEL)
            4'b0001: OUT = AC + R; //ADD
            4'b0010: OUT = AC - R; //SUB
            4'b0011: OUT = AC + 1; //INAC
            4'b0100: OUT = 0;      //CLAC
            4'b0101: OUT = AC & R; //AND
            4'b0110: OUT = AC | R; //OR
            4'b0111: OUT = AC ^ R; //XOR
            4'b1000: OUT = ~AC;    //NOT
            default: OUT = 8'bXXXXXXXX;
        endcase
    end
endmodule

module nor_gate (
  input [7:0] a,
  output reg out
);

  always @*
    out = ~(|a);

endmodule

module flip_flop (
  input clk,
  input reset,
  input  d,
  output reg q
);
initial q = 1'b0; 
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
	end
endmodule

module control (input z_flag_in, 
                input [3:0] op, 
                output [1:0] selectmux,
                output [3:0] sel, 
                output jumpmuxselect, we);

  reg [7:0] controls;
  assign {we, jumpmuxselect, selectmux, sel}  = controls;

  always @ (* )
  case({z_flag_in,op})
    5'b00000 :  controls <= 8'b01000000;         //NOP 
    5'b00001 :  controls <= 8'b01010000;         //LDAC
    5'b00010 :  controls <= 8'b11000000;         //STAC
    5'b00011 :  controls <= 8'b01000000;         //MVAC
    5'b00100 :  controls <= 8'b01100000;         //MOVR
    5'b00101 :  controls <= 8'b00000000;         //JUMP
    5'b10110 :  controls <= 8'b00000000;         //JMPZ
    5'b00111 :  controls <= 8'b00000000;         //JPNZ
    5'b01000 :  controls <= 8'b01000001;         //ADD
    5'b01001 :  controls <= 8'b01000010;         //SUB
    5'b01010 :  controls <= 8'b01000011;         //INAC
    5'b01011 :  controls <= 8'b01000100;         //CLAC
    5'b01100 :  controls <= 8'b01000101;         //AND
    5'b01101 :  controls <= 8'b01000110;         //OR
    5'b01110 :  controls <= 8'b01000111;         //XOR
    5'b01111 :  controls <= 8'b01001000;         //NOT
    default :   controls <= 8'b00000000;         //???

  endcase

endmodule