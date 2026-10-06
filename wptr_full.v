// ==============================================================================
// Module: wptr_full
// Description: Write Pointer & Full Condition Logic for Asynchronous FIFO.
//              Maintains binary write pointer for RAM addressing,
//              generates Gray-coded write pointer for CDC transmission,
//              and detects FIFO full condition.
// ==============================================================================

`timescale 1ns / 1ps

module wptr_full #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [ADDR_WIDTH:0]   wq2_rptr, // Synchronized read pointer from read domain
    output reg                   wfull,
    output wire [ADDR_WIDTH-1:0] waddr,
    output reg  [ADDR_WIDTH:0]   wptr      // Gray-coded write pointer to read domain
);

    reg  [ADDR_WIDTH:0] wbin;
    wire [ADDR_WIDTH:0] wbin_next;
    wire [ADDR_WIDTH:0] wgray_next;
    wire                wfull_val;

    // Increment binary write pointer if write requested and FIFO not full
    assign wbin_next  = wbin + (winc & ~wfull);

    // Binary-to-Gray conversion: G = B ^ (B >> 1)
    assign wgray_next = wbin_next ^ (wbin_next >> 1);

    // RAM address derived directly from lower bits of binary pointer
    assign waddr      = wbin[ADDR_WIDTH-1:0];

    // Full condition in Gray code:
    // When FIFO is full, write pointer has wrapped around exactly once compared to read pointer.
    // In Gray code, this corresponds to:
    // - MSB inverted
    // - 2nd MSB inverted
    // - Lower bits identical
    assign wfull_val  = (wgray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= {(ADDR_WIDTH+1){1'b0}};
            wptr  <= {(ADDR_WIDTH+1){1'b0}};
            wfull <= 1'b0;
        end else begin
            wbin  <= wbin_next;
            wptr  <= wgray_next;
            wfull <= wfull_val;
        end
    end

endmodule
