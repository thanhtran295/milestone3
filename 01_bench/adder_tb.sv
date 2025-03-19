module tb_adder;
    logic [31:0] a, b;
    logic cin;
    logic [31:0] sum;
    logic cout;
    
    // Instantiate the full adder
    adder uut (
        .op_a(a), .op_b(b), .cin(cin), .sum(sum), .cout(cout)
    );

logic [32:0] a_rand;
logic [32:0] b_rand;
logic [32:0] sum_exp;
initial begin
   // Test case 1: 0 + 0
   for (int i = 1; i < 100; i = i +1) begin 
     a = $random; b = $random; cin=$random; 
     $display("CASE %d: a=%h, b=%h, cin=%b", i, a, b, cin);
     a_rand = {0,a}; b_rand = {0,b};
     sum_exp = a_rand + b_rand + cin; 
     #5;
     if ((sum_exp[31:0] == sum) && (sum_exp[32] == cout)) begin 
       $display("PASS: sum=%h, cout=%b", sum, cout);
     end 
     else begin 
       $display("FAILED: EXPECTED: sum=%h, cout=%b -- ACTUAL: sum=%h, cout= %b", sum_exp[31:0],sum_exp[32], sum, cout);
     end   
   end 
end

endmodule
