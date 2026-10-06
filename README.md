# Dual-Clock Asynchronous FIFO with CDC Protection

A synthesizable, parameterized dual-clock asynchronous FIFO buffer implemented in Verilog HDL. Designed to facilitate safe, zero-loss data streaming across asynchronous clock domains using Clock Domain Crossing (CDC) safeguards.

## Architecture & Features
- **Dual Independent Clock Domains:** Operates with asynchronous write clock (`wclk`) and read clock (`rclk`).
- **Clock Domain Crossing (CDC) Protection:** Implements 2-stage D-Flip-Flop synchronizers to suppress metastability and maximize Mean Time Between Failures (MTBF).
- **Gray Code Pointer Encoding:** Pointers are converted to Gray code before crossing clock domains, guaranteeing only a single bit toggles per increment cycle.
- **Look-Ahead Full and Empty Detection:**
  - `rempty`: Evaluated in the read clock domain by comparing the Gray-coded read pointer with the synchronized write pointer.
  - `wfull`: Evaluated in the write clock domain by comparing the Gray-coded write pointer with the synchronized read pointer with inverted MSB and 2nd MSB.
- **Dual-Port Memory Buffer:** Fully synthesizable memory array preventing simultaneous write-overwrite.

## Directory Structure
```
├── async_fifo.v      # Top-level module
├── fifomem.v         # Dual-port RAM array
├── sync_2ff.v        # 2-stage D-FF CDC synchronizer
├── rptr_empty.v      # Read pointer & empty generation logic
├── wptr_full.v       # Write pointer & full generation logic
└── tb_async_fifo.v   # Self-checking verification testbench
```

## Simulation & Verification
Compiled and verified using **Icarus Verilog**:
```bash
iverilog -o sim_fifo tb_async_fifo.v async_fifo.v fifomem.v sync_2ff.v rptr_empty.v wptr_full.v
vvp sim_fifo
```
Waveforms can be viewed using GTKWave:
```bash
gtkwave async_fifo.vcd
```
