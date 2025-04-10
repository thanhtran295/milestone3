`define NUM_LOOP 50
`define THANH_TB
module singlecycle_tb;
    // DUT signals
    logic            i_clk            ;
    logic            i_reset          ;
    logic [31:0]     o_pc_debug       ;
    logic            o_insn_vld       ;
    logic [31:0]     o_io_ledr        ;
    logic [31:0]     o_io_ledg        ;
    logic [6:0]      o_io_hex07 [0:7] ; 
    logic [31:0]     o_io_lcd         ; 
    logic [31:0]     i_io_sw          ;

singlecycle dut (
    .i_clk(i_clk)            ,
    .i_reset(i_reset)        ,
    .o_pc_debug(o_pc_debug)  ,
    .o_insn_vld(o_insn_vld)  ,
    .o_io_ledr(o_io_ledr)    ,
    .o_io_ledg(o_io_ledg)    ,
    .o_io_hex07(o_io_hex07)  , 
    .o_io_lcd(o_io_lcd)      , 
    .i_io_sw(i_io_sw)        
    );

always #5 i_clk = ~i_clk;

initial begin 
        $display("==== SingleCycle Testbench ====");
        i_clk   = 0;
        i_reset = 1; 
        @(posedge i_clk);
        i_reset = 0;
        i_io_sw = 32'h0000_0000; 
        repeat(15) @(posedge i_clk);
        // Store Word aligned
        repeat(8000) @(posedge i_clk);
        $finish;
end  

initial begin
    $dumpfile("wave.vcd");         // Tên file FSDB output
    $dumpvars(0, dut);              // Ghi toàn bộ hierarchy bắt đầu từ 'dut'
end

endmodule
