module imm_gen(
    input logic     [31:7]  i_inst, 
    input logic     [2:0]   i_imm_sel,
    output logic    [31:0]  o_imm
);
    localparam IMM_I_TYPE       =   3'b000; 
    localparam IMM_S_TYPE       =   3'b001; 
    localparam IMM_B_TYPE       =   3'b010; 
    localparam IMM_J_TYPE       =   3'b011; 
    localparam IMM_U_TYPE       =   3'b100;
//    logic imm_0 ; // bit 0 of imm; 
    
//    assign imm_0            =       i_imm_sel[0] ? 1'b0 : i_i_inst[7];
//    assign o_imm[10:5]      =       i_i_inst[31:24];
//    assign o_imm[11]        =       i_imm_sel[1] ? i_i_inst[7] : i_i_inst[31];
//    assign o_imm[4:0]       =       i_imm_sel[0] ? i_i_inst[11:7] : i_i_inst[24:20];
//    assign o_imm[31:12]     =       {20{i_i_inst[31]}};
    always_comb begin 
        case(i_imm_sel) 
            IMM_I_TYPE: o_imm = {{20{i_inst[31]}}, i_inst[31:20]};//signed extended
            IMM_S_TYPE: o_imm = {{20{i_inst[31]}} ,i_inst[31:25], i_inst[11:7]};
            IMM_B_TYPE: o_imm = {{20{i_inst[31]}} ,i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
            IMM_J_TYPE: o_imm = { {11{i_inst[31]}},i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:25], i_inst[24:21], 1'b0};
            IMM_U_TYPE: o_imm = {i_inst[31:12], 12'd0};
            default: o_imm = 32'dx;
        endcase
    end 
    
endmodule
