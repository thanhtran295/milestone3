module imm_gen(
    input logic     [31:7]  inst, 
    input logic     [1:0]   i_imm_sel,
    output logic    [31:0]  o_imm
);
    
    always_comb begin 
        case(i_imm_sel) 
            2'b00: o_imm = {{20{inst[31]}}, inst[31:20]};//signed extended
            default: o_imm = 32'dx;
        endcase
    end 
    
endmodule
