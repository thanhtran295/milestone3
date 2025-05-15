module dmem(
    input                       i_clk, 
    input                       i_reset, 
    input      [31:0]           i_addr, 
    input      [31:0]           i_wdata,
    input                       i_wren,     
    output logic [31:0]         o_rdata  
);
    memory dmem_inst (
        .i_clk              (i_clk), 
        .i_reset            (i_reset), 
        .i_addr             (i_addr),
        .i_wdata            (i_wdata),
        .i_bmask            (4'b1111), //write all 4 bytes = 32bit
        .i_wren             (i_wren),
        .o_rdata            (o_rdata)
    );
    
endmodule 
