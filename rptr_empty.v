// ==============================================================================
// Module: rptr_empty
// Description: Read Pointer & Empty Condition Logic for Asynchronous FIFO.
//              Maintains binary read pointer for RAM addressing,
//              generates Gray-coded read pointer for CDC transmission,
//              and detects FIFO empty condition.
// ==============================================================================

`timescale 1ns / 1ps

module rptr_empty #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    input  wire [ADDR_WIDTH:0]   rq2_wptr, // Synchronized write pointer from write domain
    output reg                   rempty,
    output wire [ADDR_WIDTH-1:0] raddr,
    output reg  [ADDR_WIDTH:0]   rptr      // Gray-coded read pointer to write domain
);

    reg  [ADDR_WIDTH:0] rbin;
    wire [ADDR_WIDTH:0] rbin_next;
    wire [ADDR_WIDTH:0] rgray_next;
    wire                rempty_val;

    // Increment binary read pointer if read requested and FIFO not empty
    assign rbin_next  = rbin + (rinc & ~rempty);
    
    // Binary-to-Gray conversion: G = B ^ (B >> 1)
    // Only 1 bit flips between consecutive counts, preventing multi-bit CDC errors
    assign rgray_next = rbin_next ^ (rbin_next >> 1);

    // RAM address is derived directly from lower bits of binary pointer
    assign raddr      = rbin[ADDR_WIDTH-1:0];

    // Empty condition: write pointer matches read pointer in Gray code
    assign rempty_val = (rgray_next == rq2_wptr);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin   <= {(ADDR_WIDTH+1){1'b0}};
            rptr   <= {(ADDR_WIDTH+1){1'b0}};
            rempty <= 1'b1; // FIFO starts empty upon reset
        end else begin
            rbin   <= rbin_next;
            rptr   <= rgray_next;
            rempty <= rempty_val;
        end
    end

endmodule
