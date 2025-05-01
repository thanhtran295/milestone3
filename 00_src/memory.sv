module memory #(
    parameter   ADDR_W = 32
)
(
    input                           i_clk, 
    input                           i_reset, 
    input        [ADDR_W-1:0]       i_addr, 
    input        [31:0]             i_wdata,
    input        [3:0]              i_bmask, 
    input                           i_wren, 
    output logic [31:0]             o_rdata
);
    localparam ADDR = 64000;
    logic [31:0] mem [ADDR-1:0]; 
        
    assign o_rdata = mem[i_addr];
    
    initial begin 
        //$readmemh("E:/TK_VXL/SingleCycle_RICSV/project_1/project_1.srcs/sources_1/new/asm_code.mem", mem);
        //$readmemh("/home/cpa/ca301/sc-test/02_test/isa.mem", mem);
        $readmemh("F:/DATA/Study/SEM3/VXL/milestone2/milestone2/00_src/test.hex", mem);
    end
endmodule

