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
    localparam ADDR = 512;
    logic [31:0] mem [0:ADDR-1]; 
    logic [31:0] o_rdata_temp; 
    always_ff @(posedge i_clk) begin
        o_rdata_temp = mem[i_addr]; 
    //     if (i_reset) begin 
    //         for (int i = 0; i < ADDR; i++) begin 
    //             mem[i] <= 0;
    //         end 
    //     end 
    //     else if (i_wren) begin 
    //         for (int ii = 0; ii < 4; ii++) begin 
    //             if (i_bmask[ii]) begin
    //                 mem[i_addr][ii*8 +: 8] <= i_wdata[ii*8 +: 8]; 
    //             end 
    //         end 
    //     end 
    end 
    
    assign o_rdata = o_rdata_temp;
    
    initial begin 
        //`ifdef THANH_TB
        $readmemh("F:/DATA/Study/SEM3/VXL/milestone2/milestone2/00_src/test.hex", mem);
        //`else 
        //$readmemh("E:/TK_VXL/SingleCycle_RICSV/project_1/project_1.srcs/sources_1/new/asm_code.mem", mem);
        //`endif 
    end
endmodule 