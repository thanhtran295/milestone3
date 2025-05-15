module hazard_unit_always_stall (
    input  logic       i_clk, i_reset,
    input  logic [6:0] opcodeIF, // opcode from IF stage
    input  logic [6:0] opcodeEX,
    input  logic [4:0] rs1E, rs2E, 
    input  logic [4:0] rs1D, rs2D,         
    input  logic [4:0] ex_rd, mem_rd, wb_rd,    
    input  logic       ex_regwrite, mem_regwrite, wb_regwrite,
    input  logic [1:0] wb_sel,    
    input  logic       pc_sel_ex, // pc_sel from EX stage                         
    // input  logic       branchD,  
    // input  logic       takenE, 

    output logic       stallF,
    output logic       stallD,
    output logic       flushD,           
    output logic       flushE,       
//    output logic       flushMEM, 
    output logic [1:0] forward_a, forward_b     
);

    
    localparam B_TYPE           =   7'b1100011;
    localparam J_TYPE           =   7'b1101111;
    localparam JALR_TYPE        =   7'b1100111;
    // Forwarding Logic
    always_comb begin
        forward_a = 2'b00; // default: no forwarding
        forward_b = 2'b00;

        if (mem_regwrite && (mem_rd != 0) && (mem_rd == rs1E))
            forward_a = 2'b10;
        else if (wb_regwrite && (wb_rd != 0) && (wb_rd == rs1E))
            forward_a = 2'b01;

        if (mem_regwrite && (mem_rd != 0) && (mem_rd == rs2E))
            forward_b = 2'b10;
        else if (wb_regwrite && (wb_rd != 0) && (wb_rd == rs2E))
            forward_b = 2'b01;
    end

    // Load-use hazard detection (Stall)
    
    wire lwStall = (wb_sel==2'b00) && ((ex_rd == rs1D) || (ex_rd == rs2D)) && (ex_rd != 0);

    // ========== Branch Stall ==========
    logic branchStall_IF;
    always_comb begin 
        branchStall_IF = 1'b0; 
        if (((opcodeIF == B_TYPE) || (opcodeIF == J_TYPE) || (opcodeIF == JALR_TYPE))) begin 
            branchStall_IF = ~(((opcodeEX == B_TYPE) || (opcodeEX == J_TYPE) || (opcodeEX == JALR_TYPE)))  ; // branch instruction in IF stage
        end
    end 

    
    logic branchStall_IF_delay1, branchStall_IF_delay2, branchStall_IF_delay3; // delay the branch stall signal for 1 cycle
    logic branchFlush; // flush the IF stage if there is a branch instruction in the decode stage
    always_ff @(posedge i_clk or posedge i_reset) begin 
        if (i_reset) begin 
            {branchStall_IF_delay1, branchStall_IF_delay2, branchStall_IF_delay3} <= 3'b0;
        end 
        else begin 
           {branchStall_IF_delay3, branchStall_IF_delay2, branchStall_IF_delay1} <= {branchStall_IF_delay2, branchStall_IF_delay1, branchStall_IF};
        end
    end

    assign branchFlush = branchStall_IF_delay3;
    // ========== Control signals ==========

    assign stallD = lwStall; // stall the decode stage if there is a hazard
    assign stallF = lwStall | branchStall_IF;
    assign flushD = branchFlush;
    assign flushE = lwStall | branchFlush;
//    assign flusMEM =  branchFlush;

endmodule
