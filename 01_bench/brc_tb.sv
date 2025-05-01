`define NUM_LOOP 50
module brc_tb;
   logic [31:0] a; // rs1 register
   logic [31:0] b; // rs2 register
   logic        i_br_un   ; // i_br_un = 0 --> unsigned ; i_br_un = 1 --> signed
   logic        o_br_less ; // less result
   logic        o_br_equal; // equal result 
   int pass, fail; 
    // Instantiate the full adder
    brc uut (
        .i_rs1_data(a), 
        .i_rs2_data(b), 
        .i_br_un(i_br_un), 
        .o_br_less(o_br_less),
        .o_br_equal(o_br_equal)
    );

logic [31:0] sum_exp; 

initial begin
    sltu_case();
    slt_case(); 
    equal_case();
    $display("Total PASS: %d",pass); 
    $display("Total FAIL: %d", fail);
end

task slt_case();
    logic signed [31:0] a_signed, b_signed; 
    $display("Start SLT signed operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        a_signed = a; 
        b_signed = b; 
        i_br_un = 1'b1;
        $display("CASE %d: a_signed=%d, b_signed=%d, i_br_un=%b", i, a_signed, b_signed, i_br_un);
        sum_exp = 0; 
        sum_exp = a_signed < b_signed;
        //$display(a_signed - b_signed); 
        #5;
        if (sum_exp == o_br_less) begin 
            $display("PASS: actual=%h, expected=%h", o_br_less, sum_exp);
            pass++;
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", o_br_less, sum_exp);
            fail++;
        end   
    end   
    $display("End SLT signed operation check");
endtask 

task sltu_case();
    $display("Start SLTU operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        i_br_un = 1'b0; 
        $display("CASE %d: a=%h, b=%h, i_br_un=%b", i, a, b, i_br_un);
        sum_exp = 0; 
        sum_exp = a < b;
        #5;
        if (sum_exp == o_br_less) begin 
            $display("PASS: actual=%h, expected=%h", o_br_less, sum_exp);
            pass++;
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", o_br_less, sum_exp);
            fail++;
        end
    end  
    $display("End SLTU operation check");
endtask 

task equal_case();
    $display("Start Equal operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; 
        b = a;
        i_br_un = $random;
        $display("CASE %d: a_signed=%h, b=%h, i_br_un=%b", i, a, b, i_br_un);
        sum_exp = 0;
        sum_exp = (a == b);
        #5;
        if (sum_exp == o_br_equal) begin 
            $display("PASS: actual=%h, expected=%h", o_br_equal, sum_exp);
            pass++;
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", o_br_equal, sum_exp);
            fail++;
        end
    end   
    $display("End Equal operation check");
endtask 

endmodule
