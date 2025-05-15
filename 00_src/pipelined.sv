module pipelined(
    input  logic            i_clk, 
    input  logic            i_reset, 
    output logic [31:0]     o_pc_debug,
    output logic            o_ctrl, 
    output logic            o_mispred,
    output logic            o_insn_vld, 
    output logic [31:0]     o_io_ledr, 
    output logic [31:0]     o_io_ledg, 
//    output logic [6:0]      o_io_hex07  [0:7], 
    output logic [6:0]      o_io_hex0,
    output logic [6:0]      o_io_hex1,
    output logic [6:0]      o_io_hex2,
    output logic [6:0]      o_io_hex3,
    output logic [6:0]      o_io_hex4,
    output logic [6:0]      o_io_hex5,
    output logic [6:0]      o_io_hex6,
    output logic [6:0]      o_io_hex7,
    output logic [31:0]     o_io_lcd, 
    input  logic [31:0]     i_io_sw
);
    //DATA PATH wires
    logic [31:0]    pc, pc_next, pc_plus_4; 
    logic [31:0]    inst;
    logic [31:0]    alu_out, write_back_data; 
    logic [31:0]    rs1_data, rs2_data; 
    logic [31:0]    alu_opa, alu_opb;
    logic [31:0]    imm;
    logic [31:0]    dmem_rdata, dmem_wdata; 
    logic [6:0]     o_io_hex07  [0:7];
    
    //Control signals wires 
    logic [1:0]     alu_a_sel; 
    logic           alu_b_sel; 
    logic [2:0]     imm_sel; 
    logic [3:0]     alu_op; 
    logic           reg_wen;
    logic [1:0]     wb_sel;
    logic           dmem_we; 
    logic           br_un; 
    logic           br_less, br_equal; 
    logic           pc_sel;
    logic           lsu_signed;
    logic [1:0]     lsu_size;
    logic [31:0]    imem_data_out;
    logic [31:0]    inst_if, pc_if; 

    localparam  BEQ        =   3'b000;
    localparam  BNE        =   3'b001;
    localparam  BLT        =   3'b100;
    localparam  BGE        =   3'b101;
    localparam  BLTU       =   3'b110;
    localparam  BGEU       =   3'b111;

    logic     stall_IF;
    logic     stall_ID;
    logic     flush_ID; 
    logic     flush_EX; 
    logic     flush_MEM; 

    typedef enum logic [6:0] { R_TYPE           =   7'b0110011, 
                               R_TYPE_IMM       =   7'b0010011,
                               I_TYPE           =   7'b0000011, 
                               S_TYPE           =   7'b0100011,
                               B_TYPE           =   7'b1100011, 
                               J_TYPE           =   7'b1101111, 
                               JALR_TYPE        =   7'b1100111, 
                               LUI_TYPE         =   7'b0110111, 
                               AUIPC_TYPE       =   7'b0010111} inst_type; 

//    IF/ID: 32-b PC address, 32-b instruction
//    ID/EX: immediate, R[rs1], R[rs2], PC address, 32-b instruction
//    EX/MEM: R[rs2], PC, ALU, instruction
//    MEM/WB: ALU, mem, PC+4, instruction

    //=============================================INSTRUCTION MEMORY====================================
    logic [31:0] sram_addr; 
    logic        sram_addr_valid;
    
    sram_single_port imem_inst (
           .i_clk       (i_clk), 
           .i_reset     (i_reset),
           .i_addr      ({2'd0, sram_addr[31:2]}), 
           .i_cs        (sram_addr_valid),
           .i_wdata     (32'd0),
           .i_wren      (1'b0),
           .i_bmask     (4'b1111), 
           .o_rdata     (imem_data_out)
    );

    
    //=============================================STAGE IF====================================

    logic pc_sel_if; 
    // inst_type opcode_if;
    logic inst_valid_if;
    logic [31:0] pc_if_delay;


    PrefetchBuffer #(
        .ADDR_WIDTH(32), 
        .DATA_WIDTH(32),
        .DEPTH(2)
    ) prefetch_buffer_inst (
        .clk               (i_clk),
        .reset             (i_reset),

        .pc_current        (pc_if),
        .pc_stall          (stall_IF),
        .branch_flush      (flush_ID),
        .branch_target     (pc_next),

        .sram_addr         (sram_addr),
        .sram_valid        (1'b1), 
        .sram_req          (sram_addr_valid),
        .sram_data         (imem_data_out),

    
        .inst_out          (inst_if),
        .inst_valid        (inst_valid_if) 
    );


    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin 
            pc_if <= 0; 
        end 
        else if (~stall_IF && inst_valid_if) begin 
            pc_if <= pc_next; 
        end 
    end

    assign pc_plus_4 = pc_if + 32'd4;
    assign pc_next = pc_sel_if ? alu_out : pc_plus_4; 
    assign pc_sel_if = pc_sel;

    inst_type opcode_if;

    always_comb begin 
        opcode_if = inst_type'(inst_if[6:0]); 
    end

    
    // ==============================BRANCH PREDICTION LOGIC=======================



    //=============================================PIPELINE REG====================================
    typedef struct packed {
        logic [31:0] pc; 
        logic [31:0] inst; 
    } IF_ID_t;
    IF_ID_t reg_IF_ID;


    always_ff @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin 
            reg_IF_ID <= 0;
        end 
        else if (flush_ID) begin 
            reg_IF_ID <= 0; 
        end 
        else if (~stall_ID && inst_valid_if) begin 
            reg_IF_ID <= '{
                           pc: pc_if, 
                           inst: inst_if
                           }; 
        end
    end 

    //=============================================STAGE ID====================================
    
    wire [31:0] inst_id = reg_IF_ID.inst;
    // wire [31:0] inst_id = flush_ID ? 0 : inst_if; // for debugging purpose
    wire [31:0] pc_id   = reg_IF_ID.pc;
    
    //internal control signals
    logic [2:0] imm_sel_id; 
    logic       reg_wen_id;
    logic       pc_sel_id;
    logic       dmem_we_id;
    logic [1:0] alu_a_sel_id;
    logic       alu_b_sel_id; 

    logic [3:0]  alu_op_id;
    logic [1:0]  wb_sel_id; 
    logic [1:0]  lsu_size_id;
    logic        insn_vld_id;


    regfile regfile_inst(
        .i_clk          (i_clk),                
        .i_reset        (i_reset),              
        .i_rs1_addr     (inst_id[19:15]),           
        .i_rs2_addr     (inst_id[24:20]),           
        .o_rs1_data     (rs1_data),           
        .o_rs2_data     (rs2_data), 

        .i_rd_addr      (inst_wb[11:7]),            
        .i_rd_data      (write_back_data),            
        .i_rd_wren      (reg_wen_wb)      
    );
    
    imm_gen imm_gen_inst (
         .i_inst         (inst_id[31:7]),                     
         .i_imm_sel      (imm_sel_id),                
         .o_imm          (imm)          
    );

    controller controller_inst(
//        .i_clk           (i_clk),        
//        .i_reset         (i_reset),
        .i_inst          (inst_id),

        .o_imm_sel       (imm_sel_id),
        .o_reg_wen       (reg_wen_id),

        .o_alu_op        (alu_op_id),
        .o_alu_a_sel     (alu_a_sel_id), 
        .o_alu_b_sel     (alu_b_sel_id),  
        
        .o_dmem_we       (dmem_we_id), 
        
        .o_pc_sel        (pc_sel_id),
        .o_insn_vld      (insn_vld_id),
        .o_lsu_signed    (lsu_signed_id),
        .o_lsu_size      (lsu_size_id),

        .o_wb_sel        (wb_sel_id) 
    );
    
    //DEBUG ONLY this logic will be removed when running synthesis

    inst_type opcode_id;

    always_comb begin 
        opcode_id = inst_type'(inst_id[6:0]); 
    end

    //=============================================PIPELINE REG====================================
    typedef struct packed {
        logic [31:0] pc;
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] imm;
        logic [31:0] inst;
        // control
        logic [3:0]  alu_op;
        logic [1:0]  alu_a_sel;
        logic        alu_b_sel;
        logic        dmem_we;
        logic [1:0]  wb_sel;
        logic        lsu_signed;
        logic [1:0]  lsu_size;
        logic        insn_vld;
        logic        reg_wen;
        logic        pc_sel;
    } id_ex_reg_t;

    id_ex_reg_t reg_ID_EX;

    always_ff @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin 
            reg_ID_EX <= 0;
        end 
        else if (flush_EX) begin
            reg_ID_EX <= 0; 
        end 
        else begin 
            reg_ID_EX <= '{
                pc        : pc_id,
                rs1_data  : rs1_data,
                rs2_data  : rs2_data,
                imm       : imm,
                inst      : inst_id,
                alu_op    : alu_op_id,
                alu_a_sel : alu_a_sel_id,
                alu_b_sel : alu_b_sel_id,
                dmem_we   : dmem_we_id,
                wb_sel    : wb_sel_id,
                lsu_signed: lsu_signed_id,
                lsu_size  : lsu_size_id,
                insn_vld  : insn_vld_id,
                reg_wen   : reg_wen_id,
                pc_sel    : pc_sel_id
            };

        end
    end 

    //=============================================STAGE EX====================================
    // Control signals
    wire [3:0]  alu_op_ex     = reg_ID_EX.alu_op; //used
    wire [1:0]  alu_a_sel_ex  = reg_ID_EX.alu_a_sel; //used
    wire        alu_b_sel_ex  = reg_ID_EX.alu_b_sel; //used

    wire        dmem_we_ex    = reg_ID_EX.dmem_we;
    wire [1:0]  wb_sel_ex     = reg_ID_EX.wb_sel;
    wire        lsu_signed_ex = reg_ID_EX.lsu_signed;
    wire [1:0]  lsu_size_ex   = reg_ID_EX.lsu_size;
    wire        insn_vld_ex   = reg_ID_EX.insn_vld;
    wire        reg_wen_ex    = reg_ID_EX.reg_wen;
    wire        pc_sel_ex_id  = reg_ID_EX.pc_sel; //used
    // Data path
    wire [31:0] rs1_data_ex  = reg_ID_EX.rs1_data;
    wire [31:0] rs2_data_ex  = reg_ID_EX.rs2_data;
    wire [31:0] imm_ex       = reg_ID_EX.imm;
    wire [31:0] inst_ex      = reg_ID_EX.inst;
    wire [31:0] pc_ex        = reg_ID_EX.pc;
    // LOGIC OF CONTROLLER
    logic [2:0] funct3; 
    logic [6:0] opcode; 
    logic       pc_sel_ex;
    logic       reg_wen_wb;


    assign  opcode = inst_ex[6:0];
    assign  funct3 = inst_ex[14:12]; 

    assign pc_sel = (opcode == B_TYPE) ? pc_sel_ex : pc_sel_ex_id;
    // assign pc_sel = pc_sel_ex_id; // no need to use pc_sel_ex in ID stage

    always_comb begin   
        case(funct3)
            BEQ: begin 
                pc_sel_ex = br_equal; 
            end 
            BNE: begin 
                pc_sel_ex = ~br_equal; 
            end 
            BLT: begin 
                pc_sel_ex = br_less; 
            end 
            BGE: begin 
                pc_sel_ex = br_equal | ~br_less; 
            end
            BLTU: begin
                pc_sel_ex = br_less; 
            end
            BGEU: begin 
                pc_sel_ex = br_equal | ~br_less; 
            end
            default: begin
                pc_sel_ex = 1'b0;
            end
        endcase
    end 

    always_comb begin   
        case(funct3)
            BEQ: begin 
                br_un = 1'b0; 
            end 
            BNE: begin 
                br_un = 1'b0; 
            end 
            BLT: begin 
                br_un = 1'b1; 
            end 
            BGE: begin 
                br_un = 1'b1;     
            end
            BLTU: begin
                br_un = 1'b0; 
            end
            BGEU: begin 
                br_un = 1'b0; 
            end
            default: begin
                br_un = 1'b0;
            end
        endcase
    end 
    logic [1:0] forward_a, forward_b;

    alu alu_inst (
        .i_operand_a    (alu_opa),
        .i_operand_b    (alu_opb),
        .i_alu_op       (alu_op_ex),   
        .o_alu_data     (alu_out) 
    );
    
//    assign alu_opa  = alu_a_sel ? pc : rs1_data ; 
    always_comb begin 
        alu_opa = 0; 
        casez({forward_a, alu_a_sel_ex})
            {2'b00,2'b00}: alu_opa = rs1_data_ex; 
            {2'b00,2'b01}: alu_opa = pc_ex; 
            {2'b00,2'b10}: alu_opa = 0;
            {2'b10,2'b??}: alu_opa = alu_out_mem;
            {2'b01,2'b??}: alu_opa = write_back_data; 
            default: alu_opa = rs1_data_ex; 
        endcase
    end 
    
    // assign alu_opb  = alu_b_sel_ex ? imm_ex :  rs2_data_ex ; 
    always_comb begin
        alu_opb = 0; 
        casez({forward_b, alu_b_sel_ex})
            {2'b00,1'b0}: alu_opb = rs2_data_ex; 
            {2'b00,1'b1}: alu_opb = imm_ex; 
            {2'b10,1'b?}: alu_opb = alu_out_mem;
            {2'b01,1'b?}: alu_opb = alu_out_wb; 
            default: alu_opb = rs2_data_ex; 
        endcase
    end
    
    brc brc_inst (
        .i_rs1_data     (rs1_data_ex),
        .i_rs2_data     (rs2_data_ex),
        .i_br_un        (br_un), 
        .o_br_less      (br_less), 
        .o_br_equal     (br_equal)
    );

    //DEBUG ONLY this logic will be removed when running synthesis
    inst_type opcode_ex;

    always_comb begin 
        opcode_ex = inst_type'(inst_ex[6:0]); 
    end

    //=============================================PIPELINE REG====================================
    
    typedef struct packed  {
        logic [31:0] pc;
        logic [31:0] alu_out;
        logic [31:0] rs2_data;
        logic [31:0] inst;
        // control
        logic        dmem_we;   
        logic [1:0]  wb_sel;    
        logic        lsu_signed;
        logic [1:0]  lsu_size;  
        logic        insn_vld;  
        logic        reg_wen;   
    } ex_mem_reg_t;
    
    ex_mem_reg_t reg_EX_MEM;
    
    always_ff @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin 
            reg_EX_MEM <= '0;
        end 
        else if (flush_MEM) begin 
            reg_EX_MEM <= '0; 
        end 
        else begin 
            reg_EX_MEM <= '{
                pc         : pc_ex,
                alu_out    : alu_out,
                rs2_data   : rs2_data_ex,
                inst       : inst_ex,
                dmem_we    : dmem_we_ex,
                wb_sel     : wb_sel_ex,
                lsu_signed : lsu_signed_ex,
                lsu_size   : lsu_size_ex,
                insn_vld   : insn_vld_ex,
                reg_wen    : reg_wen_ex
            }; 
        end
    end 
    
    //=============================================STAGE MEM====================================
    wire [31:0] pc_mem         =       reg_EX_MEM.pc;
    wire [31:0] alu_out_mem    =       reg_EX_MEM.alu_out;
    wire [31:0] rs2_data_mem   =       reg_EX_MEM.rs2_data;
    wire [31:0] inst_mem       =       reg_EX_MEM.inst;
    //control signals
    wire        dmem_we_mem    =       reg_EX_MEM.dmem_we;   //used
    wire [1:0]  wb_sel_mem     =       reg_EX_MEM.wb_sel;    
    wire        lsu_signed_mem =       reg_EX_MEM.lsu_signed; //used
    wire [1:0]  lsu_size_mem   =       reg_EX_MEM.lsu_size;   //used
    wire        insn_vld_mem   =       reg_EX_MEM.insn_vld;  
    wire        reg_wen_mem    =       reg_EX_MEM.reg_wen;   

    logic [6:0]      io_hex07_mem  [0:7];
    logic [31:0]     io_ledr_mem;
    logic [31:0]     io_ledg_mem;
    logic [31:0]     io_lcd_mem;

    logic [6:0]     io_hex0_mem;
    logic [6:0]     io_hex1_mem;
    logic [6:0]     io_hex2_mem;
    logic [6:0]     io_hex3_mem;
    logic [6:0]     io_hex4_mem;
    logic [6:0]     io_hex5_mem;
    logic [6:0]     io_hex6_mem;
    logic [6:0]     io_hex7_mem;

    lsu lsu_inst (
          .i_clk        (i_clk),
          .i_reset      (i_reset),
          .i_lsu_addr   (alu_out_mem),
          .i_st_data    (dmem_wdata),
          .i_lsu_size    (lsu_size_mem), //default WORD 
          .i_lsu_signed  (~lsu_signed_mem), 
          .i_lsu_wren   (dmem_we_mem),
          .o_ld_data    (dmem_rdata),
          .o_io_ledr    (io_ledr_mem),
          .o_io_ledg    (io_ledg_mem),
          .o_io_hex     (io_hex07_mem),
          .o_io_lcd     (io_lcd_mem),
          .i_io_sw      (i_io_sw)
    );


    assign io_hex0_mem =  io_hex07_mem[0];
    assign io_hex1_mem =  io_hex07_mem[1];
    assign io_hex2_mem =  io_hex07_mem[2];
    assign io_hex3_mem =  io_hex07_mem[3];
    assign io_hex4_mem =  io_hex07_mem[4];
    assign io_hex5_mem =  io_hex07_mem[5];
    assign io_hex6_mem =  io_hex07_mem[6];
    assign io_hex7_mem =  io_hex07_mem[7];

//    assign dmem_wdata       = alu_out;    
    assign dmem_wdata       = rs2_data_mem;
    wire [31:0] pc_plus_4_mem = pc_mem + 32'd4;
//    assign write_back_data  = wb_sel ? alu_out : dmem_rdata ;

    //DEBUG ONLY this logic will be removed when running synthesis
    inst_type opcode_mem;

    always_comb begin 
        opcode_mem = inst_type'(inst_mem[6:0]); 
    end

    //=============================================PIPELINE REG====================================
    typedef struct packed {
        logic [31:0]    pc;
        logic [31:0]    pc_plus_4;
        logic [31:0]    alu_out;
        logic [31:0]    dmem_rdata;
        logic [31:0]    inst; 
        //IO
        logic [31:0]    io_ledr;
        logic [31:0]    io_ledg;
        logic [31:0]    io_lcd;
        logic [6:0]     io_hex0;
        logic [6:0]     io_hex1;
        logic [6:0]     io_hex2;
        logic [6:0]     io_hex3;
        logic [6:0]     io_hex4;
        logic [6:0]     io_hex5;
        logic [6:0]     io_hex6;
        logic [6:0]     io_hex7;

        // control
        logic           reg_wen;
        logic [1:0]     wb_sel; 
        logic           insn_vld;
    } mem_wb_reg_t;
    
    mem_wb_reg_t reg_MEM_WB;
    
    always_ff @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin 
            reg_MEM_WB <= 0;
        end 
        else begin 
            reg_MEM_WB <=  '{
                pc          : pc_mem,
                pc_plus_4   : pc_plus_4_mem, 
                alu_out     : alu_out_mem,
                dmem_rdata  : dmem_rdata, // no need to be pipelined in sram model
                inst        : inst_mem, 
                io_ledr     : io_ledr_mem,   
                io_ledg     : io_ledg_mem,   
                io_lcd      : io_lcd_mem,   
                io_hex0     : io_hex0_mem,   
                io_hex1     : io_hex1_mem,   
                io_hex2     : io_hex2_mem,   
                io_hex3     : io_hex3_mem,   
                io_hex4     : io_hex4_mem,   
                io_hex5     : io_hex5_mem,   
                io_hex6     : io_hex6_mem,   
                io_hex7     : io_hex7_mem,   
                reg_wen     : reg_wen_mem,
                wb_sel      : wb_sel_mem,
                insn_vld    : insn_vld_mem            
                };
        end
    end 
    //=============================================STAGE WB ====================================
    wire [31:0]    pc_wb = reg_MEM_WB.pc;
    wire [31:0]    pc_plus_4_wb = reg_MEM_WB.pc_plus_4;
    wire [31:0]    alu_out_wb = reg_MEM_WB.alu_out;
    // wire [31:0]    dmem_rdata_wb = reg_MEM_WB.dmem_rdata; // already pipelined in SRAM model synchronous read
    wire [31:0]    inst_wb = reg_MEM_WB.inst; 

    //IO
    wire [31:0]    io_ledr_wb = reg_MEM_WB.io_ledr;
    wire [31:0]    io_ledg_wb = reg_MEM_WB.io_ledg;
    wire [31:0]    io_lcd_wb = reg_MEM_WB.io_lcd;
    wire [6:0]     io_hex0_wb = reg_MEM_WB.io_hex0;
    wire [6:0]     io_hex1_wb = reg_MEM_WB.io_hex1;
    wire [6:0]     io_hex2_wb = reg_MEM_WB.io_hex2;
    wire [6:0]     io_hex3_wb = reg_MEM_WB.io_hex3;
    wire [6:0]     io_hex4_wb = reg_MEM_WB.io_hex4;
    wire [6:0]     io_hex5_wb = reg_MEM_WB.io_hex5;
    wire [6:0]     io_hex6_wb = reg_MEM_WB.io_hex6;
    wire [6:0]     io_hex7_wb = reg_MEM_WB.io_hex7;

    // control
    wire [1:0]     wb_sel_wb = reg_MEM_WB.wb_sel; 
    wire           insn_vld_wb = reg_MEM_WB.insn_vld;
    assign         reg_wen_wb = reg_MEM_WB.reg_wen;

    always_comb begin
        write_back_data = dmem_rdata;
        case(wb_sel_wb)
            2'b00: write_back_data = dmem_rdata; 
            2'b01: write_back_data = alu_out_wb; 
            2'b10: write_back_data = pc_plus_4_wb;
	    default:write_back_data = dmem_rdata; 
        endcase
    end 

    //DEBUG ONLY this logic will be removed when running synthesis
    inst_type opcode_wb;

    always_comb begin 
        opcode_wb = inst_type'(inst_wb[6:0]); 
    end

    //IO assignment

    assign o_io_ledr = io_ledr_wb; 
    assign o_io_ledg = io_ledg_wb; 
    assign o_io_lcd  = io_lcd_wb; 
    assign o_io_hex0 = io_hex0_wb;
    assign o_io_hex1 = io_hex1_wb;
    assign o_io_hex2 = io_hex2_wb;
    assign o_io_hex3 = io_hex3_wb;
    assign o_io_hex4 = io_hex4_wb;
    assign o_io_hex5 = io_hex5_wb;
    assign o_io_hex6 = io_hex6_wb;
    assign o_io_hex7 = io_hex7_wb;
    assign o_pc_debug = pc_wb;
    assign o_insn_vld = insn_vld_wb;
    assign o_pc_debug = pc_wb;

    // ======================================HAZARD CONTROLLER UNIT====================================

    HazardUnit hazard_unit_inst (
        .i_clk         (i_clk),
        .i_reset       (i_reset),
        .opcodeIF      (inst_if[6:0]), // opcode from IF stage
        .opcodeEX      (inst_ex[6:0]), // opcode from EX stage
        // Source operands
        .rs1E          (inst_ex[19:15]), // Execute stage rs1_address
        .rs2E          (inst_ex[24:20]), // Execute stage rs2_address
        .rs1D          (inst_id[19:15]), // Decode stage rs1_address
        .rs2D          (inst_id[24:20]), // Decode stage rs2_address
        // Destination registers
        .ex_rd         (inst_ex[11:7]),  //Destination register in EX stage
        .mem_rd        (inst_mem[11:7]), //Destination register in MEM stage
        .wb_rd         (inst_wb[11:7]),  //Destination register in WB stage

        .ex_regwrite   (reg_wen_ex), 
        .mem_regwrite  (reg_wen_mem), 
        .wb_regwrite   (reg_wen_wb), 
        .wb_sel        (wb_sel_ex),// no mem2reg in EX stage
        // .branchD       (pc_sel_ex),
        // .takenE        (pc_sel_ex),
        .pc_sel_ex     (pc_sel),
        .stallF        (stall_IF), 
        .stallD        (stall_ID), 
        .flushE        (flush_EX), 
        .flushD        (flush_ID),
        .flushMEM     (flush_MEM),
        .forward_a     (forward_a), 
        .forward_b     (forward_b) 
    );

    
    
endmodule 
