module sram_single_port #(
    parameter  AW = 32,
    parameter  DW = 32
)
(
    input logic             i_clk, 
    input logic             i_reset, 
    input logic   [AW-1:0]  i_addr, 
    input logic   [DW-1:0]  i_wdata,
    input logic             i_cs,
    input logic             i_wren, 
    input logic   [3:0]     i_bmask, 
    output logic  [DW-1:0]  o_rdata
);
//    localparam ADDR = 2**AW;

    localparam ADDR=100;    
    logic [DW-1:0]  mem  [ADDR -1 :0]; 
    
    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin
            o_rdata <= 0; 
        end 
        else begin 
            if (i_wren & i_cs) begin 
                for (int ii = 0; ii < 4; ii++) begin 
                    if (i_bmask[ii]) begin
                        mem[i_addr][ii*8 +: 8] <= i_wdata[ii*8 +: 8]; 
                    end 
                end 
            end 
            else if (~i_wren & i_cs) begin 
                for (int ii = 0; ii < 4; ii++) begin 
                    if (i_bmask[ii]) begin
                        o_rdata[ii*8 +: 8] <= mem[i_addr][ii*8 +: 8]; 
                    end 
                end 
            end
        end 
    end
    initial begin  
        //$readmemh("E:/TK_VXL/Pipeline_RISCV/rtl/asm_code.mem", mem);
        $readmemh("E:/TK_VXL/Pipeline_RISCV/rtl/asm_code.mem", mem);
    end 
endmodule 
