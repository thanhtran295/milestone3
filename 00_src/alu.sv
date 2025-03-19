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