module pipelined_tb;
    // clock & reset
    logic         i_clk;
    logic         i_reset;
    // DUT I/Os
    logic [31:0]  o_pc_debug;
    logic         o_ctrl;
    logic         o_mispred;
    logic         o_insn_vld;
    logic [31:0]  o_io_ledr;
    logic [31:0]  o_io_ledg;
    logic [6:0]   o_io_hex0;
    logic [6:0]   o_io_hex1;
    logic [6:0]   o_io_hex2;
    logic [6:0]   o_io_hex3;
    logic [6:0]   o_io_hex4;
    logic [6:0]   o_io_hex5;
    logic [6:0]   o_io_hex6;
    logic [6:0]   o_io_hex7;
    logic [31:0]  o_io_lcd;
    logic [31:0]  i_io_sw;

    // Instantiate DUT
    pipelined dut (
        .i_clk        (i_clk),
        .i_reset      (i_reset),
        .o_pc_debug   (o_pc_debug),
        .o_ctrl       (o_ctrl),
        .o_mispred    (o_mispred),
        .o_insn_vld   (o_insn_vld),
        .o_io_ledr    (o_io_ledr),
        .o_io_ledg    (o_io_ledg),
        .o_io_hex0    (o_io_hex0),
        .o_io_hex1    (o_io_hex1),
        .o_io_hex2    (o_io_hex2),
        .o_io_hex3    (o_io_hex3),
        .o_io_hex4    (o_io_hex4),
        .o_io_hex5    (o_io_hex5),
        .o_io_hex6    (o_io_hex6),
        .o_io_hex7    (o_io_hex7),
        .o_io_lcd     (o_io_lcd),
        .i_io_sw      (i_io_sw)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;  // 100 MHz
    end

    // Test sequence
    initial begin
        // reset pulse
        i_reset = 1;
        i_io_sw = 32'h0000_0000;
        #4;
        i_reset = 0;

        // run for a while then finish
        #2000;
        $finish;
    end

endmodule