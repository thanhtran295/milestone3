/*
 * PrefetchBuffer for RISC-V IF stage
 * - Always non-taken predictor (fetch PC+4)
 * - Prefetch FIFO handles SRAM latency = 1
 */
module prefetch_buffer #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 4
) (
    input  logic                   clk,
    input  logic                   reset,

    // Interface to PC/branch resolution
    input  logic [ADDR_WIDTH-1:0]  pc_current,
    input  logic                   pc_stall,
    input  logic                   branch_flush,
    input  logic [ADDR_WIDTH-1:0]  branch_target,

    // SRAM interface
    output logic [ADDR_WIDTH-1:0]  sram_addr,
    output logic                   sram_req,
    input  logic                   sram_valid,
    input  logic [DATA_WIDTH-1:0]  sram_data,

    // Output to ID stage
    output logic [DATA_WIDTH-1:0]  inst_out,
    output logic                   inst_valid
);
    // FSM states
    typedef enum logic [1:0] {START, PREFILL, STEADY, FLUSH } state_t;
    state_t state, next_state;

    // next fetch address
    logic [ADDR_WIDTH-1:0] next_addr;

    // FIFO control signals
    logic fifo_full, fifo_empty;

    // FIFO instance
    logic fifo_wr_en, fifo_rd_en;
    SimpleFIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) fifo_inst (
        .clk   (clk),
        .reset (reset),
        .purge (branch_flush),
        .wr_en (fifo_wr_en),
        .rd_en (fifo_rd_en),
        .din   (sram_data),
        .dout  (inst_out),
        .full  (fifo_full),
        // .almost_full (almost_full),
        .empty (fifo_empty)
    );

    // Sequential logic: state and next_addr update
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= PREFILL;
            next_addr <= 0;
        end else begin
            state <= next_state;
            if (branch_flush) begin
                next_addr <= branch_target;
            end else if (sram_req) begin
                next_addr <= next_addr + 4;
            end
        end
    end

    assign sram_req     = (state == PREFILL) ? (pre_fill_counter <= DEPTH-1) : ((state == STEADY) && !fifo_full);
    assign sram_addr    = next_addr;
    assign inst_valid   = (state == STEADY);
    assign fifo_rd_en   = (state == STEADY) && !fifo_empty && !pc_stall;   

    assign fifo_wr_en   =  (state == PREFILL) ?  pre_fill_counter>=1 : ((state == STEADY) && !fifo_full); 


    logic [2:0] pre_fill_counter; 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pre_fill_counter <= 0;
        end 
        else if (state == PREFILL) begin
            pre_fill_counter <= pre_fill_counter + 1;
        end 
        else begin
            pre_fill_counter <= 0;
        end
    end
    // Combinational FSM and control signals
    always_comb begin
        // defaults
        next_state   = state;
        case (state)
            START: begin
                // initial state, go to prefill
                next_state = PREFILL;
            end
            PREFILL: begin
                if (pre_fill_counter == DEPTH-1) begin
                    next_state = STEADY;
                end
            end
            STEADY: begin
                if (branch_flush) begin
                    next_state = FLUSH;
                end
            end

            FLUSH: begin
                // after purge, go refill
                next_state = PREFILL;
            end

            default: next_state = PREFILL;
        endcase
    end

endmodule
