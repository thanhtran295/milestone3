module controller(
//    input                      i_clk, 
//    input                      i_reset, 
    input            [31:0]    i_inst,
    input                      i_br_less,  
    input                      i_br_equal,    
    output logic     [3:0]     o_alu_op, 
    output logic               o_reg_wen,
    output logic     [1:0]     o_alu_a_sel,
    output logic               o_alu_b_sel, 
    output logic     [2:0]     o_imm_sel,  
    output logic     [1:0]     o_wb_sel,
    output logic               o_dmem_we, 
    output logic               o_br_un, 
    output logic               o_pc_sel, 
    output logic               o_insn_vld    
);
//     localparam R_TYPE           =   7'b0110011; 
//     localparam R_TYPE_IMM       =   7'b0010011;
//     localparam I_TYPE           =   7'b0000011; 
//     localparam S_TYPE           =   7'b0100011;
//     localparam B_TYPE           =   7'b1100011;
//     localparam J_TYPE           =   7'b1101111;
//     localparam JALR_TYPE        =   7'b1100111;  
//     localparam LUI_TYPE         =   7'b0110111; 
//     localparam AUIPC_TYPE       =   7'b0010111; 
    
    localparam IMM_I_TYPE       =   3'b000; 
    localparam IMM_S_TYPE       =   3'b001;
    localparam IMM_B_TYPE       =   3'b010; 
    localparam IMM_J_TYPE       =   3'b011; 
    localparam IMM_U_TYPE       =   3'b100;
      
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
    
    localparam logic BEQ        =   3'b000;
    localparam logic BNE        =   3'b001;
    localparam logic BLT        =   3'b100;
    localparam logic BGE        =   3'b101;
    localparam logic BLTU       =   3'b110;
    localparam logic BGEU       =   3'b111;
    
    typedef enum logic [6:0] { R_TYPE           =   7'b0110011, 
                               R_TYPE_IMM       =   7'b0010011,
                               I_TYPE           =   7'b0000011, 
                               S_TYPE           =   7'b0100011,
                               B_TYPE           =   7'b1100011, 
                               J_TYPE           =   7'b1101111, 
                               JALR_TYPE        =   7'b1100111, 
                               LUI_TYPE         =   7'b0110111, 
                               AUIPC_TYPE       =   7'b0010111} inst_type; 
    
    inst_type opcode ;
//    logic [6:0] opcode; 
    logic [3:0] alu_op; 
    logic       pc_sel_branch;
    
    assign opcode = i_inst[6:0]; 
    
    always_comb begin 
        case(opcode) 
            R_TYPE: begin 
                o_alu_op        =       alu_op;  
                o_reg_wen       =       1'b1;
                o_alu_a_sel     =       2'b00;
                o_alu_b_sel     =       1'b0; 
                o_imm_sel       =       2'b00;
                o_wb_sel        =       2'b01; 
                o_dmem_we       =       1'b0; 
                o_pc_sel        =       1'b0; 
                o_insn_vld      =       1'b1;  
            end 
            R_TYPE_IMM: begin
                 o_alu_op       =       ADD; 
                 o_reg_wen      =       1'b1;
                 o_alu_a_sel    =       2'b00;
                 o_alu_b_sel    =       1'b1; 
                 o_imm_sel      =       IMM_I_TYPE; 
                 o_wb_sel       =       2'b01; 
                 o_dmem_we      =       1'b0; 
                 o_pc_sel        =      1'b0; 
                 o_insn_vld     =       1'b1;
            end 
            I_TYPE: begin // LOAD 
                o_alu_op        =       ADD;  
                o_reg_wen       =       1'b1;
                o_alu_a_sel     =       2'b00;
                o_alu_b_sel     =       1'b1; 
                o_imm_sel       =       IMM_I_TYPE;
                o_wb_sel        =       2'b00; 
                o_dmem_we       =       1'b0; 
                o_pc_sel        =       1'b0; 
                o_insn_vld      =       1'b1;  
            end 
            S_TYPE: begin  // STORE
                o_alu_op        =       ADD;  
                o_reg_wen       =       1'b0;
                o_alu_a_sel     =       2'b01;
                o_alu_b_sel     =       1'b1; 
                o_imm_sel       =       IMM_S_TYPE;
                o_wb_sel        =       2'b0; 
                o_dmem_we       =       1'b1; 
                o_pc_sel        =       1'b0; 
                o_insn_vld      =       1'b1;  
            end 
            B_TYPE: begin // BRANCH
                 o_alu_op        =      alu_op;
                 o_reg_wen       =      1'b0;
                 o_alu_a_sel     =      2'b01;
                 o_alu_b_sel     =      1'b1;
                 o_imm_sel       =      IMM_B_TYPE;
                 o_wb_sel        =      2'b00;
                 o_dmem_we       =      1'b0;
                 o_pc_sel        =      pc_sel_branch; 
                 o_insn_vld      =      1'b1;
            end
            J_TYPE: begin 
                 o_alu_op        =      ADD;
                 o_reg_wen       =      1'b1;
                 o_alu_a_sel     =      2'b01;
                 o_alu_b_sel     =      1'b1;
                 o_imm_sel       =      IMM_J_TYPE;
                 o_wb_sel        =      2'b10;
                 o_dmem_we       =      1'b0;
                 o_pc_sel        =      1'b1; 
                 o_insn_vld      =      1'b1;
            end 
            JALR_TYPE: begin 
                 o_alu_op        =      ADD;
                 o_reg_wen       =      1'b1;
                 o_alu_a_sel     =      2'b01; 
                 o_alu_b_sel     =      1'b1;
                 o_imm_sel       =      IMM_I_TYPE;
                 o_wb_sel        =      2'b10;
                 o_dmem_we       =      1'b0;
                 o_pc_sel        =      1'b1; 
                 o_insn_vld      =      1'b1;
            end 
            LUI_TYPE: begin
                 o_alu_op        =      ADD;
                 o_reg_wen       =      1'b1;
                 o_alu_a_sel     =      2'b10; 
                 o_alu_b_sel     =      1'b1;
                 o_imm_sel       =      IMM_U_TYPE;
                 o_wb_sel        =      2'b01;
                 o_dmem_we       =      1'b0;
                 o_pc_sel        =      1'b0; 
                 o_insn_vld      =      1'b1;
            end
            AUIPC_TYPE: begin 
                 o_alu_op        =      ADD;
                 o_reg_wen       =      1'b1;
                 o_alu_a_sel     =      2'b01; 
                 o_alu_b_sel     =      1'b1;
                 o_imm_sel       =      IMM_U_TYPE;
                 o_wb_sel        =      2'b01;
                 o_dmem_we       =      1'b1;
                 o_pc_sel        =      1'b0; 
                 o_insn_vld      =      1'b1;
            end 
            default: begin 
                o_alu_op        =       4'dx; 
                o_reg_wen       =       1'bx;
                o_alu_a_sel     =       2'b0x;
                o_alu_b_sel     =       1'bx; 
                o_imm_sel       =       2'bxx; 
                o_wb_sel        =       2'bxx; 
                o_dmem_we       =       1'bx; 
                o_pc_sel        =       1'bx; 
                o_insn_vld      =       1'bx; 
            end 
        endcase
    end 

    // Branch decode logic
    always_comb begin 
        case(i_inst[14:12])
            BEQ: begin 
                o_br_un = 1'b0; 
                pc_sel_branch = i_br_equal; 
            end 
            BNE: begin 
                o_br_un = 1'b0; 
                pc_sel_branch = ~i_br_equal; 
            end 
            BLT: begin 
                o_br_un = 1'b1; 
                pc_sel_branch = i_br_less; 
            end 
            BGE: begin 
                o_br_un = 1'b1; 
                pc_sel_branch = i_br_equal | ~i_br_less; 
            end
            BLTU: begin 
                o_br_un = 1'b0; 
                pc_sel_branch = i_br_less; 
            end
            BGEU: begin 
                o_br_un = 1'b0; 
                pc_sel_branch = i_br_equal | ~i_br_less; 
            end
            default: begin
                o_br_un = 1'b0;
                pc_sel_branch = 1'b0;
            end
        endcase
    end 

    // ALU decode logic
    // only R-Type 
    // R_IMM_TYPE 
    aludecode aludecode_inst(
        .i_opcode       (opcode), 
        .i_funct3       (i_inst[14:12]),   
        .i_funct7       (i_inst[30]),   
        .o_alu_op       (alu_op)
    );
    
endmodule