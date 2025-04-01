module lsu (
    input logic         i_clk,
    input logic         i_reset,
    input logic [31:0]  i_lsu_addr,
    input logic [31:0]  i_st_data,
    input logic [1:0]   i_lsu_size,  // 00: byte, 01: half-word, 10: word
    input logic         i_lsu_signed, // 1 --> signed, 0 --> unsigned
    input logic         i_lsu_wren,
    output logic [31:0] o_ld_data,

    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex [0:7], // 0: Seven-segment LEDs 0-3; 1: Seven-segment LEDs 7-4
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw
);
    logic [31:0] aligned_addr;
    logic [1:0]  byte_offset;
    logic [31:0] mem_addr;

    logic [31:0] r_data;
    logic [3:0]  mem_bmask; 
    logic [31:0] r_switch; 
    logic [31:0] r_seven_seg_0; 
    logic [31:0] r_seven_seg_1;
    logic [31:0] r_ledr; 
    logic [31:0] r_ledg;
    logic [31:0] r_lcd ; 


//Instant memory model 
memory dmem_0 (
        .i_clk         (i_clk), 
        .i_reset       (i_reset), 
        .i_addr        (mem_addr),
        .i_wdata       (i_st_data),
        .i_bmask       (mem_bmask), 
        .i_wren        (i_lsu_wren),
        .o_rdata       (r_data)
);


    assign aligned_addr = {i_lsu_addr[31:2], 2'b00};
    assign byte_offset  = i_lsu_addr[1:0];
    assign mem_addr = {2'b0, i_lsu_addr[31:2]};

    // Write Mem logic 
    always_comb begin 
        if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
            case (i_lsu_size)
                2'b00: begin // store byte
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
    end

//Write PIO register 
  always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_switch <= 0;
            r_seven_seg_0 <= 0;
            r_seven_seg_1 <= 0;
            r_ledr  <= 0;
            r_ledg  <= 0;
            r_lcd   <= 0; 
        end else if (i_lsu_wren) begin
            case (i_lsu_addr)
                32'h1000_0000: r_ledr         <= i_st_data;
                32'h1000_1000: r_ledg         <= i_st_data;
                32'h1000_2000: r_seven_seg_0  <= i_st_data;
                32'h1000_3000: r_seven_seg_1  <= i_st_data;
                32'h1000_4000: r_lcd          <= i_st_data;
                32'h1001_0000: r_switch       <= i_io_sw; 
            endcase
        end
    end

    // Read logic
    always_comb begin
        o_ld_data = 32'd0;
        o_io_lcd  = 32'd0;
        o_io_ledr = 32'd0; 
        o_io_ledg = 32'd0; 
        for (int i = 0; i < 8; i++) o_io_hex[i] = 32'd0;
        o_io_ledr = {15'b0,r_ledr[16:0]};
        o_io_ledg = {15'b0,r_ledg[16:0]};
        
        o_io_hex[0] = {25'd0, r_seven_seg_0[6:0]};
        o_io_hex[1] = {25'd0, r_seven_seg_0[14:8]};
        o_io_hex[2] = {25'd0, r_seven_seg_0[22:16]};
        o_io_hex[3] = {25'd0, r_seven_seg_0[30:24]}; 
        o_io_hex[4] = {25'd0, r_seven_seg_1[6:0]};
        o_io_hex[5] = {25'd0, r_seven_seg_1[14:8]};
        o_io_hex[6] = {25'd0, r_seven_seg_1[22:16]};
        o_io_hex[7] = {25'd0, r_seven_seg_1[30:24]};
        o_io_lcd = {r_lcd[31],20'b0,r_lcd[10:0]};

        if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
            case (i_lsu_size)
                2'b00: begin // store byte
                //mem_addr =  mem[aligned_addr[10:2]][8*byte_offset +: 8] <= i_st_data[7:0];
                    o_ld_data = (byte_offset == 2'b00) ? {{24{i_lsu_signed & r_data[7]}}, r_data[7:0]} :
                                (byte_offset == 2'b01) ? {{24{i_lsu_signed & r_data[15]}}, r_data[15:8]} :
                                (byte_offset == 2'b10) ? {{24{i_lsu_signed & r_data[23]}}, r_data[23:16]} :
                                                         {{24{i_lsu_signed & r_data[31]}}, r_data[31:24]};
                end
                2'b01: begin // store half-word
                    o_ld_data = (byte_offset[1] == 1'b1) ? {{16{i_lsu_signed&r_data[31]}},r_data[31:16]} : {{16{i_lsu_signed&r_data[15]}},r_data[15:0]}; 
                end
                2'b10: begin // store word
                    o_ld_data = r_data;
                end
                default: begin 
                    o_ld_data = r_data;
                end 
            endcase
        end else begin 
                o_ld_data = r_switch;
        end  
    end

endmodule
