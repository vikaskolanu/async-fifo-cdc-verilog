// ==============================================================================
// Module: async_fifo
// Description: Parameterized Dual-Clock Asynchronous FIFO Top-Level Module.
//              Safely passes multi-bit data between independent write and read
//              clock domains with 2-FF synchronizers, Gray-coded pointers,
//              and full/empty flag generation.
//
// Parameters:
//   DATA_WIDTH - Width of the data bus (default: 8 bits)
//   ADDR_WIDTH - Width of the address bus (Depth = 2^ADDR_WIDTH = 16)
// ==============================================================================

`timescale 1ns / 1ps

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // Write Clock Domain
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [DATA_WIDTH-1:0] wdata,
    output wire                  wfull,

    // Read Clock Domain
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire                  rempty
);

    // Internal wires
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire [ADDR_WIDTH:0]   wptr, rptr;
    wire [ADDR_WIDTH:0]   wq2_rptr, rq2_wptr;

    // Dual-Port SRAM Memory
    fifomem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifomem (
        .wclk   (wclk),
        .wclken (winc),
        .waddr  (waddr),
        .wdata  (wdata),
        .wfull  (wfull),
        .raddr  (raddr),
        .rdata  (rdata)
    );

    // Synchronize Read Pointer into Write Clock Domain (2-FF Sync)
    sync_2ff #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_sync_r2w (
        .clk   (wclk),
        .rst_n (wrst_n),
        .din   (rptr),
        .dout  (wq2_rptr)
    );

    // Synchronize Write Pointer into Read Clock Domain (2-FF Sync)
    sync_2ff #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_sync_w2r (
        .clk   (rclk),
        .rst_n (rrst_n),
        .din   (wptr),
        .dout  (rq2_wptr)
    );

    // Read Pointer and Empty Flag Logic (in Read Domain)
    rptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr_empty (
        .rclk     (rclk),
        .rrst_n   (rrst_n),
        .rinc     (rinc),
        .rq2_wptr (rq2_wptr),
        .rempty   (rempty),
        .raddr    (raddr),
        .rptr     (rptr)
    );

    // Write Pointer and Full Flag Logic (in Write Domain)
    wptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr_full (
        .wclk     (wclk),
        .wrst_n   (wrst_n),
        .winc     (winc),
        .wq2_rptr (wq2_rptr),
        .wfull    (wfull),
        .waddr    (waddr),
        .wptr     (wptr)
    );

endmodule
