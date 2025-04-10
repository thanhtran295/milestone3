module dual_port_mem #(
    parameter   ADDR_W = 32
)
(
    input                           i_clk, 
    input                           i_reset, 
    input        [9-1:0]            i_addr_a,
    input        [9-1:0]            i_addr_b, 
    input        [31:0]             i_wdata_a,
    input        [31:0]             i_wdata_b,
    input        [3:0]              i_bmask_a, 
    input        [3:0]              i_bmask_b,
    input                           i_wren_a,
    input                           i_wren_b,
    output logic [31:0]             o_rdata_a, 
    output logic [31:0]             o_rdata_b
);
    localparam ADDR = 512;
    logic [31:0] data_mem_L [0:256-1] = '{default:32'b0} ; 
    logic [31:0] data_mem_H [0:256-1] = '{default:32'b0} ;
    logic [31:0] rdata_a, rdata_b;
    logic [31:0] addr_plus; 
    logic [3:0]  i_bmask_H, i_bmask_L; 
    logic [31:0] rdata_H, rdata_L; 
    logic [31:0] i_wdata_H, i_wdata_L;
    logic        i_wren_H, i_wren_L;
    logic [8:0]  i_addr_H, i_addr_L; 

    always_comb begin
        if (i_addr_a[0]) begin
            i_addr_L  = {1'b0,i_addr_b[8:1]};
            i_bmask_L = i_bmask_b;
            i_wren_L  = i_wren_b;
            i_wdata_L  = i_wdata_b;
            rdata_b   = rdata_L;  
            i_addr_H  = {1'b0,i_addr_a[8:1]};
            i_bmask_H = i_bmask_a;
            i_wren_H  = i_wren_a; 
            i_wdata_H  = i_wdata_a;
            rdata_a   = rdata_H; 
        end else begin
            i_addr_H  = {1'b0,i_addr_b[8:1]};
            i_bmask_H = i_bmask_b;
            i_wren_H  = i_wren_b;
            i_wdata_H  = i_wdata_b;
            rdata_b   = rdata_H;  
            i_addr_L  = {1'b0,i_addr_a[8:1]};
            i_bmask_L = i_bmask_a;
            i_wren_L  = i_wren_a;
            i_wdata_L  = i_wdata_a;
            rdata_a   = rdata_L;
        end 
    end 
    assign rdata_H = data_mem_H[i_addr_H];
    assign rdata_L = data_mem_L[i_addr_L];

    // initial begin 
    //     $readmemh("F:/DATA/Study/SEM3/VXL/milestone2/milestone2/00_src/test.hex", data_mem);
    // end    
//    always_ff @(posedge i_clk, posedge i_reset) begin
    always_ff @(posedge i_clk) begin 
		//rdata_L <= data_mem_L[i_addr_L];
        if (i_wren_L) begin 
            if (i_bmask_L[0]) data_mem_L[i_addr_L][7:0]   <= i_wdata_L[7:0];
            if (i_bmask_L[1]) data_mem_L[i_addr_L][15:8]  <= i_wdata_L[15:8];
            if (i_bmask_L[2]) data_mem_L[i_addr_L][23:16] <= i_wdata_L[23:16];
            if (i_bmask_L[3]) data_mem_L[i_addr_L][31:24] <= i_wdata_L[31:24];
        end
    end
    always_ff @(posedge i_clk) begin 
		//rdata_H <= data_mem_H[i_addr_H];
        if (i_wren_H) begin 
            if (i_bmask_H[0]) data_mem_H[i_addr_H][7:0]   <= i_wdata_H[7:0];
            if (i_bmask_H[1]) data_mem_H[i_addr_H][15:8]  <= i_wdata_H[15:8];
            if (i_bmask_H[2]) data_mem_H[i_addr_H][23:16] <= i_wdata_H[23:16];
            if (i_bmask_H[3]) data_mem_H[i_addr_H][31:24] <= i_wdata_H[31:24];
        end
    end
	 
    // always_ff @(posedge i_clk) begin 
	// 	  rdata_b <= data_mem[i_addr_b];
    //     if (i_wren_b) begin 
    //         if (i_bmask_b[0]) data_mem[i_addr_b][7:0]   <= i_wdata_b[7:0];
    //         if (i_bmask_b[1]) data_mem[i_addr_b][15:8]  <= i_wdata_b[15:8];
    //         if (i_bmask_b[2]) data_mem[i_addr_b][23:16] <= i_wdata_b[23:16];
    //         if (i_bmask_b[3]) data_mem[i_addr_b][31:24] <= i_wdata_b[31:24];
    //     end 
    // end			
			
	 
//    end 
    
    assign o_rdata_a = rdata_a;
    assign o_rdata_b = rdata_b;
 

endmodule 
