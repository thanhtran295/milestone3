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
    logic [31:0] aligned_addr;
    logic [1:0]  byte_offset;
    logic [31:0] mem_addr;
    logic [31:0] mem_addr_a;
    logic [31:0] mem_addr_b;
    logic        misalign; 
    logic [31:0] i_st_data_a; 
    logic [31:0] i_st_data_b; 
    logic [31:0] i_st_data_temp;
    logic        i_lsu_wren_a;
    logic        i_lsu_wren_b; 

    logic [31:0] r_data;
    logic [31:0] r_data_a;
    logic [31:0] r_data_b;
    logic [3:0]  mem_bmask; 
    logic [3:0]  mem_bmask_a;
    logic [3:0]  mem_bmask_b;
    logic [31:0] r_switch; 
    logic [31:0] r_seven_seg_0; 
    logic [31:0] r_seven_seg_1;
    logic [31:0] r_ledr; 
    logic [31:0] r_ledg;
    logic [31:0] r_lcd ; 


//Instant memory model 
dual_port_mem dmem_0 (
        .i_clk           (i_clk), 
        .i_reset         (i_reset), 
        .i_addr_a        (mem_addr_a),
        .i_addr_b        (mem_addr_b),
        .i_wdata_a       (i_st_data_a),
        .i_wdata_b       (i_st_data_b),
        .i_bmask_a       (mem_bmask_a),
        .i_bmask_b       (mem_bmask_b), 
        .i_wren_a        (i_lsu_wren_a),
        .i_wren_b        (i_lsu_wren_b),
        .o_rdata_a       (r_data_a),
        .o_rdata_b       (r_data_b)
);

    assign misalign = ((i_lsu_size == 2'b10) && (byte_offset != 2'b00)) ? 1'b1 : 
                      ((i_lsu_size == 2'b01) && (byte_offset[0])) ? 1'b1 : 1'b0;
   
    always_comb begin 
        if (!misalign) begin
            mem_bmask_a = mem_bmask; 
            mem_bmask_b = 4'b0; 
            i_st_data_a = i_st_data_temp;  
            i_st_data_b = 32'b0;
            mem_addr_a = mem_addr; 
            mem_addr_b = 32'b0; 
            r_data = r_data_a; 
            i_lsu_wren_a = i_lsu_wren; 
            i_lsu_wren_b = 1'b0; 
        end else begin  
            mem_addr_a = mem_addr; 
            mem_addr_b = mem_addr + 1'b1;  
            i_lsu_wren_a = i_lsu_wren; 
            i_lsu_wren_b = i_lsu_wren; 
            if (i_lsu_size == 2'b10) begin 
                case (byte_offset)
                2'b01: begin
                    i_st_data_a = {i_st_data[23:0],8'b0};  
                    i_st_data_b = {24'b0,i_st_data[31:24]}; 
                    mem_bmask_a = 4'b1110; 
                    mem_bmask_b = 4'b0001;
                    r_data = {r_data_b[7:0],r_data_a[31:8]};
                end 
                2'b10: begin
                    i_st_data_a = {i_st_data[15:0],16'b0};  
                    i_st_data_b = {16'b0,i_st_data[31:16]}; 
                    mem_bmask_a = 4'b1100; 
                    mem_bmask_b = 4'b0011;
                    r_data = {r_data_b[15:0],r_data_a[31:16]};
                end 
                2'b11: begin 
                    i_st_data_a = {i_st_data[7:0],24'b0};  
                    i_st_data_b = {8'b0,i_st_data[31:8]}; 
                    mem_bmask_a = 4'b1000; 
                    mem_bmask_b = 4'b0111;
                    r_data = {r_data_b[23:0],r_data_a[31:24]};
                end 
                default: begin
                    i_st_data_a = {i_st_data[23:0],8'b0};  
                    i_st_data_b = {24'b0,i_st_data[31:24]}; 
                    mem_bmask_a = 4'b1110; 
                    mem_bmask_b = 4'b0001;
                    r_data = {r_data_b[7:0],r_data_a[31:8]};
                end 
                endcase 
            end else begin
                case(byte_offset)
                2'b01: begin
                    i_st_data_a = {8'b0,i_st_data[15:0],8'b0};  
                    i_st_data_b = 32'b0; 
                    mem_bmask_a = 4'b0110; 
                    mem_bmask_b = 4'b0000;
                    r_data = {16'b0,r_data_a[23:8]};
                end 
                2'b11: begin
                    i_st_data_a = {i_st_data[7:0],24'b0};  
                    i_st_data_b = {24'b0,i_st_data[15:8]}; 
                    i_st_data_a = {i_st_data[23:0],8'b0};  
                    i_st_data_b = {24'b0,i_st_data[31:24]};
                    mem_bmask_a = 4'b1000; 
                    mem_bmask_b = 4'b0001;
                    r_data = {16'b0,r_data_b[7:0],r_data_a[31:24]};
                    
                end 
                default: begin 
                    mem_bmask_a = 4'b1110; 
                    mem_bmask_b = 4'b0001;
                    r_data = {r_data_b[7:0],r_data_a[31:8]};
                end 
                endcase 
            end
        end 
    end 

    assign aligned_addr = {i_lsu_addr[31:2], 2'b00};
    assign byte_offset  = i_lsu_addr[1:0];
    assign mem_addr = {2'b0, i_lsu_addr[31:2]};

    // Write Mem logic 
    always_comb begin 
        if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
            case (i_lsu_size)
                2'b00: begin // store byte 
                i_st_data_temp = (byte_offset == 2'b00) ? {24'b0,i_st_data} : 
                                 (byte_offset == 2'b01) ? {16'b0,i_st_data[7:0],8'b0} : 
                                 (byte_offset == 2'b10) ? {8'b0,i_st_data[7:0],16'b0} :
                                 (byte_offset == 2'b11) ? {i_st_data[7:0],24'b0} : {24'b0,i_st_data};

                mem_bmask = (byte_offset == 2'b00) ? (4'b0001) : 
                            (byte_offset == 2'b01) ? (4'b0010) : 
                            (byte_offset == 2'b10) ? (4'b0100) :
                            (byte_offset == 2'b11) ? (4'b1000) : (4'b0001); 
                end
                2'b01: begin // store half-word
                mem_bmask = (byte_offset[1] == 1'b0) ? (4'b0011) : 
                            (byte_offset[1] == 1'b1) ? (4'b1100) : (4'b0011);
                i_st_data_temp = (byte_offset[1] == 1'b0) ? {16'b0,i_st_data} : 
                                 (byte_offset[1] == 1'b1) ? {i_st_data, 16'b0} : {16'b0,i_st_data};
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
            o_io_ledr <= 0;
            o_io_ledg <= 0;
            o_io_lcd  <= 0;
            for (int i = 0; i < 2; i++) o_io_hex[i] <= 0;
        end else if (i_lsu_wren) begin
            if ((i_lsu_addr >= 32'h1000_0000) && (i_lsu_addr <= 32'h1000_0FFF)) begin
                case (i_lsu_addr)
                    32'h1000_0000: o_io_ledr <= i_st_data;
                    32'h1000_1000: o_io_ledg <= i_st_data;
                    32'h1000_2000: o_io_hex[0] <= i_st_data[6:0];
                    32'h1000_3000: o_io_hex[1] <= i_st_data[6:0];
                    32'h1000_4000: o_io_lcd   <= i_st_data;
                    32'h1001_0000: r_switch <= i_io_sw; 
                endcase
            end
        end
    end

    // Read logic
    always_comb begin
        o_ld_data = 32'd0;
        if (i_lsu_addr >= 32'h0000_0000 && i_lsu_addr <= 32'h0000_07FF) begin
            case (i_lsu_size)
                2'b00: begin // load byte
                //mem_addr =  mem[aligned_addr[10:2]][8*byte_offset +: 8] <= i_st_data[7:0];
                    o_ld_data = (byte_offset == 2'b00) ? {{24{i_lsu_signed & r_data[7]}}, r_data[7:0]} :
                                (byte_offset == 2'b01) ? {{24{i_lsu_signed & r_data[15]}}, r_data[15:8]} :
                                (byte_offset == 2'b10) ? {{24{i_lsu_signed & r_data[23]}}, r_data[23:16]} :
                                                         {{24{i_lsu_signed & r_data[31]}}, r_data[31:24]};
                end
                2'b01: begin // load half-word
                    o_ld_data = (byte_offset[1] == 1'b1) ? {{16{i_lsu_signed&r_data[31]}},r_data[31:16]} : {{16{i_lsu_signed&r_data[15]}},r_data[15:0]}; 
                end
                2'b10: begin // load word
                    o_ld_data = r_data;
                end
                default: begin 
                    o_ld_data = r_data;
                end 
            endcase
        end
    end

endmodule
