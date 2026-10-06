// ==============================================================================
// Module: sync_2ff
// Description: Multi-bit 2-Stage D-Flip-Flop Synchronizer.
//              Used to safely pass Gray-coded pointers across asynchronous
//              clock boundaries to reduce metastability probability (MTBF).
// ==============================================================================

`timescale 1ns / 1ps

module sync_2ff #(
    parameter WIDTH = 5  // Pointer width = ADDR_WIDTH + 1
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout
);

    reg [WIDTH-1:0] stage1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1 <= {WIDTH{1'b0}};
            dout   <= {WIDTH{1'b0}};
        end else begin
            stage1 <= din;    // First flop catches asynchronous signal (may become metastable)
            dout   <= stage1; // Second flop provides resolution time for signal to settle
        end
    end

endmodule
