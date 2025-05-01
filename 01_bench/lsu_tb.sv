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
    int passed = 0;
    int failed = 0;  

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
task str_ld_cmp(input [31:0] a, input [31:0] d, input [1:0] sz, input u);
    logic [31:0] mem_addr, data_expect, data_H, data_L; 
    $display("===================");
    $display("Case %d", passed+failed+1);
     
    store(a,d,sz); 
    load(a,sz,u);

    case (sz)
    2'b00: begin
        if (u) begin 
            data_expect = {{24{d[7]}},d[7:0]};
        end else begin 
            data_expect = {{24{0}},d[7:0]};
        end 
        $display("Expected BYTE [%h] = %h", a, data_expect);
    end 
    2'b01: begin 
        if (u) begin 
            data_expect = {{16{d[15]}},d[15:0]};
        end else begin 
            data_expect = {{16{0}},d[15:0]};
        end
        $display("Expected HW [%h] = %h", a, data_expect);
    end 
    2'b10: begin 
        data_expect = d; 
        $display("Expected W [%h] = %h", a, data_expect);
    end 
    endcase
    if (ld_data == data_expect) begin  
        $display("PASS: [%h] = %h", a, ld_data);
        passed++;
    end else begin
        $display("FAILED: [%h] = %h", a, ld_data);
        $display("Time: %d", $time);
        failed++;
    end
   
endtask

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
            str_ld_cmp(i, data_in, 2'b10, 1);
        end 
        // Store Haft-Word aligned
        for (int i = 40; i < (40 +2*10); i=i+2) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b01, 1);
        end 
        for (int i = 60; i < (60 + 10); i=i+1) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b00, 1);
        end
        
        for (int i = 0; i < 4*10; i=i+4) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b10, 0);
        end 
        // Store Haft-Word aligned
        for (int i = 40; i < (40 +2*10); i=i+2) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b01, 0);
        end 
        for (int i = 60; i < (60 + 10); i=i+1) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b00, 0);
        end

        $display("==== Misaligned check ====");
        for (int i = 100; i < 110; i=i+1) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b10, 1);
        end
        for (int i = 121; i < 130; i=i+2) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b01, 0);
        end
        for (int i = 200; i < 250; i=i+5) begin 
            data_in = $random; 
            str_ld_cmp(i, data_in, 2'b01, 0);
        end
        

        $display("==== Done ====");
        $display("PASS: %d",passed);
        $display("FAIL: %d",failed);

        $finish;
end  

endmodule
