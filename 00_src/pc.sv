module pc(
    input                    i_clk, 
    input                    i_reset, 
    input        [31:0]      pc_next, 
    output logic [31:0]      pc_curr
);
    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin 
            pc_curr <= 0;
        end 
        else begin 
            pc_curr <= pc_next;
        end 
    end 
endmodule

