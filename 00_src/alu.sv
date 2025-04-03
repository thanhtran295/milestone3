module alu (
    input  logic [31:0] i_operand_a, // First operand
    input  logic [31:0] i_operand_b, // Second operand
    input  logic [3:0]  i_alu_op,    // ALU operation selector
    output logic [31:0] o_alu_data   // ALU result
);
localparam logic [3:0] ADD  = 4'b0000;
localparam logic [3:0] SUB  = 4'b0001;
localparam logic [3:0] SLT  = 4'b0010;
localparam logic [3:0] SLTU = 4'b0011;
localparam logic [3:0] XOR  = 4'b0100;
localparam logic [3:0] OR   = 4'b0101;
localparam logic [3:0] AND  = 4'b0110;
localparam logic [3:0] SLL  = 4'b0111;
localparam logic [3:0] SRL  = 4'b1000;
localparam logic [3:0] SRA  = 4'b1001;

logic [31:0] b_path; 
logic [31:0] cin_path; 
logic [31:0] b_path_4op; 
logic cin_path_4op; 
logic [31:0] sum_path; 
logic [31:0] shrl_path; 
logic [31:0] shll_path; 
logic [31:0] shra_path; 
logic cout_path; 
logic sel_path; 
logic signA, signB, signDiff, overflow, res;

assign sel_path = (~i_alu_op[3]) & (~i_alu_op[2]) & (i_alu_op[1] | i_alu_op[0]); //chose only SUB, SLT, SLTU opcode 
assign b_path     = sel_path ? (~i_operand_b) : i_operand_b; 
assign cin_path   = sel_path ? 1'b1 : 1'b0; 
 
adder adder_0 (
    .op_a(i_operand_a),
    .op_b(b_path),
    .cin(cin_path),
    .sum(sum_path),
    .cout(cout_path)
);

shifter_right_logic shrl0 (
    .a_in(i_operand_a),
    .shamt(i_operand_b[4:0]),
    .a_out(shrl_path)
);

shifter_left shll0 (
    .a_in(i_operand_a),
    .shamt(i_operand_b[4:0]),
    .a_out(shll_path)
);
shifter_right_arth shra0 (
    .a_in(i_operand_a),
    .shamt(i_operand_b[4:0]),
    .a_out(shra_path)
);
always_comb begin
    case (i_alu_op)

    ADD: begin
        o_alu_data = sum_path[31:0];
    end

    SUB: begin
        o_alu_data = sum_path[31:0];
    end

    SLT: begin
    // Compute A - B
    signA = i_operand_a[31]; 
    signB = i_operand_b[31];
    signDiff = sum_path[31]; 
    overflow = (signA ^ signB) & (signDiff ^ signA);  
    res = signDiff ^ overflow;
    o_alu_data = {31'h0, res};
    end

    SLTU: begin
    // A - B => if carry_out=0 => A < B
    o_alu_data = {31'b0, ~cout_path};
    end
    
    XOR: begin
        o_alu_data = i_operand_a ^ i_operand_b;
    end
    
    OR: begin
        o_alu_data = i_operand_a | i_operand_b;
    end

    AND: begin
        o_alu_data = i_operand_a & i_operand_b;
    end

    SLL: begin
        o_alu_data = shll_path;
    end

    SRL: begin
        o_alu_data = shrl_path;
    end

    SRA: begin
        o_alu_data = shra_path;
    end

    default: begin
        o_alu_data = sum_path[31:0];
    end
    endcase
end

endmodule

module full_adder (
    input a,
    input b,
    input cin, 
    output sum,
    output cout
); 


//Sum 
assign sum = a ^ b ^ cin;

// Cout 
assign cout = (a&b) | ((a^b) & cin);

endmodule 

module shifter_right_arth (
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
assign a_right_1b = shamt[0] ? {a_in[31],a_in[31:1]} : a_in;
// Shift 2 bits
assign a_right_2b = shamt[1] ? {{2{a_right_1b[31]}}, a_right_1b[31:2]} : a_right_1b;
// Shift 4 bits
assign a_right_4b = shamt[2] ? {{4{a_right_2b[31]}}, a_right_2b[31:4]} : a_right_2b;
// Shift 8 bits
assign a_right_8b = shamt[3] ? {{8{a_right_4b[31]}}, a_right_4b[31:8]} : a_right_4b;
// Shift 16 bits
assign a_right_16b = shamt[4] ? {{16{a_right_8b[31]}}, a_right_8b[31:16]} : a_right_8b;

// Cout 
assign a_out = a_right_16b;

endmodule 
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

module adder (
    input  [31:0] op_a,
    input  [31:0] op_b,
    input         cin ,
    output        cout,
    output [31:0] sum
);

logic [31:0]  cout_tmp; 
full_adder fa_0 (
    .a(op_a[0]), 
    .b(op_b[0]),
    .cin(cin),
    .cout(cout_tmp[0]),
    .sum(sum[0])
); 

genvar i; 
generate 
  for (i = 1; i < 32; i++) begin : fa
    full_adder fa_i (
        .a(op_a[i]), 
        .b(op_b[i]),
        .cin(cout_tmp[i-1]),
        .cout(cout_tmp[i]),
        .sum(sum[i])
    ); 
  end 
endgenerate 

assign cout = cout_tmp[31]; 

endmodule 