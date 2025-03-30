`define NUM_LOOP 50
module lsu_tb;
    // DUT signals
    logic        clk;
    logic        reset;
    logic [31:0] addr, st_data;
    logic [1:0]  size;
//    logic        unsigned_op;
    logic        wren;
    logic [31:0] ld_data;

    // IO outputs
    logic [31:0] io_ledr, io_ledg, io_lcd;
    logic [6:0]  io_hex [0:7];
    logic [31:0] io_sw = 32'hDEADBEEF;
    logic [31:0] data_in; 

lsu dut (
    .i_clk(clk),
    .i_reset(reset),
    .i_lsu_addr(addr),
    .i_st_data(st_data),
    .i_lsu_size(size),
//    .i_lsu_unsigned(unsigned_op),
    .i_lsu_wren(wren),
    .o_ld_data(ld_data),
    .o_io_ledr(io_ledr),
    .o_io_ledg(io_ledg),
    .o_io_hex(io_hex),
    .o_io_lcd(io_lcd),
    .i_io_sw(io_sw)
    );

always #5 clk = ~clk;


task store(input [31:0] a, input [31:0] d, input [1:0] sz);
    addr = a;
    st_data = d;
    size = sz;
    wren = 1;
    @(posedge clk);
    $display("Store [%h] = %h", a, st_data);

endtask


task load(input [31:0] a, input [1:0] sz, input u);
        addr = a;
        size = sz;
        //unsigned_op = u;
        wren = 0;
        @(posedge clk);
        $display("Load [%h] = %h", a, ld_data);
endtask
initial begin 
        $display("==== LSU Testbench ====");
        clk = 0;
        reset = 1;
        @(posedge clk);
        reset = 0;
        repeat(15) @(posedge clk);
        // Store Word aligned
        for (int i = 0; i < 4*10; i=i+4) begin 
            data_in = $random; 
            store(i, data_in, 2'b10);
        end 
        // Load Word
        load(32'h0000_0000, 2'b10, 0);
        $display("==== Done ====");
        //$finish;
end  

endmodule
