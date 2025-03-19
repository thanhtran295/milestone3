module shifter_left (
    input [31:0] a_in,
    input [4:0] shamt,
    output [31:0] a_out
); 


//Shift left 
logic [31:0] a_left_1b; 
logic [31:0] a_left_2b; 
logic [31:0] a_left_4b; 
logic [31:0] a_left_8b; 
logic [31:0] a_left_16b;

// Shift 1 bit 
assign a_left_1b = shamt[0] ? {a_in[30:0], 1'b0} : a_in;
// Shift 2 bits
assign a_left_2b = shamt[1] ? {a_left_1b[29:0], 2'b0} : a_left_1b;
// Shift 4 bits
assign a_left_4b = shamt[2] ? {a_left_2b[27:0], 4'b0} : a_left_2b;
// Shift 8 bits
assign a_left_8b = shamt[3] ? {a_left_4b[23:0], 8'b0} : a_left_4b;
// Shift 16 bits
assign a_left_16b = shamt[4] ? {a_left_8b[15:0], 16'b0} : a_left_8b;

// Cout 
assign a_out = a_left_16b;

endmodule 
