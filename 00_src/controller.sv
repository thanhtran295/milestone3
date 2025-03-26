module controller(
    input                      i_clk, 
    input                      i_reset, 
    input            [31:0]    i_inst,
    output logic     [3:0]     o_alu_op, 
    output logic               o_reg_wen,
    output logic               o_alu_b_sel, 
    output logic     [1:0]     o_imm_sel,  
    output logic               o_wb_sel, 
    output logic               o_dmem_we, 
    output logic               o_insn_vld    
);
    localparam R_TYPE           =   7'b0110011; 
    localparam R_TYPE_IMM       =   7'b0010011;
    localparam L_TYPE           =   7'b00000011; 
    
    
    localparam logic [3:0] ADD  =   4'b0000;
    localparam logic [3:0] SUB  =   4'b0001;
    localparam logic [3:0] SLT  =   4'b0010;
    localparam logic [3:0] SLTU =   4'b0011;
    localparam logic [3:0] XOR  =   4'b0100;
    localparam logic [3:0] OR   =   4'b0101;
    localparam logic [3:0] AND  =   4'b0110;
    localparam logic [3:0] SLL  =   4'b0111;
    localparam logic [3:0] SRL  =   4'b1000;
    localparam logic [3:0] SRA  =   4'b1001;
    
    
    
    logic [6:0] opcode ;
    logic [3:0] alu_op; 
    assign opcode = i_inst[6:0]; 
    
    always_comb begin 
        case(opcode) 
            R_TYPE: begin 
                o_alu_op        =       alu_op;  
                o_reg_wen       =       1'b1;
                o_alu_b_sel     =       1'b0; 
                o_imm_sel       =       2'bxx;
                o_wb_sel        =       1'b1; 
                o_dmem_we       =       1'b0; 
                o_insn_vld      =       1'b1;  
            end 
            R_TYPE_IMM: begin
                 o_alu_op       =       alu_op; 
                 o_reg_wen      =       1'b1;
                 o_alu_b_sel    =       1'b1; 
                 o_imm_sel      =       2'b00; 
                 o_wb_sel       =       1'b1; 
                 o_dmem_we      =       1'b0; 
                 o_insn_vld     =       1'b1;
            end 
            L_TYPE: begin 
                o_alu_op        =       ADD;  
                o_reg_wen       =       1'b1;
                o_alu_b_sel     =       1'b1; 
                o_imm_sel       =       2'b00;
                o_wb_sel        =       1'b0; 
                o_dmem_we       =       1'b0; 
                o_insn_vld      =       1'b1;  
            end 
            default: begin 
                o_alu_op        =       4'd0; 
                o_reg_wen       =       1'b0;
                o_alu_b_sel     =       1'b0; 
                o_imm_sel       =       2'bxx; 
                o_wb_sel        =       1'b0; 
                o_dmem_we       =       1'b0; 
                o_insn_vld      =       1'bx; 
            end 
        endcase
    end 
    
    aludecode aludecode_inst(
        .i_funct3       (i_inst[14:12]),   
        .i_funct7       (i_inst[30]),   
        .o_alu_op       (alu_op)
    );
    
endmodule