/*
 * Simple FIFO with synchronous clear for PrefetchBuffer
 */

module SimpleFIFO #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 2
) (
    input  logic                 clk,
    input  logic                 reset,
    input  logic                 purge,    // synchronous clear FIFO
    input  logic                 wr_en,
    input  logic                 rd_en,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                 full,
    output logic                 empty
);
    localparam PTR_WIDTH = $clog2(DEPTH);

    // Storage and pointers
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0]  wr_ptr, rd_ptr;
    logic [PTR_WIDTH:0]    count;

    // Sequential logic: manage pointers, count, purge
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            // dout   <= '0;
        end else if (purge) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            // dout   <= '0;
        end else begin
            // Write
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            // Read
            if (rd_en && !empty) begin
                
                rd_ptr <= rd_ptr + 1;
            end
            // Update count
            count <= count + (wr_en && !full ? 1 : 0) - (rd_en && !empty ? 1 : 0);
        end
    end
    assign dout = mem[rd_ptr];
    // Full/empty flags
    assign full  = (count == DEPTH);
    assign empty = (count == 0);
endmodule
