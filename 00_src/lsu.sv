module lsu (
    input logic         i_clk,
    input logic         i_reset,
    input logic [31:0]  i_lsu_addr,
    input logic [31:0]  i_st_data,
    input logic [1:0]   i_lsu_size,  // 00: byte, 01: half-word, 10: word
    input logic         i_lsu_wren,
    output logic [31:0] o_ld_data,

    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex [0:7], // 0: Seven-segment LEDs 0-3; 1: Seven-segment LEDs 7-4
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw
);

//Instant memory model 
memory dmem_0 (
        .i_clk         (i_clk), 
        .i_reset       (i_reset), 
        .i_addr        (mem_addr),
        .i_wdata       (w_data),
        .i_bmask       (mem_bmask), 
        .i_wren        (i_lsu_wren),
        .o_rdata       (o_ld_data)
);

    logic [31:0] aligned_addr;
    logic [1:0]  byte_offset;

    logic [31:0] w_data; 
    logic [31:0] r_data;
    logic [3:0]  mem_bmask; 

    assign aligned_addr = {i_lsu_addr[31:2], 2'b00};
    assign byte_offset  = i_lsu_addr[1:0];
    assign mem_addr = aligned_addr[31:2];

    // Write Mem logic 
    always_comb begin 
        //if (i_lsu_wren) begin
            if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
                case (i_lsu_size)
                    2'b00: begin // store byte
                        //mem_addr =  mem[aligned_addr[10:2]][8*byte_offset +: 8] <= i_st_data[7:0];
                        mem_bmask = (byte_offset == 2'b00) ? (4'b0001) : 
                                    (byte_offset == 2'b01) ? (4'b0010) : 
                                    (byte_offset == 2'b10) ? (4'b0100) :
                                    (byte_offset == 2'b11) ? (4'b1000) : (4'b0001); 
                    end
                    2'b01: begin // store half-word
                        mem_bmask = (byte_offset[1] == 1'b0) ? (4'b0011) : 
                                    (byte_offset[1] == 1'b1) ? (4'b1100) : (4'b0011);
                    end
                    2'b10: begin // store word
                        mem_bmask = 4'b1111;
                    end
                    default: begin 
                        mem_bmask = 4'b1111;
                    end 
                endcase
            end else begin 
                mem_bmask = 4'b0000; 
            end 
        //end else begin
        ///    mem_bmask = 4'b0000;
        //end  
    end

//Write PIO register 
  always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            o_io_ledr <= 0;
            o_io_ledg <= 0;
            o_io_lcd  <= 0;
            for (int i = 0; i < 2; i++) o_io_hex[i] <= 0;
        end else if (i_lsu_wren) begin
            (i_lsu_addr >= 32'h1000_0000 && i_lsu_addr <= 32'h1000_0FFF) begin
                case (i_lsu_addr)
                    32'h1000_0000: o_io_ledr <= i_st_data;
                    32'h1000_1000: o_io_ledg <= i_st_data;
                    32'h1000_2000: o_io_hex[0] <= i_st_data[6:0];
                    32'h1000_3000: o_io_hex[1] <= i_st_data[6:0];
                    32'h1000_4000: o_io_lcd <= i_st_data;
                endcase
            end
        end
    end

    // Read logic
    always_comb begin
        o_ld_data = 32'd0;
        if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
            o_ld_data = r_data; 
        end else begin
            case (i_lsu_addr)
                32'h1000_0000: o_ld_data = i_io_sw;
                32'h1000_0000: o_ld_data = o_io_ledr;
                32'h1000_1000: o_ld_data = o_io_ledg;
                32'h1000_2000: o_ld_data = {25'd0, o_io_hex[0]};
                32'h1000_3000: o_ld_data = {25'd0, o_io_hex[1]};
                32'h1000_4000: o_ld_data = o_io_lcd;
            endcase
        end
    end

endmodule
