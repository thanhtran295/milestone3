module sram_dual_port #(
    parameter  AW = 32,
    parameter  DW = 32
)
(
    input                           i_clk, 
    input                           i_reset, 
    input        [AW-1:0]           i_addr_a,
    input        [DW-1:0]           i_addr_b, 
    input        [31:0]             i_wdata_a,
    input        [31:0]             i_wdata_b,
    input        [3:0]              i_bmask_a, 
    input        [3:0]              i_bmask_b,
    input                           i_wren_a,
    input                           i_wren_b,
    output logic [31:0]             o_rdata_a, 
    output logic [31:0]             o_rdata_b
);
//    localparam ADDR =  1 << AW;;
    localparam ADDR = 16384;
    logic [DW-1:0] mem [ADDR-1:0]; 
    
   // initial begin 
   //     $readmemh("/mnt/hgfs/milestone2/milestone2/00_src/test.hex", mem);
   // end    
    always_ff @(posedge i_clk) begin 
      //  if (i_reset) begin 
      //      for (int i = 0; i < ADDR; i++) begin 
      //          mem[i] <= 0;
      //      end 
      //  end 
      //  else begin 
            if (i_wren_a) begin 
                for (int ii = 0; ii < 4; ii++) begin 
                    if (i_bmask_a[ii]) begin
                        mem[i_addr_a][ii*8 +: 8] <= i_wdata_a[ii*8 +: 8]; 
                    end 
                end 
            end 
            if (i_wren_b) begin 
                for (int ii = 0; ii < 4; ii++) begin 
                    if (i_bmask_b[ii]) begin
                        mem[i_addr_b][ii*8 +: 8] <= i_wdata_b[ii*8 +: 8]; 
                    end 
                end 
            end 
    //    end 
    end 
    
    always_ff @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin 
            o_rdata_a <= 0; 
            o_rdata_b <=0; 
        end
        else begin
            if (~i_wren_a) begin 
                o_rdata_a <= mem[i_addr_a]; 
            end 
            if (~i_wren_b) begin 
                o_rdata_b <= mem[i_addr_b]; 
            end 
        end
    end

endmodule 

