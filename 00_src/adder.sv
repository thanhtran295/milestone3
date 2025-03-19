module adder (
    input  [31:0] op_a,
    input  [31:0] op_b,
    input         cin ,
    output        cout,
    output [31:0] sum
);

logic [31:0]  cout_tmp; 
full_adder fa_0 (
    .a(op_a[0]), 
    .b(op_b[0]),
    .cin(cin),
    .cout(cout_tmp[0]),
    .sum(sum[0])
); 

genvar i; 
generate 
  for (i = 1; i < 32; i++) begin : fa
    full_adder fa_i (
        .a(op_a[i]), 
        .b(op_b[i]),
        .cin(cout_tmp[i-1]),
        .cout(cout_tmp[i]),
        .sum(sum[i])
    ); 
  end 
endgenerate 

assign cout = cout_tmp[31]; 

endmodule 
