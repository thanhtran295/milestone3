module full_adder (
    input a,
    input b,
    input cin, 
    output sum,
    output cout
); 


//Sum 
assign sum = a ^ b ^ cin;

// Cout 
assign cout = (a&b) | ((a^b) & cin);

endmodule 
