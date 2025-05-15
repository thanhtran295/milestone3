module skid_buffer
#(
    parameter DW = 32 // Data width
)
(
    input logic                 i_clk,
    input logic                 i_reset,  
    input logic     [DW-1:0]    i_data_in,
    input logic                 i_bypass, 
    output logic    [DW-1:0]    o_data_out
);  
    logic [DW-1:0] data_reg; 
    logic bypass_reg; 

    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin 
            data_reg <= 0; 
            bypass_reg <= 0;
        end 
        else begin 
            data_reg <= i_data_in;
            bypass_reg <= i_bypass;
        end 
    end 

    assign o_data_out = bypass_reg ? i_data_in : data_reg;

endmodule
