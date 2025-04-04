`timescale 1ns/1ps
//module singlecycle_tb;
//    logic            i_clk        ;
//    logic            i_reset      ;
//    logic [31:0]     o_pc_debug   ;
//    logic            o_insn_vld   ;
//    logic [31:0]     o_io_ledr    ;
//    logic [31:0]     o_io_ledg    ;
//    logic [6:0]      o_io_hex07[0:7]   ;
//    logic [31:0]     o_io_lcd     ;
//    logic [31:0]     i_io_sw      ;
    
    
//    singlecycle singlecycle_dut(
//        .i_clk          ( i_clk     ),
//        .i_reset        ( i_reset   ),
//        .o_pc_debug     ( o_pc_debug),
//        .o_insn_vld     ( o_insn_vld),
//        .o_io_ledr      ( o_io_ledr ),
//        .o_io_ledg      ( o_io_ledg ),
//        .o_io_hex07     ( o_io_hex07),
//        .o_io_lcd       ( o_io_lcd  ),
//        .i_io_sw        ( i_io_sw   )
//      );     
      
//      always #5 i_clk = ~i_clk; 
      
//      initial begin 
//            i_clk  = 0;
//            i_reset = 0;
//            i_io_sw = 32'haaaa;
//            #3
//            i_reset = 1;
//            #1 i_reset = 0;
//      end 

//endmodule 
//`timescale 1ns/1ps
// test bài toán cộng 
module singlecycle_tb;

  // Các tín hiệu giao tiếp với DUT
  logic         i_clk;
  logic         i_reset;
  logic [31:0]  o_pc_debug;
  logic         o_insn_vld;
  logic [31:0]  o_io_ledr;
  logic [31:0]  o_io_ledg;
  logic [6:0]   o_io_hex07 [0:7];
  logic [31:0]  o_io_lcd;
  logic [31:0]  i_io_sw;

  // Instantiate DUT (module singlecycle)
  singlecycle singlecycle_dut (
    .i_clk       (i_clk),
    .i_reset     (i_reset),
    .o_pc_debug  (o_pc_debug),
    .o_insn_vld  (o_insn_vld),
    .o_io_ledr   (o_io_ledr),
    .o_io_ledg   (o_io_ledg),
    .o_io_hex07  (o_io_hex07),
    .o_io_lcd    (o_io_lcd),
    .i_io_sw     (i_io_sw)
  );

  // =========================
  // Clock generation: period 10ns
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  // Reset generation: assert reset trong 20ns
  initial begin
    i_reset = 1;
    i_io_sw = 32'd0; // Giả sử không có switch nào được nhấn
    #20;
    i_reset = 0;
  end
    
  // Checker 1: Theo dõi giá trị o_pc_debug trong suốt quá trình simulation
  integer  loop_count;
  initial begin
    loop_count = 0;
    forever begin
      @(posedge i_clk);
      // Giả sử nhãn "loop:" có PC = 0x00000008.
      if (o_pc_debug == 32'h00000008) begin
         loop_count = loop_count + 1;
         $display("[Time=%0t] Detected loop iteration %0d (PC=0x%h)", $time, loop_count, o_pc_debug);
      end
      
    end
  end

  // Checker 2: Sau khi simulation chạy đủ thời gian, kiểm tra giá trị của thanh ghi x10 trong register file.
  // Giả sử rằng trong module singlecycle, register file được instance với tên "regfile_inst"
  // và thanh ghi x10 (register a0) có thể truy cập qua "DUT.regfile_inst.regs[10]".
  // (Điều này phụ thuộc vào cách bạn đặt tên và truy xuất nội bộ trong thiết kế của bạn.)
  initial begin
    #3000; // Chờ đủ thời gian để chương trình hoàn thành (điều chỉnh nếu cần)
    if (singlecycle_dut.regfile_inst.reg_mem[10] === 32'd1275)
      $display("Checker2 PASS: Register x10 : %0d", singlecycle_dut.regfile_inst.reg_mem[10]);
    else
      $display("Checker2 FAIL: Register x10 expect 1275, but %0d", singlecycle_dut.regfile_inst.reg_mem[10]);
  end

  // Checker 3: Sau khi simulation chạy đủ, kiểm tra giá trị của bộ nhớ ngoài tại địa chỉ 0x40.
  // Giả sử LS Unit của DUT có một mảng bộ nhớ nội bộ được truy xuất qua "DUT.lsu_inst.memory".
  // Với mỗi word chiếm 4 byte, địa chỉ 0x40 ứng với phần tử thứ (0x40/4) = 16.
  logic [31:0] mem_val;
  initial begin
    #3000; // Chờ đủ thời gian để chương trình hoàn thành
    
    mem_val = singlecycle_dut.lsu_inst.dmem_0.mem[16]; // Giả sử memory là mảng và index = address/4
    if (mem_val === 32'd1275)
      $display("Checker3 PASS: Memory at  0x4 : %0d", mem_val);
    else
      $display("Checker3 FAIL: Memory at 0x40 expected 1275, but %0d", mem_val);
    #10
    $finish;
  end
  
    // Checker1 Additional: Sau khi simulation chạy đủ thời gian, kiểm tra số vòng lặp đếm được
  initial begin
    #3000; // Chờ đủ thời gian để chương trình hoàn thành
    if (loop_count === 50)
      $display("Checker1 PASS: (50 iterations).");
    else
      $display("Checker1 FAIL: %0d iterations.", loop_count);
//    $finish;
  end



endmodule
