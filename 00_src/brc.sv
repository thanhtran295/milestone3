module brc (
    input  logic [31:0] i_rs1_data, // rs1 register 
    input  logic [31:0] i_rs2_data, // rs2 register
    input logic  i_br_un,    // i_br_un = 0 --> unsigned ; i_br_un = 1 --> signed
    output logic  o_br_less,   // Less result
    output logic  o_br_equal   // equal result
);

assign o_br_equal = ~|(i_rs1_data ^ i_rs2_data);

logic cout_path; 
logic [31:0] sum_path; 
logic signA, signB, signDiff, overflow;

adder adder_0 (
    .op_a(i_rs1_data),
    .op_b(~i_rs2_data),
    .cin(1'b1),
    .sum(sum_path),
    .cout(cout_path)
);

always_comb begin
    // Compute A - B
    case (i_br_un)
    1'b1: begin 
        signA = i_rs1_data[31]; 
        signB = i_rs2_data[31];
        signDiff = sum_path[31]; 
        overflow = (signA ^ signB) & (signDiff ^ signA);  
        o_br_less = signDiff ^ overflow;
    end

    1'b0: begin 
        // A - B => if carry_out=0 => A < B
        o_br_less = ~cout_path;
    end

    default: begin 
        o_br_less = ~cout_path;
    end 
    endcase 
end 

endmodule 