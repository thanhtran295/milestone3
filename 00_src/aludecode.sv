module aludecode(
     input logic [2:0]      i_funct3, 
     input logic            i_funct7,
     input logic  [6:0]     i_opcode, 
     output logic [3:0]     o_alu_op     
);
    localparam logic [3:0] ADD  = 4'b0000;
    localparam logic [3:0] SUB  = 4'b0001;
    localparam logic [3:0] SLT  = 4'b0010;
    localparam logic [3:0] SLTU = 4'b0011;
    localparam logic [3:0] XOR  = 4'b0100;
    localparam logic [3:0] OR   = 4'b0101;
    localparam logic [3:0] AND  = 4'b0110;
    localparam logic [3:0] SLL  = 4'b0111;
    localparam logic [3:0] SRL  = 4'b1000;
    localparam logic [3:0] SRA  = 4'b1001;
    
    
    localparam R_TYPE           =   7'b0110011; 
    localparam R_TYPE_IMM       =   7'b0010011;

    always_comb begin 
        if (i_opcode == R_TYPE) begin 
            case({i_funct7, i_funct3})
                4'b0000: o_alu_op = ADD;
                4'b1000: o_alu_op = SUB; 
                4'b0001: o_alu_op = SLL; 
                4'b0010: o_alu_op = SLT; 
                4'b0011: o_alu_op = SLTU; 
                4'b0100: o_alu_op = XOR;
                4'b0101: o_alu_op = SRL; 
                4'b1110: o_alu_op = SRA;
                4'b0110: o_alu_op = OR;
                4'b0111: o_alu_op = AND;
                default: o_alu_op = 4'bxxx; 
            endcase
        end
        else begin 
            case(i_funct3) 
                3'b000: o_alu_op = ADD;
                3'b100: o_alu_op = XOR; 
                3'b110: o_alu_op = OR; 
                3'b111: o_alu_op = AND; 
            endcase
        end
    end
    
endmodule