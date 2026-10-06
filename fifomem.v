// ==============================================================================
// Module: fifomem
// Description: Dual-Port RAM memory buffer for Asynchronous FIFO.
//              Handles write operations in the write-clock domain and
//              read operations in the read-clock domain.
// ==============================================================================

`timescale 1ns / 1ps

module fifomem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4  // Depth = 2^ADDR_WIDTH = 16
)(
    input  wire                  wclk,
    input  wire                  wclken,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire                  wfull,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] rdata
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Dual-port RAM array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write operation: occurs on wclk posedge when write is enabled and FIFO is not full
    always @(posedge wclk) begin
        if (wclken && !wfull) begin
            mem[waddr] <= wdata;
        end
    end

    // Continuous read: asynchronous output based on current read pointer
    assign rdata = mem[raddr];

endmodule
