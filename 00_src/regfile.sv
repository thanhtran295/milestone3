module regfile (
    input                       i_clk, 
    input                       i_reset,
    input         [4:0]         i_rs1_addr, 
    input         [4:0]         i_rs2_addr, 
    output logic  [31:0]        o_rs1_data, 
    output logic  [31:0]        o_rs2_data, 
    input         [4:0]         i_rd_addr, 
    input         [31:0]        i_rd_data,
    input                       i_rd_wren
);

    logic [31:0]  reg_mem [0:31]; 
    
    always_ff @(posedge i_clk, posedge i_reset)begin 
        if (i_reset) begin 
            for (int i=0; i<32; i++) begin 
                reg_mem[i] <= 32'd0;
//                   o_rs2_data <= 0;
            end
        end 
        else begin 
            if (i_rd_wren) begin 
                reg_mem[i_rd_addr] <= i_rd_data;
            end 
        end 
    end 
 
    assign o_rs1_data = (i_rs1_addr == 5'd0) ? 32'd0 : reg_mem[i_rs1_addr];
    assign o_rs2_data = (i_rs2_addr == 5'd0) ? 32'd0 : reg_mem[i_rs2_addr];
        
endmodule

