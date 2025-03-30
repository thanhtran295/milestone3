module memory #(
    parameter   ADDR_W = 32,
    parameter   ADDR_S = 512,
    parameter   DATA_W = 32
)
(
    input                           i_clk, 
    input                           i_reset, 
    input        [ADDR_W-1:0]       i_addr, 
    input        [DATA_W-1:0]             i_wdata,
    input        [(DATA_W/8)-1:0]              i_bmask, 
    input                           i_wren, 
    output logic [DATA_W-1:0]             o_rdata
);
    
    logic [31:0] mem [ADDR_S-1:0]; 
    
    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin 
            for (int i = 0; i < ADDR_S-1; i++) begin 
                mem[i] <= 0;
            end 
        end 
        else if (i_wren) begin 
            for (int ii = 0; ii < (DATA_W/8); ii++) begin 
                if (i_bmask[ii]) begin
                    mem[i_addr][ii*8 +: 8] <= i_wdata[ii*8 +: 8]; 
                end 
            end 
        end 
    end 
    always_comb begin
        o_rdata = 32'b0;  
        for (int iii = 0; iii < (DATA_W/8); iii++) begin 
            if (i_bmask[iii]) begin
                o_rdata[iii*8 +: 8] = mem[i_addr][iii*8 +: 8];
            end 
        end 
    end
endmodule 