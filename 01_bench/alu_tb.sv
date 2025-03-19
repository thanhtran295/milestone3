`define NUM_LOOP 50
module alu_tb;
   logic [31:0] a; // First operand
   logic [31:0] b; // Second operand
   logic [3:0]  alu_op;    // ALU operation selector
   logic [31:0] alu_data;   // ALU result 
    // Instantiate the full adder
    alu uut (
        .i_operand_a(a), 
        .i_operand_b(b), 
        .i_alu_op(alu_op), 
        .o_alu_data(alu_data)
    );

logic [31:0] sum_exp; 

initial begin
    add_case(); 
    sub_case();
    slt_case();
    sltu_case();
    xor_case();
    or_case();
    and_case();
    sll_case();
    srl_case();
    sra_case(); 
end

task add_case();
    $display("Start ADD operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0000; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = a + b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End ADD operation check");
endtask 

task sub_case();
    $display("Start SUB operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0001; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = a - b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end      
    $display("End SUB operation check");
endtask 

task slt_case();
    logic signed [31:0] a_signed, b_signed; 
    $display("Start SLT operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        a_signed = a; 
        b_signed = b; 
        alu_op = 4'b0010; 
        $display("CASE %d: a_signed=%d, b_signed=%d, alu_op=%b", i, a_signed, b_signed, alu_op);
        sum_exp = 0; 
        sum_exp = a_signed < b_signed;
        //$display(a_signed - b_signed); 
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end   
    end   
    $display("End SLT operation check");
endtask 

task sltu_case();
    $display("Start SLTU operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0011; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = 0; 
        sum_exp[0] = a < b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end  
    $display("End SLTU operation check");
endtask 
task xor_case();
    $display("Start XOR operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0100; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = a ^ b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End XOR operation check");
endtask 

task or_case();
    $display("Start OR operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0101; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = a | b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End OR operation check");
endtask 

task and_case();
    $display("Start AND operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b = $random;
        alu_op = 4'b0110; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b, alu_op);
        sum_exp = a & b;
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End AND operation check");
endtask 

task sll_case();
    $display("Start SLL operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b[4:0] = $random;
        alu_op = 4'b0111; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b[4:0], alu_op);
        sum_exp = a << b[4:0];
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End SLL operation check");
endtask 

task srl_case();
    $display("Start SRL operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b[4:0] = $random;
        alu_op = 4'b1000; 
        $display("CASE %d: a=%h, b=%h, alu_op=%b", i, a, b[4:0], alu_op);
        sum_exp = a >> b[4:0];
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end    
    $display("End SRL operation check");
endtask 

task sra_case();
    logic signed [31:0] a_signed, b_signed;
    $display("Start SRA operation check"); 
    for (int i = 1; i < `NUM_LOOP; i = i +1) begin
        a = $random; b[4:0] = $random;
        a_signed = a; 
        alu_op = 4'b1001; 
        $display("CASE %d: a_signed=%h, b=%h, alu_op=%b", i, a_signed, b[4:0], alu_op);
        sum_exp = a_signed >>> b[4:0];
        #5;
        if (sum_exp == alu_data) begin 
            $display("PASS: actual=%h, expected=%h", alu_data, sum_exp);
        end 
        else begin 
            $display("FAIL: actual=%h, expected=%h", alu_data, sum_exp);
        end
    end   
    $display("End SRA operation check");
endtask 

endmodule
