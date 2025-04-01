module singlecycle(
    input  logic            i_clk, 
    input  logic            i_reset, 
    output logic [31:0]     o_pc_debug,
    output logic            o_insn_vld, 
    output logic [31:0]     o_io_ledr, 
    output logic [31:0]     o_io_ledg, 
    output logic [6:0]      o_io_hex07 [0:7], 
    output logic [31:0]     o_io_lcd, 
    input  logic [31:0]     i_io_sw
);
    //DATA PATH wires
    logic [31:0]    pc, pc_next; 
    logic [31:0]    inst;
    logic [31:0]    alu_out, write_back_data; 
    logic [31:0]    rs1_data, rs2_data; 
    logic [31:0]    alu_opa, alu_opb;
    logic [31:0]    imm;
    logic [31:0]    dmem_rdata, dmem_wdata; 
    
    //Control signals wires 
    logic           alu_a_sel, alu_b_sel; 
    logic [1:0]     imm_sel; 
    logic [3:0]     alu_op; 
    logic           reg_wen;
    logic           wb_sel;
    logic           dmem_we; 
    logic           br_un; 
    logic           br_less, br_equal; 
    logic           pc_sel;
    //==========================================================================================
    //=============================================DATA PATH====================================
    //==========================================================================================

    pc pc_inst (
          .i_clk       (i_clk), 
          .i_reset     (i_reset), 
          .pc_next     (pc_next),
          .pc_curr     (pc)
    );
    
    assign pc_next = pc_sel ? alu_out : pc + 32'd4; 
    
    imem imem_inst (
          .i_clk        (i_clk), 
          .i_reset      (i_reset),
          .i_addr       (pc),
          .o_rdata      (inst)
    );
    
    regfile regfile_inst(
        .i_clk          (i_clk),                
        .i_reset        (i_reset),              
        .i_rs1_addr     (inst[19:15]),           
        .i_rs2_addr     (inst[24:20]),           
        .o_rs1_data     (rs1_data),           
        .o_rs2_data     (rs2_data),              
        .i_rd_addr      (inst[11:7]),            
        .i_rd_data      (write_back_data),            
        .i_rd_wren      (reg_wen)      
    );
    
    alu alu_inst (
        .i_operand_a    (alu_opa),
        .i_operand_b    (alu_opb),
        .i_alu_op       (alu_op),   
        .o_alu_data     (alu_out) 
    );
    
    assign alu_opa  = alu_a_sel ? pc : rs1_data ; 
    assign alu_opb  = alu_b_sel ? imm :  rs2_data ; 
    
    imm_gen imm_gen_inst (
         .i_inst         (inst[31:7]),                     
         .i_imm_sel      (imm_sel),                
         .o_imm          (imm)          
    );
    
//    dmem dmem_inst (
//        .i_clk           (i_clk),   
//       .i_reset         (i_reset), 
//        .i_addr          (alu_out),  
//        .i_wdata         (dmem_wdata), 
//       .i_wren          (dmem_we),  
//        .o_rdata         (dmem_rdata)  
//   );
    lsu dut (
        .i_clk(i_clk),
    .i_reset(i_reset),
    .i_lsu_addr(alu_out),
    .i_st_data(dmem_wdata),
    .i_lsu_size(1'b10), //default WORD 
//    .i_lsu_unsigned(unsigned_op),
    .i_lsu_wren(dmem_we),
    .o_ld_data(dmem_rdata),
    .o_io_ledr(o_io_ledr),
    .o_io_ledg(o_io_ledg),
    .o_io_hex(o_io_hex07),
    .o_io_lcd(o_io_lcd),
    .i_io_sw(i_io_sw)
    );

    assign dmem_wdata       = rs2_data;
    assign write_back_data  = wb_sel ? alu_out : dmem_rdata ;
    
    brc brc_inst (
        .i_rs1_data     (rs1_data),
        .i_rs2_data     (rs2_data),
        .i_br_un        (br_un), 
        .o_br_less      (br_less), 
        .o_br_equal     (br_equal)
    );
    
    //==========================================================================================
    //=============================================CONTROLLER===================================
    //==========================================================================================
    controller controller_inst(
        .i_clk           (i_clk),        
        .i_reset         (i_reset),      
        .i_inst          (inst),   
        .i_br_less       (br_less), 
        .i_br_equal      (br_equal),
        .o_alu_op        (alu_op),
        .o_imm_sel       (imm_sel),
        .o_alu_a_sel     (alu_a_sel), 
        .o_alu_b_sel     (alu_b_sel),  
        .o_reg_wen       (reg_wen),
        .o_wb_sel        (wb_sel), 
        .o_dmem_we       (dmem_we), 
        .o_br_un         (br_un),
        .o_pc_sel        (pc_sel),
        .o_insn_vld      (o_insn_vld)
    );
    
    
endmodule 