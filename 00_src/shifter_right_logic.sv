module shifter_right_logic (
    input [31:0] a_in,
    input [4:0] shamt,
    output [31:0] a_out
); 


//Shift right 
logic [31:0] a_right_1b; 
logic [31:0] a_right_2b; 
logic [31:0] a_right_4b; 
logic [31:0] a_right_8b; 
logic [31:0] a_right_16b;

// Shift 1 bit 
assign a_right_1b = shamt[0] ? {1'b0,a_in[31:1]} : a_in;
// Shift 2 bits
assign a_right_2b = shamt[1] ? {2'b0, a_right_1b[31:2]} : a_right_1b;
// Shift 4 bits
assign a_right_4b = shamt[2] ? {4'b0, a_right_2b[31:4]} : a_right_2b;
// Shift 8 bits
assign a_right_8b = shamt[3] ? {8'b0, a_right_4b[31:8]} : a_right_4b;
// Shift 16 bits
assign a_right_16b = shamt[4] ? {16'b0, a_right_8b[31:16]} : a_right_8b;

// Cout 
assign a_out = a_right_16b;

endmodule 
