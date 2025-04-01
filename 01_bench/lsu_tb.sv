`define NUM_LOOP 50
module lsu_tb;
    // DUT signals
    logic        clk;
    logic        reset;
    logic [31:0] addr, st_data;
    logic [1:0]  size;
    logic        signed_op;
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
    .i_lsu_signed(signed_op),
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
        signed_op = u;
        wren = 0;
        @(posedge clk);
        $display("Load [%h] = %h", a, ld_data);
endtask
initial begin 
        $display("==== LSU Testbench ====");
        clk = 0;
        reset = 1;
        addr = 0;
        size = 0;
        signed_op = 0;
        wren = 0;
        io_sw = 0; 
        st_data = 0; 

        @(posedge clk);
        reset = 0;
        repeat(15) @(posedge clk);
        // Store Word aligned
        for (int i = 0; i < 4*10; i=i+4) begin 
            data_in = $random; 
            store(i, data_in, 2'b10);
        end 
        // Store Haft-Word aligned
        for (int i = 40; i < (40 +2*10); i=i+2) begin 
            data_in = $random; 
            store(i, data_in, 2'b01);
        end 
        for (int i = 60; i < (60 + 10); i=i+1) begin 
            data_in = $random; 
            store(i, data_in, 2'b00);
        end
        // Load Word
        for (int i = 0; i < 4*10; i=i+4) begin 
            load(i, 2'b10, 0);
        end 
        // Load Half-Word aligned
        for (int i = 40; i < (40 +2*10); i=i+2) begin 
            load(i, 2'b01, 0);
        end 
        // Load Byte aligned
        for (int i = 60; i < (60 + 12); i=i+1) begin 
            load(i, 2'b00, 0);
        end
        
        for (int i = 0; i < 4*10; i=i+4) begin 
            load(i, 2'b10, 1);
        end 
        // Store Haft-Word aligned
        for (int i = 40; i < (40 +2*10); i=i+2) begin 
            load(i, 2'b01, 1);
        end 
        for (int i = 60; i < (60 + 12); i=i+1) begin 
            load(i, 2'b00, 1);
        end

        for (int i = 40; i < 60; i=i+4) begin 
            load(i, 2'b10, 0);
        end
        for (int i = 60; i < 72; i=i+4) begin 
            load(i, 2'b10, 0);
        end

        data_in = $random; 
        store(32'h1000_0000, data_in, 2'b10);
        data_in = $random; 
        store(32'h1000_1000, data_in, 2'b10);
        data_in = $random; 
        store(32'h1000_2000, data_in, 2'b10);
        data_in = $random; 
        store(32'h1000_3000, data_in, 2'b10);
        data_in = $random; 
        store(32'h1000_4000, data_in, 2'b10);
        data_in = $random; 
        store(32'h1001_0000, data_in, 2'b10);
         @(posedge clk);
        load(32'h1001_0000, 2'b10, 0);
        
        

        $display("==== Done ====");
        $finish;
end  

endmodule
